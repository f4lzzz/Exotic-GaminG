import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import 'pages/monitor_room_page.dart';

// ==================== WARNA (sama dengan owner dashboard) ====================
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
  final _idCtrl = TextEditingController(); // sebelumnya _menuCtrl
  final _hargaCtrl = TextEditingController();
  bool _loading = false;

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
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        _currentTime = timeFormat.format(now);
        _currentDate = dateFormat.format(now);
      });
    }
  }

  void _startClock() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _tabCtrl.dispose();
    _idCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  void _tambah() {
    try {
      final id = _idCtrl.text.trim().toUpperCase(); // ID produk
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

      context.read<AppState>().tambahTransaksi(
            namaMenu: id, // ID disimpan sebagai namaMenu
            harga: harga,
            kasir: widget.kasirName,
            shift: widget.shift,
          );

      _idCtrl.clear();
      _hargaCtrl.clear();
      _snack('Transaksi ditambah!');
    } catch (e) {
      print('Error _tambah: $e');
      _snack('Gagal menambah transaksi: $e', error: true);
    }
  }

  Future<void> _hapusTransaksi(dynamic t) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: kOrange, size: 26),
            const SizedBox(width: 8),
            Text(
              'Hapus Transaksi?',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: kTextDark,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pastikan data berikut benar sebelum dihapus:',
              style: GoogleFonts.lato(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kBgLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kBlue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogRow(Icons.barcode_reader, 'ID',
                      t.namaMenu), // label diganti ID
                  const SizedBox(height: 6),
                  _dialogRow(
                      Icons.attach_money, 'Harga', currency.format(t.harga)),
                  const SizedBox(height: 6),
                  _dialogRow(
                      Icons.access_time, 'Waktu', timeFormat.format(t.waktu)),
                  const SizedBox(height: 6),
                  _dialogRow(Icons.person_outline, 'Kasir', t.kasir),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: kRed),
                const SizedBox(width: 4),
                Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style: GoogleFonts.lato(
                    color: kRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: kBlue,
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal',
                style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              foregroundColor: kWhite,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: Text('Ya, Hapus',
                style: GoogleFonts.lato(fontWeight: FontWeight.w800)),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      context.read<AppState>().hapusTransaksi(t.id);
      _snack('Transaksi ID "${t.namaMenu}" dihapus');
    }
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: kBlue),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kTextDark,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _closing() async {
    try {
      final appState = context.read<AppState>();
      final list = appState.transaksi;

      if (list.isEmpty) {
        _snack('Belum ada transaksi', error: true);
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Konfirmasi Closing',
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.w900, color: kTextDark)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${list.length} transaksi', style: GoogleFonts.lato()),
              Text('Total: ${currency.format(appState.totalTransaksi)}',
                  style: GoogleFonts.lato(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('Cetak rekap & closing?', style: GoogleFonts.lato()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal', style: GoogleFonts.lato()),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Closing & Cetak',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _loading = true);

      try {
        await PdfService.cetakRekap(
          transaksi: list,
          kasir: widget.kasirName,
          shift: widget.shift,
        );
        appState.closingShift();
        if (mounted) _snack('Closing berhasil! PDF tersimpan.');
      } catch (e) {
        print('Error PDF: $e');
        if (mounted) _snack('Gagal cetak PDF: $e', error: true);
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    } catch (e) {
      print('Error _closing: $e');
      if (mounted) {
        _snack('Gagal closing: $e', error: true);
        setState(() => _loading = false);
      }
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
      backgroundColor: error ? kRed : kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
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
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
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
          Text(
            'GAMING & CAFE',
            style: GoogleFonts.playfairDisplay(
                fontSize: 11, color: kWhiteDim, letterSpacing: 3),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _currentTime,
                style: GoogleFonts.lato(
                    color: kWhite, fontWeight: FontWeight.w900, fontSize: 18),
              ),
              const SizedBox(height: 4),
              Text(
                _currentDate,
                style: GoogleFonts.lato(fontSize: 10, color: kWhiteDim),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Consumer<AppState>(
                  builder: (context, state, child) {
                    return Text(
                      'TRX: ${state.transaksi.length}',
                      style: GoogleFonts.lato(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kWhite),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: kBlue,
          borderRadius: BorderRadius.circular(40),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: kWhite,
        unselectedLabelColor: Colors.black45,
        labelStyle: GoogleFonts.lato(fontWeight: FontWeight.w800, fontSize: 13),
        unselectedLabelStyle:
            GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 13),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'KASIR DATA'),
          Tab(text: 'MONITOR ROOM'),
        ],
      ),
    );
  }

  Widget _buildKasirData() {
    return Consumer<AppState>(
      builder: (context, state, child) {
        final list = state.transaksi;

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
                        offset: const Offset(0, 2)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InputRow(
                      controller: _idCtrl,
                      label: 'ID',
                      hint: 'Contoh: PS5001',
                      icon: Icons.barcode_reader,
                    ),
                    const SizedBox(height: 12),
                    _InputRow(
                      controller: _hargaCtrl,
                      label: 'Harga',
                      hint: 'Contoh: 25000',
                      icon: Icons.attach_money,
                      number: true,
                    ),
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
                              borderRadius: BorderRadius.circular(12)),
                        ),
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
                  Text('${list.length} Transaksi',
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w800, color: kTextDark)),
                  Text(currency.format(state.totalTransaksi),
                      style: GoogleFonts.lato(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: kBlue)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
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
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final t = list[list.length - 1 - i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2)),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kBlue.withOpacity(0.1),
                              child: Text('${list.length - i}',
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w900,
                                      color: kBlue)),
                            ),
                            title: Text(t.namaMenu, // menampilkan ID
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w800,
                                    color: kTextDark)),
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 12, color: Colors.black38),
                                const SizedBox(width: 4),
                                Text(timeFormat.format(t.waktu),
                                    style: GoogleFonts.lato(
                                        fontSize: 12, color: Colors.black45)),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currency.format(t.harga),
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.w800,
                                        color: kBlue)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _hapusTransaksi(t),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: kRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
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
            if (list.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _closing,
                    icon: const Icon(Icons.print, color: kWhite),
                    label: Text(
                      _loading ? 'Memproses...' : 'Closing & Cetak Rekap',
                      style: GoogleFonts.lato(fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: kWhite,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
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

  const _InputRow({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.number = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
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
