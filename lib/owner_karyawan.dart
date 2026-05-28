import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'profil_owner.dart';
import 'owner_kalender.dart';
import 'notif_icon.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF9800);
const kPurple = Color(0xFF7C4DFF);
const kBgLight = Color(0xFFF0F4FF);

const String _firebaseApiKey = 'AIzaSyC30Vpz3_sU15HsDlqMuEI4ZJKlqHhkSkE';

// ─── Model Shift ─────────────────────────────────────────────────────────────
class ShiftItem {
  final String nama;
  final String jamMasuk;
  final String jamKeluar;
  final Color color;
  ShiftItem(
      {required this.nama,
      required this.jamMasuk,
      required this.jamKeluar,
      required this.color});
}

class OwnerKaryawanScreen extends StatefulWidget {
  const OwnerKaryawanScreen({super.key});

  @override
  State<OwnerKaryawanScreen> createState() => _OwnerKaryawanScreenState();
}

class _OwnerKaryawanScreenState extends State<OwnerKaryawanScreen>
    with WidgetsBindingObserver {
  int _tabIndex = 0;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  DateTime _today = DateTime.now();
  int _refreshKey = 0;

  Map<String, Map<String, dynamic>> _mapAbsensi = {};
  bool _loadingAbsensi = true;

  // Cache shift per karyawan
  Map<String, Map<String, dynamic>?> _mapShift = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateToday();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _updateToday();
  }

  void _updateToday() {
    final now = DateTime.now();
    final newToday = DateTime(now.year, now.month, now.day);
    if (_today != newToday) {
      setState(() {
        _today = newToday;
        _refreshKey++;
        _mapAbsensi.clear();
        _mapShift.clear();
        _loadingAbsensi = true;
      });
    }
  }

  Stream<QuerySnapshot> get _karyawanStream => FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'karyawan')
      .snapshots();

  Future<void> _loadAllAbsensi(List<QueryDocumentSnapshot> karyawanDocs) async {
    if (karyawanDocs.isEmpty) {
      setState(() => _loadingAbsensi = false);
      return;
    }
    final todayTimestamp = Timestamp.fromDate(_today);
    final Map<String, Map<String, dynamic>> temp = {};
    final Map<String, Map<String, dynamic>?> tempShift = {};

    for (var doc in karyawanDocs) {
      final uid = doc.id;

      // Load absensi hari ini
      final absenSnap = await FirebaseFirestore.instance
          .collection('absensi')
          .where('uid', isEqualTo: uid)
          .where('tanggal', isEqualTo: todayTimestamp)
          .limit(1)
          .get();

      if (absenSnap.docs.isNotEmpty) {
        final data = absenSnap.docs.first.data();
        final checkIn = data['checkIn'] as Timestamp?;
        final status = data['status'] as String?;
        temp[uid] = {
          'status': status ?? 'hadir',
          'checkIn': checkIn != null
              ? DateFormat('HH:mm').format(checkIn.toDate())
              : null,
          'hasCheckIn': checkIn != null,
        };
      } else {
        temp[uid] = {'status': 'belum', 'checkIn': null, 'hasCheckIn': false};
      }

      // Load shift karyawan
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data();
      if (userData != null && userData['shift'] is Map) {
        tempShift[uid] = Map<String, dynamic>.from(userData['shift'] as Map);
      } else {
        tempShift[uid] = null;
      }
    }

    if (mounted) {
      setState(() {
        _mapAbsensi = temp;
        _mapShift = tempShift;
        _loadingAbsensi = false;
      });
    }
  }

  Future<Map<String, int>> _getRingkasan(
      List<QueryDocumentSnapshot> docs) async {
    int total = docs.length, hadir = 0, belum = 0;
    for (var doc in docs) {
      final data = _mapAbsensi[doc.id];
      if (data != null && data['hasCheckIn'] == true)
        hadir++;
      else
        belum++;
    }
    return {'total': total, 'hadir': hadir, 'belum': belum};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: RefreshIndicator(
        onRefresh: () async {
          _updateToday();
          setState(() {
            _mapAbsensi.clear();
            _mapShift.clear();
            _loadingAbsensi = true;
          });
        },
        child: Column(
          children: [
            _buildHeader(),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildSummaryRow()),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _buildSearchBar()),
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: _buildTabBar()),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                key: ValueKey(_refreshKey),
                stream: _karyawanStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(Icons.people_outline,
                                size: 48, color: Colors.black26),
                            SizedBox(height: 12),
                            Text('Belum ada karyawan',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.black38)),
                          ],
                        ),
                      ),
                    );
                  }
                  final docs = snapshot.data!.docs;
                  if (_mapAbsensi.isEmpty && _loadingAbsensi) {
                    _loadAllAbsensi(docs);
                  }
                  final filtered = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nama = data['nama']?.toLowerCase() ?? '';
                    final jabatan = data['jabatan']?.toLowerCase() ?? '';
                    final matchSearch = _searchQuery.isEmpty ||
                        nama.contains(_searchQuery.toLowerCase()) ||
                        jabatan.contains(_searchQuery.toLowerCase());
                    if (!matchSearch) return false;
                    final absen = _mapAbsensi[doc.id];
                    final hasCheckIn = absen?['hasCheckIn'] == true;
                    if (_tabIndex == 1) return hasCheckIn;
                    if (_tabIndex == 2) return !hasCheckIn;
                    return true;
                  }).toList();

                  if (filtered.isEmpty && !_loadingAbsensi) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('Tidak ditemukan',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black38)),
                      ),
                    );
                  }
                  if (_loadingAbsensi) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final absenData = _mapAbsensi[doc.id];
                      final shiftData = _mapShift[doc.id];
                      return _karyawanCard(doc, absenData, shiftData);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
              children: const [
                TextSpan(
                    text: 'E',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                TextSpan(
                    text: 'X',
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
                TextSpan(
                    text: 'OTIC',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('GAMING & CAFE',
              style:
                  TextStyle(fontSize: 11, color: kWhiteDim, letterSpacing: 3)),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerIconBtn(
                Icons.settings_outlined,
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProfilOwnerScreen())),
              ),
              const SizedBox(width: 6),
              const NotifIcon(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(IconData icon,
      {int badge = 0, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration:
                    const BoxDecoration(color: kRed, shape: BoxShape.circle),
                child: Center(
                  child: Text('$badge',
                      style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: kWhite)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── SUMMARY ROW ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: _karyawanStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);
        final docs = snapshot.data!.docs;
        if (_mapAbsensi.isEmpty && _loadingAbsensi) {
          return const SizedBox(
              height: 80, child: Center(child: CircularProgressIndicator()));
        }
        return FutureBuilder<Map<String, int>>(
          future: _getRingkasan(docs),
          builder: (context, sumSnap) {
            if (sumSnap.connectionState != ConnectionState.done ||
                _loadingAbsensi) {
              return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()));
            }
            final data = sumSnap.data ?? {'total': 0, 'hadir': 0, 'belum': 0};
            return Row(
              children: [
                Expanded(
                    child: _summaryCard('TOTAL', data['total'].toString(),
                        Icons.people, kBlue)),
                const SizedBox(width: 10),
                Expanded(
                    child: _summaryCard('HADIR', data['hadir'].toString(),
                        Icons.check_circle, kGreen)),
                const SizedBox(width: 10),
                Expanded(
                    child: _summaryCard('BELUM HADIR', data['belum'].toString(),
                        Icons.hourglass_empty, kOrange)),
              ],
            );
          },
        );
      },
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.lato(
                  fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.black38)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: 'Cari nama atau jabatan...',
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchQuery = '';
                    _searchCtrl.clear();
                  }),
                  child:
                      const Icon(Icons.close, color: Colors.black38, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Semua', 'Hadir', 'Belum Hadir'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _tabIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: Container(
              margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? kBlue : kWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                tabs[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? kWhite : Colors.black45,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── KARTU KARYAWAN ───────────────────────────────────────────────────────
  Widget _karyawanCard(
    QueryDocumentSnapshot doc,
    Map<String, dynamic>? absenData,
    Map<String, dynamic>? shiftData,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = doc.id;
    final nama = data['nama'] ?? 'Tanpa Nama';
    final jabatan = data['jabatan'] ?? '-';
    final avatar = nama.isNotEmpty
        ? nama.split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '??';

    // Status absensi
    String statusText = '';
    Color statusColor = Colors.black38;
    IconData statusIcon = Icons.help_outline;
    if (absenData == null) {
      statusText = 'Memuat...';
    } else {
      final hasCheckIn = absenData['hasCheckIn'] == true;
      final status = absenData['status'];
      final checkInTime = absenData['checkIn'];
      if (hasCheckIn) {
        statusText = 'Hadir $checkInTime';
        statusColor = kGreen;
        statusIcon = Icons.check_circle;
      } else if (status == 'izin') {
        statusText = 'Izin';
        statusColor = kOrange;
        statusIcon = Icons.event_note;
      } else if (status == 'sakit') {
        statusText = 'Sakit';
        statusColor = kPurple;
        statusIcon = Icons.healing;
      } else {
        statusText = 'Belum Hadir';
        statusColor = kRed;
        statusIcon = Icons.hourglass_empty;
      }
    }

    // Info shift
    final shiftNama = shiftData?['nama'] as String?;
    final shiftMasuk = shiftData?['jamMasuk'] as String?;
    final shiftKeluar = shiftData?['jamKeluar'] as String?;
    final adaShift = shiftNama != null && shiftMasuk != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kBlue.withOpacity(0.12),
                  border:
                      Border.all(color: statusColor.withOpacity(0.5), width: 2),
                ),
                child: Center(
                    child: Text(avatar,
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: kBlue))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nama,
                        style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kTextDark)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.work_outline,
                            size: 11, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(jabatan,
                            style: GoogleFonts.lato(
                                fontSize: 11, color: Colors.black45)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        const SizedBox(width: 4),
                        Text(statusText,
                            style: GoogleFonts.lato(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      _actionBtn(
                          Icons.calendar_month,
                          kBlue,
                          () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => OwnerKalenderScreen(
                                      uid: uid, nama: nama)))),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.access_time, kPurple,
                          () => _showShiftDialog(uid, nama, shiftData)),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.edit_outlined, kBlue,
                          () => _showEditDialog(uid, data)),
                      const SizedBox(width: 6),
                      _actionBtn(Icons.delete_outline, kRed,
                          () => _showDeleteDialog(uid, nama)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // ── Chip shift (kalau ada) ────────────────────────────────────────
          if (adaShift) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: kPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kPurple.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time, size: 13, color: kPurple),
                  const SizedBox(width: 6),
                  Text(
                    '$shiftNama  •  $shiftMasuk – $shiftKeluar',
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kPurple),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showTambahDialog,
      backgroundColor: kBlue,
      icon: const Icon(Icons.person_add, color: kWhite),
      label: Text('Tambah',
          style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite)),
    );
  }

  // =========================================================================
  // DIALOG SHIFT
  // =========================================================================
  void _showShiftDialog(
      String uid, String nama, Map<String, dynamic>? currentShift) {
    final namaShiftCtrl =
        TextEditingController(text: currentShift?['nama'] ?? '');
    TimeOfDay masuk = _parseTime(currentShift?['jamMasuk'] ?? '08:00');
    TimeOfDay keluar = _parseTime(currentShift?['jamKeluar'] ?? '17:00');
    bool isLoading = false;

    // Preset shift cepat
    final presets = [
      {'nama': 'Shift Pagi', 'masuk': '07:00', 'keluar': '15:00'},
      {'nama': 'Shift Siang', 'masuk': '11:00', 'keluar': '19:00'},
      {'nama': 'Shift Malam', 'masuk': '15:00', 'keluar': '23:00'},
      {'nama': 'Shift Full', 'masuk': '08:00', 'keluar': '20:00'},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: kPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.access_time, color: kPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Atur Shift',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w900,
                            color: kTextDark,
                            fontSize: 16)),
                    Text(nama,
                        style: GoogleFonts.lato(
                            fontSize: 12, color: Colors.black45)),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nama shift
                  _dialogField(namaShiftCtrl, 'Nama Shift (misal: Shift Pagi)',
                      Icons.label_outline),
                  const SizedBox(height: 14),

                  // Preset cepat
                  Text('PRESET CEPAT',
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black45)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((p) {
                      return GestureDetector(
                        onTap: () {
                          setDlg(() {
                            namaShiftCtrl.text = p['nama']!;
                            masuk = _parseTime(p['masuk']!);
                            keluar = _parseTime(p['keluar']!);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: kPurple.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: kPurple.withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Text(p['nama']!,
                                  style: GoogleFonts.lato(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: kPurple)),
                              Text('${p['masuk']} – ${p['keluar']}',
                                  style: GoogleFonts.lato(
                                      fontSize: 10, color: Colors.black45)),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Pilih jam manual
                  Text('JAM KERJA',
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black45)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // Jam masuk
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: masuk,
                              builder: (_, child) => MediaQuery(
                                data: MediaQuery.of(ctx)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setDlg(() => masuk = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: kBgLight,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: kPurple.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.login,
                                    size: 18, color: kGreen),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(masuk),
                                  style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: kGreen),
                                ),
                                Text('Jam Masuk',
                                    style: GoogleFonts.lato(
                                        fontSize: 10, color: Colors.black38)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward,
                          color: Colors.black38, size: 20),
                      const SizedBox(width: 10),
                      // Jam keluar
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: ctx,
                              initialTime: keluar,
                              builder: (_, child) => MediaQuery(
                                data: MediaQuery.of(ctx)
                                    .copyWith(alwaysUse24HourFormat: true),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setDlg(() => keluar = picked);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 12),
                            decoration: BoxDecoration(
                              color: kBgLight,
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: kPurple.withOpacity(0.3)),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.logout, size: 18, color: kRed),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTime(keluar),
                                  style: GoogleFonts.lato(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: kRed),
                                ),
                                Text('Jam Keluar',
                                    style: GoogleFonts.lato(
                                        fontSize: 10, color: Colors.black38)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (isLoading)
                    const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Center(child: CircularProgressIndicator())),
                ],
              ),
            ),
          ),
          actions: [
            // Tombol hapus shift (kalau ada)
            if (currentShift != null)
              TextButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .update({'shift': FieldValue.delete()});
                  setState(() => _mapShift[uid] = null);
                  if (ctx.mounted) Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Shift dihapus'), backgroundColor: kRed));
                },
                icon: const Icon(Icons.delete, color: kRed, size: 16),
                label: Text('Hapus', style: GoogleFonts.lato(color: kRed)),
              ),
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal',
                    style: GoogleFonts.lato(color: Colors.black45))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: isLoading
                  ? null
                  : () async {
                      final namaShift = namaShiftCtrl.text.trim();
                      if (namaShift.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Nama shift wajib diisi'),
                            backgroundColor: kRed));
                        return;
                      }
                      setDlg(() => isLoading = true);
                      final shiftMap = {
                        'nama': namaShift,
                        'jamMasuk': _formatTime(masuk),
                        'jamKeluar': _formatTime(keluar),
                      };
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(uid)
                          .update({'shift': shiftMap});
                      setState(() => _mapShift[uid] = shiftMap);
                      if (ctx.mounted) Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('Shift $namaShift disimpan untuk $nama'),
                          backgroundColor: kGreen));
                    },
              icon: const Icon(Icons.save, color: kWhite, size: 16),
              label: Text('Simpan',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800, color: kWhite)),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  TimeOfDay _parseTime(String s) {
    final parts = s.split(':');
    if (parts.length == 2) {
      return TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 8,
          minute: int.tryParse(parts[1]) ?? 0);
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

  // =========================================================================
  // TAMBAH KARYAWAN
  // =========================================================================
  void _showTambahDialog() {
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    final konfirmasiCtrl = TextEditingController();
    final namaCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    bool isLoading = false;
    bool obscurePass = true;
    bool obscureKonfirmasi = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_add, color: kBlue),
              const SizedBox(width: 10),
              Text('Tambah Karyawan',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900, color: kTextDark)),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('INFORMASI AKUN',
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 10),
                  _dialogField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _dialogField(usernameCtrl, 'Username', Icons.alternate_email),
                  const SizedBox(height: 12),
                  _dialogField(emailCtrl, 'Email', Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  Text('KEAMANAN',
                      style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: kTextDark)),
                  const SizedBox(height: 10),
                  _dialogField(
                    passwordCtrl,
                    'Password',
                    Icons.lock_outline,
                    obscure: obscurePass,
                    suffix: IconButton(
                      icon: Icon(
                          obscurePass ? Icons.visibility_off : Icons.visibility,
                          size: 18),
                      onPressed: () => setDlg(() => obscurePass = !obscurePass),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dialogField(
                    konfirmasiCtrl,
                    'Konfirmasi Password',
                    Icons.lock_reset_outlined,
                    obscure: obscureKonfirmasi,
                    suffix: IconButton(
                      icon: Icon(
                          obscureKonfirmasi
                              ? Icons.visibility_off
                              : Icons.visibility,
                          size: 18),
                      onPressed: () =>
                          setDlg(() => obscureKonfirmasi = !obscureKonfirmasi),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(child: CircularProgressIndicator())),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal',
                    style: GoogleFonts.lato(color: Colors.black45))),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: isLoading
                  ? null
                  : () async {
                      final email = emailCtrl.text.trim();
                      final password = passwordCtrl.text.trim();
                      final konfirmasi = konfirmasiCtrl.text.trim();
                      final nama = namaCtrl.text.trim();
                      final username = usernameCtrl.text.trim();
                      if (nama.isEmpty ||
                          username.isEmpty ||
                          email.isEmpty ||
                          password.isEmpty ||
                          konfirmasi.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Semua field wajib diisi'),
                            backgroundColor: kRed));
                        return;
                      }
                      if (password != konfirmasi) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Password tidak cocok'),
                            backgroundColor: kRed));
                        return;
                      }
                      if (password.length < 6) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                            content: Text('Password minimal 6 karakter'),
                            backgroundColor: kRed));
                        return;
                      }
                      setDlg(() => isLoading = true);
                      try {
                        final url = Uri.parse(
                            'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$_firebaseApiKey');
                        final response = await http.post(
                          url,
                          body: jsonEncode({
                            'email': email,
                            'password': password,
                            'returnSecureToken': false,
                          }),
                          headers: {'Content-Type': 'application/json'},
                        );
                        if (response.statusCode != 200) {
                          final error =
                              jsonDecode(response.body)['error']['message'];
                          throw Exception('Gagal membuat akun: $error');
                        }
                        final resData = jsonDecode(response.body);
                        final uid = resData['localId'];
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .set({
                          'nama': nama,
                          'username': username,
                          'email': email,
                          'role': 'karyawan',
                          'jabatan': null,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Karyawan berhasil ditambahkan'),
                                backgroundColor: kGreen));
                        setState(() {});
                      } catch (e) {
                        String msg = e.toString().contains('EMAIL_EXISTS')
                            ? 'Email sudah digunakan'
                            : 'Gagal: $e';
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text(msg), backgroundColor: kRed));
                        setDlg(() => isLoading = false);
                      }
                    },
              icon: const Icon(Icons.person_add, color: kWhite, size: 18),
              label: Text('Buat Akun',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800, color: kWhite)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // EDIT KARYAWAN
  // =========================================================================
  void _showEditDialog(String uid, Map<String, dynamic> data) {
    final namaCtrl = TextEditingController(text: data['nama'] ?? '');
    final usernameCtrl = TextEditingController(text: data['username'] ?? '');
    final jabatanCtrl = TextEditingController(text: data['jabatan'] ?? '');
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          backgroundColor: kWhite,
          surfaceTintColor: kWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Karyawan',
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900, color: kTextDark)),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _dialogField(usernameCtrl, 'Username', Icons.alternate_email),
                  const SizedBox(height: 12),
                  _dialogField(jabatanCtrl, 'Jabatan', Icons.work_outline),
                  if (isLoading)
                    const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Batal',
                    style: GoogleFonts.lato(color: Colors.black45))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kBlue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              onPressed: isLoading
                  ? null
                  : () async {
                      setDlg(() => isLoading = true);
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .update({
                          'nama': namaCtrl.text.trim(),
                          'username': usernameCtrl.text.trim(),
                          'jabatan': jabatanCtrl.text.trim().isEmpty
                              ? null
                              : jabatanCtrl.text.trim(),
                        });
                        if (ctx.mounted) Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Data karyawan diperbarui'),
                                backgroundColor: kGreen));
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                            content: Text('Gagal update: $e'),
                            backgroundColor: kRed));
                        setDlg(() => isLoading = false);
                      }
                    },
              child: Text('Simpan',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800, color: kWhite)),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HAPUS KARYAWAN
  // =========================================================================
  void _showDeleteDialog(String uid, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Karyawan',
            style: GoogleFonts.lato(
                fontWeight: FontWeight.w900, color: kTextDark)),
        content: SizedBox(
          width: MediaQuery.of(ctx).size.width,
          child: RichText(
            text: TextSpan(
              style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
              children: [
                const TextSpan(text: 'Yakin hapus '),
                TextSpan(
                    text: nama,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, color: kTextDark)),
                const TextSpan(text: '?'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal',
                  style: GoogleFonts.lato(color: Colors.black45))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Karyawan dihapus'), backgroundColor: kRed));
            },
            child: Text('Hapus',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w800, color: kWhite)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
          color: kBgLight, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: ctrl,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: Icon(icon, size: 18, color: Colors.black38),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}