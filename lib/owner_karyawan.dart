import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'notifikasi_owner.dart';
import 'profil_owner.dart';
import 'owner_kalender.dart';

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

  // Data absensi semua karyawan (uid -> data)
  Map<String, Map<String, dynamic>> _mapAbsensi = {};
  bool _loadingAbsensi = true;

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
    if (state == AppLifecycleState.resumed) {
      _updateToday();
    }
  }

  void _updateToday() {
    final now = DateTime.now();
    final newToday = DateTime(now.year, now.month, now.day);
    if (_today != newToday) {
      setState(() {
        _today = newToday;
        _refreshKey++;
        _mapAbsensi.clear();
        _loadingAbsensi = true;
      });
    }
  }

  Stream<QuerySnapshot> get _karyawanStream {
    return FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'karyawan')
        .snapshots();
  }

  // Load absensi semua karyawan untuk hari ini (sekali jalan)
  Future<void> _loadAllAbsensi(List<QueryDocumentSnapshot> karyawanDocs) async {
    if (karyawanDocs.isEmpty) {
      setState(() => _loadingAbsensi = false);
      return;
    }
    final todayTimestamp = Timestamp.fromDate(_today);
    final Map<String, Map<String, dynamic>> temp = {};

    for (var doc in karyawanDocs) {
      final uid = doc.id;
      final snapshot = await FirebaseFirestore.instance
          .collection('absensi')
          .where('uid', isEqualTo: uid)
          .where('tanggal', isEqualTo: todayTimestamp)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
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
    }
    if (mounted) {
      setState(() {
        _mapAbsensi = temp;
        _loadingAbsensi = false;
      });
    }
  }

  Future<Map<String, int>> _getRingkasan(
    List<QueryDocumentSnapshot> docs,
  ) async {
    int total = docs.length;
    int hadir = 0;
    int belum = 0;
    for (var doc in docs) {
      final data = _mapAbsensi[doc.id];
      if (data != null && data['hasCheckIn'] == true) {
        hadir++;
      } else {
        belum++;
      }
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
          setState(() {});
        },
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSummaryRow(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildSearchBar(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _buildTabBar(),
            ),
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
                            Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.black26,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Belum ada karyawan',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
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
                    final matchSearch =
                        _searchQuery.isEmpty ||
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
                        child: Text(
                          'Tidak ditemukan',
                          style: TextStyle(fontSize: 14, color: Colors.black38),
                        ),
                      ),
                    );
                  }
                  if (_loadingAbsensi) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      80,
                    ), // padding bottom lebih besar agar tidak tertutup FAB
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final absenData = _mapAbsensi[doc.id];
                      return _karyawanCard(doc, absenData);
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
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: 'OTIC',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'GAMING & CAFE',
            style: TextStyle(fontSize: 11, color: kWhiteDim, letterSpacing: 3),
          ),
          const Spacer(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _headerIconBtn(
                Icons.settings_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilOwnerScreen()),
                ),
              ),
              const SizedBox(width: 6),
              _headerIconBtn(
                Icons.notifications_outlined,
                badge: 3,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotifikasiOwnerScreen(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconBtn(
    IconData icon, {
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: kRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: _karyawanStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox(height: 80);
        final docs = snapshot.data!.docs;
        if (_mapAbsensi.isEmpty && _loadingAbsensi)
          return const SizedBox(height: 80);
        return FutureBuilder<Map<String, int>>(
          future: _getRingkasan(docs),
          builder: (context, sumSnap) {
            if (sumSnap.connectionState != ConnectionState.done ||
                _loadingAbsensi) {
              return const SizedBox(
                height: 80,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final data = sumSnap.data ?? {'total': 0, 'hadir': 0, 'belum': 0};
            return Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    'TOTAL',
                    data['total'].toString(),
                    Icons.people,
                    kBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'HADIR',
                    data['hadir'].toString(),
                    Icons.check_circle,
                    kGreen,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _summaryCard(
                    'BELUM HADIR',
                    data['belum'].toString(),
                    Icons.hourglass_empty,
                    kOrange,
                  ),
                ),
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
            ),
          ),
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
            offset: const Offset(0, 2),
          ),
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
                  child: const Icon(
                    Icons.close,
                    color: Colors.black38,
                    size: 18,
                  ),
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
                    offset: const Offset(0, 2),
                  ),
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

  Widget _karyawanCard(
    QueryDocumentSnapshot doc,
    Map<String, dynamic>? absenData,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final uid = doc.id;
    final nama = data['nama'] ?? 'Tanpa Nama';
    final jabatan = data['jabatan'] ?? '-';
    final avatar = nama.isNotEmpty
        ? nama.split(' ').take(2).map((e) => e[0].toUpperCase()).join()
        : '??';

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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBlue.withOpacity(0.12),
              border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                avatar,
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 11, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      jabatan,
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
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
                        builder: (_) =>
                            OwnerKalenderScreen(uid: uid, nama: nama),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    Icons.edit_outlined,
                    kBlue,
                    () => _showEditDialog(uid, data),
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    Icons.delete_outline,
                    kRed,
                    () => _showDeleteDialog(uid, nama),
                  ),
                ],
              ),
            ],
          ),
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _showTambahDialog,
      backgroundColor: kBlue,
      icon: const Icon(Icons.person_add, color: kWhite),
      label: Text(
        'Tambah',
        style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite),
      ),
    );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.person_add, color: kBlue),
              const SizedBox(width: 10),
              Text(
                'Tambah Karyawan',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INFORMASI AKUN',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dialogField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                  const SizedBox(height: 12),
                  _dialogField(usernameCtrl, 'Username', Icons.alternate_email),
                  const SizedBox(height: 12),
                  _dialogField(
                    emailCtrl,
                    'Email',
                    Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'KEAMANAN',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _dialogField(
                    passwordCtrl,
                    'Password',
                    Icons.lock_outline,
                    obscure: obscurePass,
                    suffix: IconButton(
                      icon: Icon(
                        obscurePass ? Icons.visibility_off : Icons.visibility,
                        size: 18,
                      ),
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
                        size: 18,
                      ),
                      onPressed: () =>
                          setDlg(() => obscureKonfirmasi = !obscureKonfirmasi),
                    ),
                  ),
                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.lato(color: Colors.black45),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Semua field wajib diisi'),
                            backgroundColor: kRed,
                          ),
                        );
                        return;
                      }
                      if (password != konfirmasi) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Password tidak cocok'),
                            backgroundColor: kRed,
                          ),
                        );
                        return;
                      }
                      if (password.length < 6) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                            content: Text('Password minimal 6 karakter'),
                            backgroundColor: kRed,
                          ),
                        );
                        return;
                      }
                      setDlg(() => isLoading = true);
                      try {
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                              email: email,
                              password: password,
                            );
                        String uid = userCredential.user!.uid;
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
                            backgroundColor: kGreen,
                          ),
                        );
                      } catch (e) {
                        String msg = e is FirebaseAuthException
                            ? (e.code == 'email-already-in-use'
                                  ? 'Email sudah digunakan'
                                  : 'Gagal: ${e.message}')
                            : 'Terjadi kesalahan: $e';
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text(msg), backgroundColor: kRed),
                        );
                        setDlg(() => isLoading = false);
                      }
                    },
              icon: const Icon(Icons.person_add, color: kWhite, size: 18),
              label: Text(
                'Buat Akun',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Karyawan',
            style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kTextDark),
          ),
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
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.lato(color: Colors.black45),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
                            backgroundColor: kGreen,
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('Gagal update: $e'),
                            backgroundColor: kRed,
                          ),
                        );
                        setDlg(() => isLoading = false);
                      }
                    },
              child: Text(
                'Simpan',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
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
        title: Text(
          'Hapus Karyawan',
          style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kTextDark),
        ),
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
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.lato(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .delete();
              if (ctx.mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Karyawan dihapus'),
                  backgroundColor: kRed,
                ),
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w800,
                color: kWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // FIELD FORM
  // =========================================================================
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
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
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
