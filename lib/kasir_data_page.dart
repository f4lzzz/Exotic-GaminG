import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import 'pages/monitor_room_page.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF9800);
const kBgLight = Color(0xFFF0F4FF);

class KasirDataPage extends StatefulWidget {
  final String kasirName;
  final String shift;
  const KasirDataPage(
      {super.key, required this.kasirName, required this.shift});

  @override
  State<KasirDataPage> createState() => _KasirDataPageState();
}

class _KasirDataPageState extends State<KasirDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _idCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();
  bool _loading = false;

  bool _shiftStarted = false;
  DateTime? _shiftStartTime;
  String? _activeShiftId;

  String _currentTime = '';
  String _currentDate = '';

  final currency =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  late final DateFormat timeFormat;
  late final DateFormat dateFormat;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    timeFormat = DateFormat('HH:mm:ss', 'id_ID');
    dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    _tabCtrl = TabController(length: 2, vsync: this);
    _updateDateTime();
    _startClock();
    _checkActiveShift();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted)
      setState(() {
        _currentTime = timeFormat.format(now);
        _currentDate = dateFormat.format(now);
      });
  }

  void _startClock() {
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _updateDateTime());
  }

  Future<void> _checkActiveShift() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('shifts')
        .where('kasirUid', isEqualTo: user.uid)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();
    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      setState(() {
        _shiftStarted = true;
        _activeShiftId = doc.id;
        _shiftStartTime = (doc['shiftStart'] as Timestamp).toDate();
      });
    }
  }

  Future<void> _startShift() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _snack('User tidak login', error: true);
      return;
    }
    if (_shiftStarted) {
      _snack('Shift sudah dimulai', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final docRef = await FirebaseFirestore.instance.collection('shifts').add({
        'kasirUid': user.uid,
        'kasirName': widget.kasirName,
        'shiftLabel': widget.shift,
        'shiftStart': FieldValue.serverTimestamp(),
        'shiftEnd': null,
        'status': 'active',
        'totalOmzet': 0,
        'totalTransaksi': 0,
      });
      setState(() {
        _shiftStarted = true;
        _activeShiftId = docRef.id;
        _shiftStartTime = DateTime.now();
        _loading = false;
      });
      _snack(
          'Shift dimulai pukul ${DateFormat('HH:mm').format(_shiftStartTime!)}');
    } catch (e) {
      setState(() => _loading = false);
      _snack('Gagal memulai shift: $e', error: true);
    }
  }

  Future<void> _endShift() async {
    if (!_shiftStarted) {
      _snack('Shift belum dimulai', error: true);
      return;
    }
    final transactions = await FirebaseFirestore.instance
        .collection('transaksi')
        .where('shiftId', isEqualTo: _activeShiftId)
        .get();
    if (transactions.docs.isEmpty) {
      _snack('Tidak ada transaksi untuk diakhiri', error: true);
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Akhiri Shift?',
            style: GoogleFonts.lato(fontWeight: FontWeight.w900)),
        content:
            Text('${transactions.docs.length} transaksi. Lanjutkan closing?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Akhiri Shift & Cetak')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loading = true);
    try {
      double totalOmzet = 0;
      for (var doc in transactions.docs) {
        final harga = doc['harga'];
        if (harga is num) totalOmzet += harga.toDouble();
      }
      await FirebaseFirestore.instance
          .collection('shifts')
          .doc(_activeShiftId)
          .update({
        'shiftEnd': FieldValue.serverTimestamp(),
        'status': 'closed',
        'totalOmzet': totalOmzet,
        'totalTransaksi': transactions.docs.length,
      });
      // Cetak PDF (opsional, sementara dinonaktifkan karena tipe data)
      // TODO: implement PDF printing with proper model
      // await PdfService.cetakRekap(transaksi: list, kasir: widget.kasirName, shift: widget.shift);
      print(
          'Shift ended with ${transactions.docs.length} transactions, total: $totalOmzet');
      setState(() {
        _shiftStarted = false;
        _activeShiftId = null;
        _shiftStartTime = null;
        _loading = false;
      });
      _snack('Shift selesai! Rekap tersimpan di Firestore.');
    } catch (e) {
      setState(() => _loading = false);
      _snack('Gagal mengakhiri shift: $e', error: true);
    }
  }

  Future<void> _tambah() async {
    if (!_shiftStarted) {
      _snack('Mulai shift terlebih dahulu!', error: true);
      return;
    }
    try {
      final id = _idCtrl.text.trim().toUpperCase();
      final hargaText =
          _hargaCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');
      if (id.isEmpty || hargaText.isEmpty) {
        _snack('ID & harga wajib diisi', error: true);
        return;
      }
      final harga = double.tryParse(hargaText);
      if (harga == null || harga <= 0) {
        _snack('Harga tidak valid', error: true);
        return;
      }
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _snack('User tidak login', error: true);
        return;
      }
      await FirebaseFirestore.instance.collection('transaksi').add({
        'kasirUid': user.uid,
        'kasirName': widget.kasirName,
        'namaMenu': id,
        'harga': harga,
        'timestamp': FieldValue.serverTimestamp(),
        'shift': widget.shift,
        'shiftId': _activeShiftId,
      });
      _idCtrl.clear();
      _hargaCtrl.clear();
      _snack('Transaksi ditambah!');
    } catch (e) {
      _snack('Gagal menambah transaksi: $e', error: true);
    }
  }

  Future<void> _hapusTransaksi(String docId, String namaMenu) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Transaksi?',
            style: GoogleFonts.lato(fontWeight: FontWeight.w900)),
        content: Text('Yakin hapus transaksi "$namaMenu"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text('Batal')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya, Hapus')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('transaksi')
            .doc(docId)
            .delete();
        _snack('Transaksi "$namaMenu" dihapus');
      } catch (e) {
        _snack('Gagal hapus: $e', error: true);
      }
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
      backgroundColor: error ? kRed : kGreen,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        if (!_shiftStarted)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _startShift,
              icon: const Icon(Icons.play_arrow),
              label: const Text('MULAI SHIFT'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kGreen,
                  minimumSize: const Size(double.infinity, 48)),
            ),
          )
        else
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
                color: kBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBlue.withOpacity(0.3))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shift Aktif',
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.w800, color: kTextDark)),
                      Text(
                          'Dimulai: ${DateFormat('HH:mm').format(_shiftStartTime!)}',
                          style: GoogleFonts.lato(
                              fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _endShift,
                  icon: const Icon(Icons.stop, color: kWhite),
                  label: const Text('AKHIRI SHIFT'),
                  style: ElevatedButton.styleFrom(backgroundColor: kRed),
                ),
              ],
            ),
          ),
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              _buildKasirData(),
              const MonitorRoomPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 16),
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
          Text('GAMING & CAFE',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 11, color: kWhiteDim, letterSpacing: 3)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_currentTime,
                  style: GoogleFonts.lato(
                      color: kWhite,
                      fontWeight: FontWeight.w900,
                      fontSize: 18)),
              const SizedBox(height: 4),
              Text(_currentDate,
                  style: GoogleFonts.lato(fontSize: 10, color: kWhiteDim)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
            color: kBlue, borderRadius: BorderRadius.circular(40)),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: kWhite,
        unselectedLabelColor: Colors.black45,
        labelStyle: GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [Tab(text: 'KASIR DATA'), Tab(text: 'MONITOR ROOM')],
      ),
    );
  }

  Widget _buildKasirData() {
    if (!_shiftStarted || _activeShiftId == null) {
      return const Center(
          child: Text('Mulai shift terlebih dahulu untuk melihat transaksi',
              style: TextStyle(color: Colors.black45)));
    }
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transaksi')
          .where('shiftId', isEqualTo: _activeShiftId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.lato(color: kRed)));
        }
        final docs = snapshot.data?.docs ?? [];
        double totalOmzet = 0;
        for (var doc in docs) {
          final harga = doc['harga'];
          if (harga is num) totalOmzet += harga.toDouble();
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2))
                    ]),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InputRow(
                        controller: _idCtrl,
                        label: 'ID',
                        hint: 'Contoh: PS5001',
                        icon: Icons.barcode_reader),
                    const SizedBox(height: 12),
                    _InputRow(
                        controller: _hargaCtrl,
                        label: 'Harga',
                        hint: 'Contoh: 25000',
                        icon: Icons.attach_money,
                        number: true),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _tambah,
                        icon:
                            const Icon(Icons.add_circle_outline, color: kWhite),
                        label: Text('Tambah Transaksi',
                            style:
                                GoogleFonts.lato(fontWeight: FontWeight.w800)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: kBlue,
                            foregroundColor: kWhite,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${docs.length} Transaksi',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w800, color: kTextDark)),
                  Text(currency.format(totalOmzet.round()),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: kBlue)),
                ],
              ),
            ),
            Expanded(
              child: docs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_outlined,
                              size: 48, color: Colors.black26),
                          const SizedBox(height: 12),
                          Text('Belum ada transaksi',
                              style: GoogleFonts.lato(
                                  fontSize: 13, color: Colors.black38)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: docs.length,
                      itemBuilder: (ctx, i) {
                        final doc = docs[i];
                        final data = doc.data() as Map<String, dynamic>;
                        final namaMenu = data['namaMenu'] ?? '-';
                        final harga = data['harga'] ?? 0;
                        final timestamp = data['timestamp'] as Timestamp?;
                        final waktu = timestamp != null
                            ? timeFormat.format(timestamp.toDate())
                            : '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                              color: kWhite,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ]),
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: kBlue.withOpacity(0.1),
                                child: Text('${docs.length - i}',
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w900,
                                        color: kBlue))),
                            title: Text(namaMenu,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w800,
                                    color: kTextDark)),
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 12, color: Colors.black38),
                                const SizedBox(width: 4),
                                Text(waktu,
                                    style: GoogleFonts.lato(
                                        fontSize: 12, color: Colors.black45)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    currency.format(
                                        harga is num ? harga.round() : 0),
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w800,
                                        color: kBlue)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () =>
                                      _hapusTransaksi(doc.id, namaMenu),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                        color: kRed.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Icon(Icons.delete_outline,
                                        color: kRed, size: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _InputRow extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool number;
  const _InputRow(
      {required this.controller,
      required this.label,
      required this.hint,
      required this.icon,
      this.number = false});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: kBgLight, borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(
        children: [
          Icon(icon, color: kBlue, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              style: GoogleFonts.lato(color: kTextDark, fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                hintText: hint,
                labelStyle: GoogleFonts.lato(
                    fontWeight: FontWeight.w600, color: kBlue, fontSize: 13),
                hintStyle:
                    GoogleFonts.lato(color: Colors.black38, fontSize: 13),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
