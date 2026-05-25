import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../services/pdf_service.dart';
import 'pages/monitor_room_page.dart';

const Color kBlueDark = Color(0xFF2C5AA0);
const Color kBlue = Color(0xFF3A7BD5);
const Color kGreen = Color(0xFF2E8B57);
const Color kRed = Color(0xFFE74C3C);
const Color kOrange = Color(0xFFE67E22);
const Color kTextDark = Color(0xFF1A2C3E);
const Color kTextMid = Color(0xFF5A6E7F);
const Color kWhite = Color(0xFFFFFFFF);
const Color kWhiteDim = Color(0xCCFFFFFF);
const Color kBgLight = Color(0xFFE8EFF9);

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
  final _menuCtrl = TextEditingController();
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
    _menuCtrl.dispose();
    _hargaCtrl.dispose();
    super.dispose();
  }

  void _tambah() {
    try {
      final menu = _menuCtrl.text.trim();
      final hargaText =
          _hargaCtrl.text.trim().replaceAll('.', '').replaceAll(',', '');

      if (menu.isEmpty || hargaText.isEmpty) {
        _snack('Nama menu & harga wajib diisi', error: true);
        return;
      }

      final harga = double.tryParse(hargaText);
      if (harga == null || harga <= 0) {
        _snack('Harga tidak valid', error: true);
        return;
      }

      context.read<AppState>().tambahTransaksi(
            namaMenu: menu,
            harga: harga,
            kasir: widget.kasirName,
            shift: widget.shift,
          );

      _menuCtrl.clear();
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
        backgroundColor:
            const Color(0xFFF0F5FF), // 🎨 BACKGROUND DIALOG → biru muda
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 26),
            SizedBox(width: 8),
            Text(
              'Hapus Transaksi?',
              style: TextStyle(
                fontSize: 16,
                color: kTextDark, // 🎨 JUDUL DIALOG
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
              style: TextStyle(
                color: kTextMid, // 🎨 TEKS KETERANGAN ATAS
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(
                    0xFFDDE8FF), // 🎨 BACKGROUND KOTAK ISI → biru muda
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: kBlue), // 🎨 BORDER KOTAK → biru
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _dialogRow(Icons.fastfood_outlined, 'Menu', t.namaMenu),
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
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline, size: 13, color: Colors.red.shade700),
                const SizedBox(width: 4),
                Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  style: TextStyle(
                    color: Colors.red.shade700, // 🎨 TEKS PERINGATAN MERAH
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side:
                  const BorderSide(color: kBlueDark), // 🎨 BORDER TOMBOL BATAL
              foregroundColor: kBlueDark, // 🎨 TEKS TOMBOL BATAL
            ),
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed, // 🎨 BACKGROUND TOMBOL HAPUS
              foregroundColor: kWhite, // 🎨 TEKS & ICON TOMBOL HAPUS
            ),
            icon: const Icon(Icons.delete_outline, size: 18),
            label: const Text('Ya, Hapus'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      context.read<AppState>().hapusTransaksi(t.id);
      _snack('Transaksi "${t.namaMenu}" dihapus');
    }
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 13, color: kBlueDark), // 🎨 WARNA ICON
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: kTextMid, // 🎨 WARNA LABEL (Menu:, Harga:, dll)
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kBlueDark, // 🎨 WARNA VALUE (isi data)
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
        builder: (_) => AlertDialog(
          title: const Text('Konfirmasi Closing'),
          content: Text(
            '${list.length} transaksi\nTotal: ${currency.format(appState.totalTransaksi)}\n\nCetak rekap & closing?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBlueDark),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Closing & Cetak',
                  style: TextStyle(color: Colors.white)),
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
      content: Text(msg),
      backgroundColor: error ? kRed : kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              MonitorRoomPage(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6BAAF5), kBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.point_of_sale, color: kWhite, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KASIR POS',
                      style: TextStyle(
                          color: kWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w900)),
                  Text(widget.kasirName,
                      style: TextStyle(
                          color: kWhite.withOpacity(0.8), fontSize: 11)),
                  Text(widget.shift,
                      style: TextStyle(
                          color: kWhite.withOpacity(0.7), fontSize: 10)),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      _currentTime,
                      style: const TextStyle(
                        color: kWhite,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _currentDate.isNotEmpty
                          ? _currentDate.split(',').first
                          : '',
                      style: TextStyle(
                          color: kWhite.withOpacity(0.8), fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        color: kWhite.withOpacity(0.7), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _currentDate,
                      style: TextStyle(
                          color: kWhite.withOpacity(0.8), fontSize: 10),
                    ),
                  ],
                ),
                Consumer<AppState>(
                  builder: (context, state, child) {
                    return Row(
                      children: [
                        Icon(Icons.receipt,
                            color: kWhite.withOpacity(0.7), size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'TRX: ${state.transaksi.length}',
                          style: const TextStyle(
                              color: kWhite,
                              fontWeight: FontWeight.w900,
                              fontSize: 11),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: kBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: kWhite,
        unselectedLabelColor: kBlueDark, // 🎨 WARNA TAB TIDAK AKTIF
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFBBCEFF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _InputRow(
                      controller: _menuCtrl,
                      label: 'Nama Menu',
                      hint: 'Contoh: Indomie Goreng',
                      icon: Icons.fastfood_outlined,
                    ),
                    const SizedBox(height: 10),
                    _InputRow(
                      controller: _hargaCtrl,
                      label: 'Harga',
                      hint: 'Contoh: 25000',
                      icon: Icons.attach_money,
                      number: true,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _tambah,
                        icon:
                            const Icon(Icons.add_circle_outline, color: kWhite),
                        label: const Text('Tambah Transaksi',
                            style: TextStyle(
                                color: kWhite, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlueDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${list.length} Transaksi',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: kBlueDark)),
                  Text(currency.format(state.totalTransaksi),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kBlueDark,
                          fontSize: 16)),
                ],
              ),
            ),
            Expanded(
              child: list.isEmpty
                  ? const Center(
                      child: Text('Belum ada transaksi',
                          style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        final t = list[list.length - 1 - i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBCEFF)),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: kBlueDark,
                              child: Text('${list.length - i}',
                                  style: const TextStyle(
                                      color: kWhite, fontSize: 13)),
                            ),
                            title: Text(
                              t.namaMenu,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kBlueDark, // 🎨 WARNA NAMA MENU
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Icon(Icons.access_time,
                                    size: 12, color: kTextMid),
                                const SizedBox(width: 4),
                                Text(
                                  timeFormat.format(t.waktu),
                                  style:
                                      TextStyle(color: kTextMid, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currency.format(t.harga),
                                  style: const TextStyle(
                                      color: kBlueDark,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () => _hapusTransaksi(t),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: kRed.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: kRed,
                                      size: 18,
                                    ),
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
                      style: const TextStyle(
                          color: kWhite, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
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
      decoration:
          BoxDecoration(color: kWhite, borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: kBlueDark, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: number ? TextInputType.number : TextInputType.text,
              style: const TextStyle(color: Colors.black, fontSize: 13),
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: label,
                hintText: hint,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: kBlueDark,
                    fontSize: 13),
                hintStyle: TextStyle(color: kTextMid, fontSize: 13),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
