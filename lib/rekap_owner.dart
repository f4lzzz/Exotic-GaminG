import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
const kPurple = Color(0xFF7C4DFF);

// ─── MODEL ───────────────────────────────────────────────────────────────────
enum PeriodeRekap { hariIni, mingguIni, bulanIni, tahunIni }

class DetailTransaksi {
  final String id;
  final String nama;
  final String kategori;
  final int jumlah;
  final int harga;
  final String waktu;
  final String inisial;

  const DetailTransaksi({
    required this.id,
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.harga,
    required this.waktu,
    required this.inisial,
  });

  int get total => jumlah * harga;
}

class RekapData {
  final int tahun;
  final int pendapatanHariIni;
  final int transaksiHariIni;
  final int pendapatanMingguIni;
  final int transaksiMingguIni;
  final int pendapatanBulanIni;
  final int transaksiBulanIni;
  final int pendapatanTahunIni;
  final int transaksiTahunIni;
  final List<int> grafikBulanan;
  final List<int> grafikMingguan;
  final List<DetailTransaksi> detailHariIni;
  final List<DetailTransaksi> detailMingguIni;
  final List<DetailTransaksi> detailBulanIni;
  final List<DetailTransaksi> detailTahunIni;

  const RekapData({
    required this.tahun,
    required this.pendapatanHariIni,
    required this.transaksiHariIni,
    required this.pendapatanMingguIni,
    required this.transaksiMingguIni,
    required this.pendapatanBulanIni,
    required this.transaksiBulanIni,
    required this.pendapatanTahunIni,
    required this.transaksiTahunIni,
    required this.grafikBulanan,
    required this.grafikMingguan,
    required this.detailHariIni,
    required this.detailMingguIni,
    required this.detailBulanIni,
    required this.detailTahunIni,
  });
}

// ─── DATA ────────────────────────────────────────────────────────────────────
const _detailHariIni = [
  DetailTransaksi(
    id: 't1',
    nama: 'Nasi Goreng Spesial',
    kategori: 'Makanan',
    jumlah: 3,
    harga: 18000,
    waktu: '08:12',
    inisial: 'NGS',
  ),
  DetailTransaksi(
    id: 't2',
    nama: 'Kopi Hitam',
    kategori: 'Minuman',
    jumlah: 5,
    harga: 8000,
    waktu: '08:30',
    inisial: 'KH',
  ),
  DetailTransaksi(
    id: 't3',
    nama: 'Meja 1 — PS4',
    kategori: 'Reguler',
    jumlah: 2,
    harga: 10000,
    waktu: '09:00',
    inisial: 'R1',
  ),
  DetailTransaksi(
    id: 't4',
    nama: 'Suite 3',
    kategori: 'Suite Room',
    jumlah: 1,
    harga: 25000,
    waktu: '09:45',
    inisial: 'S3',
  ),
  DetailTransaksi(
    id: 't5',
    nama: 'Matcha Latte',
    kategori: 'Minuman',
    jumlah: 2,
    harga: 18000,
    waktu: '10:15',
    inisial: 'ML',
  ),
  DetailTransaksi(
    id: 't6',
    nama: 'Ayam Geprek',
    kategori: 'Makanan',
    jumlah: 2,
    harga: 20000,
    waktu: '11:00',
    inisial: 'AG',
  ),
  DetailTransaksi(
    id: 't7',
    nama: 'Meja Simulator Racing',
    kategori: 'Reguler',
    jumlah: 1,
    harga: 27000,
    waktu: '11:30',
    inisial: 'SR',
  ),
];

const _detailMingguIni = [
  DetailTransaksi(
    id: 'w1',
    nama: 'Nasi Goreng Spesial',
    kategori: 'Makanan',
    jumlah: 18,
    harga: 18000,
    waktu: 'Sen-Min',
    inisial: 'NGS',
  ),
  DetailTransaksi(
    id: 'w2',
    nama: 'Boba Brown Sugar',
    kategori: 'Minuman',
    jumlah: 24,
    harga: 20000,
    waktu: 'Sen-Min',
    inisial: 'BBS',
  ),
  DetailTransaksi(
    id: 'w3',
    nama: 'Suite 4 — PS5',
    kategori: 'Suite Room',
    jumlah: 7,
    harga: 25000,
    waktu: 'Sen-Min',
    inisial: 'S4',
  ),
  DetailTransaksi(
    id: 'w4',
    nama: 'Meja 4 — PS4 Pro',
    kategori: 'Reguler',
    jumlah: 14,
    harga: 12000,
    waktu: 'Sen-Min',
    inisial: 'R4',
  ),
  DetailTransaksi(
    id: 'w5',
    nama: 'Ayam Geprek',
    kategori: 'Makanan',
    jumlah: 15,
    harga: 20000,
    waktu: 'Sen-Min',
    inisial: 'AG',
  ),
  DetailTransaksi(
    id: 'w6',
    nama: 'VIP Suite 11',
    kategori: 'Suite Room',
    jumlah: 3,
    harga: 40000,
    waktu: 'Sen-Min',
    inisial: 'VIP',
  ),
];

const _detailBulanIni = [
  DetailTransaksi(
    id: 'b1',
    nama: 'Nasi Goreng Spesial',
    kategori: 'Makanan',
    jumlah: 72,
    harga: 18000,
    waktu: 'Mar 2026',
    inisial: 'NGS',
  ),
  DetailTransaksi(
    id: 'b2',
    nama: 'Kopi Hitam',
    kategori: 'Minuman',
    jumlah: 95,
    harga: 8000,
    waktu: 'Mar 2026',
    inisial: 'KH',
  ),
  DetailTransaksi(
    id: 'b3',
    nama: 'Suite 6 — PS5',
    kategori: 'Suite Room',
    jumlah: 28,
    harga: 30000,
    waktu: 'Mar 2026',
    inisial: 'S6',
  ),
  DetailTransaksi(
    id: 'b4',
    nama: 'Meja 1 — PS4',
    kategori: 'Reguler',
    jumlah: 60,
    harga: 10000,
    waktu: 'Mar 2026',
    inisial: 'R1',
  ),
  DetailTransaksi(
    id: 'b5',
    nama: 'Boba Brown Sugar',
    kategori: 'Minuman',
    jumlah: 88,
    harga: 20000,
    waktu: 'Mar 2026',
    inisial: 'BBS',
  ),
  DetailTransaksi(
    id: 'b6',
    nama: 'Meja Simulator Racing',
    kategori: 'Reguler',
    jumlah: 45,
    harga: 27000,
    waktu: 'Mar 2026',
    inisial: 'SR',
  ),
  DetailTransaksi(
    id: 'b7',
    nama: 'VIP Suite 11',
    kategori: 'Suite Room',
    jumlah: 12,
    harga: 40000,
    waktu: 'Mar 2026',
    inisial: 'VIP',
  ),
];

const _detailTahunIni = [
  DetailTransaksi(
    id: 'y1',
    nama: 'Nasi Goreng Spesial',
    kategori: 'Makanan',
    jumlah: 860,
    harga: 18000,
    waktu: '2026',
    inisial: 'NGS',
  ),
  DetailTransaksi(
    id: 'y2',
    nama: 'Boba Brown Sugar',
    kategori: 'Minuman',
    jumlah: 1020,
    harga: 20000,
    waktu: '2026',
    inisial: 'BBS',
  ),
  DetailTransaksi(
    id: 'y3',
    nama: 'Suite 4 — PS5',
    kategori: 'Suite Room',
    jumlah: 320,
    harga: 25000,
    waktu: '2026',
    inisial: 'S4',
  ),
  DetailTransaksi(
    id: 'y4',
    nama: 'Meja 1 — PS4',
    kategori: 'Reguler',
    jumlah: 720,
    harga: 10000,
    waktu: '2026',
    inisial: 'R1',
  ),
  DetailTransaksi(
    id: 'y5',
    nama: 'VIP Suite 11',
    kategori: 'Suite Room',
    jumlah: 145,
    harga: 40000,
    waktu: '2026',
    inisial: 'VIP',
  ),
  DetailTransaksi(
    id: 'y6',
    nama: 'Meja Simulator Racing',
    kategori: 'Reguler',
    jumlah: 540,
    harga: 27000,
    waktu: '2026',
    inisial: 'SR',
  ),
  DetailTransaksi(
    id: 'y7',
    nama: 'Kopi Hitam',
    kategori: 'Minuman',
    jumlah: 1150,
    harga: 8000,
    waktu: '2026',
    inisial: 'KH',
  ),
  DetailTransaksi(
    id: 'y8',
    nama: 'Ayam Geprek',
    kategori: 'Makanan',
    jumlah: 680,
    harga: 20000,
    waktu: '2026',
    inisial: 'AG',
  ),
];

final _rekapPerTahun = {
  2026: RekapData(
    tahun: 2026,
    pendapatanHariIni: 3400000,
    transaksiHariIni: 40,
    pendapatanMingguIni: 18700000,
    transaksiMingguIni: 210,
    pendapatanBulanIni: 74500000,
    transaksiBulanIni: 890,
    pendapatanTahunIni: 187000000,
    transaksiTahunIni: 2340,
    grafikBulanan: [14, 18, 22, 19, 25, 21, 28, 24, 20, 26, 30, 0],
    grafikMingguan: [40, 62, 75, 50, 90, 65, 80],
    detailHariIni: _detailHariIni,
    detailMingguIni: _detailMingguIni,
    detailBulanIni: _detailBulanIni,
    detailTahunIni: _detailTahunIni,
  ),
  2025: RekapData(
    tahun: 2025,
    pendapatanHariIni: 0,
    transaksiHariIni: 0,
    pendapatanMingguIni: 0,
    transaksiMingguIni: 0,
    pendapatanBulanIni: 0,
    transaksiBulanIni: 0,
    pendapatanTahunIni: 156000000,
    transaksiTahunIni: 1980,
    grafikBulanan: [12, 15, 18, 16, 20, 18, 22, 20, 17, 21, 24, 25],
    grafikMingguan: [35, 55, 60, 45, 75, 58, 70],
    detailHariIni: [],
    detailMingguIni: [],
    detailBulanIni: [],
    detailTahunIni: _detailTahunIni,
  ),
  2024: RekapData(
    tahun: 2024,
    pendapatanHariIni: 0,
    transaksiHariIni: 0,
    pendapatanMingguIni: 0,
    transaksiMingguIni: 0,
    pendapatanBulanIni: 0,
    transaksiBulanIni: 0,
    pendapatanTahunIni: 128000000,
    transaksiTahunIni: 1620,
    grafikBulanan: [10, 12, 14, 13, 16, 15, 18, 16, 14, 17, 19, 20],
    grafikMingguan: [28, 42, 50, 38, 62, 48, 55],
    detailHariIni: [],
    detailMingguIni: [],
    detailBulanIni: [],
    detailTahunIni: _detailTahunIni,
  ),
};

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class RekapOwnerScreen extends StatefulWidget {
  const RekapOwnerScreen({super.key});
  @override
  State<RekapOwnerScreen> createState() => _RekapOwnerScreenState();
}

class _RekapOwnerScreenState extends State<RekapOwnerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;

  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  final List<int> _tahunList = [
    2024,
    2025,
    2026,
  ]; // ascending biar swipe kanan = lebih baru
  int _selectedTahun = 2026;
  late PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: 2); // 2026 ada di index 2
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollCtrl.addListener(
      () => setState(() => _scrollOffset = _scrollCtrl.offset),
    );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _changeTahun(int tahun) {
    final idx = _tahunList.indexOf(tahun);
    setState(() => _selectedTahun = tahun);
    _pageCtrl.animateToPage(
      idx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _showDetail(
    BuildContext context,
    String judul,
    Color color,
    List<DetailTransaksi> list,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _DetailBottomSheet(judul: judul, color: color, list: list),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
          Expanded(
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _tahunList.length,
              onPageChanged: (i) =>
                  setState(() => _selectedTahun = _tahunList[i]),
              itemBuilder: (ctx, i) =>
                  _buildKonten(ctx, _rekapPerTahun[_tahunList[i]]!),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────
  Widget _buildHeader() {
    final p = _collapseProgress;
    final double eSize = 24 - (24 - 14) * p;
    final double xSize = 40 - (40 - 22) * p;
    final double oticSize = 24 - (24 - 14) * p;
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
              children: [
                TextSpan(
                  text: 'E',
                  style: TextStyle(
                    fontSize: eSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(
                    fontSize: xSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: 'OTIC',
                  style: TextStyle(
                    fontSize: oticSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _tahunArrow(Icons.chevron_left, () {
            // kiri = tahun lebih lama = index lebih kecil
            final idx = _tahunList.indexOf(_selectedTahun);
            if (idx > 0) _changeTahun(_tahunList[idx - 1]);
          }),
          const SizedBox(width: 10),
          Text(
            '$_selectedTahun',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: kWhite,
            ),
          ),
          const SizedBox(width: 10),
          _tahunArrow(Icons.chevron_right, () {
            // kanan = tahun lebih baru = index lebih besar
            final idx = _tahunList.indexOf(_selectedTahun);
            if (idx < _tahunList.length - 1) _changeTahun(_tahunList[idx + 1]);
          }),
        ],
      ),
    );
  }

  Widget _tahunArrow(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: kWhite, size: 20),
      ),
    );
  }

  // ─── KONTEN PER TAHUN ────────────────────────────────────────
  Widget _buildKonten(BuildContext context, RekapData data) {
    final isTahunIni = data.tahun == 2026;
    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90D9), kBlue],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: kBlue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'REKAP TAHUN ${data.tahun}',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          if (isTahunIni) ...[
            _sectionLabel('📅 HARI INI', kBlue),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '💰',
                    'PENDAPATAN',
                    _formatRupiah(data.pendapatanHariIni),
                    kBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    '🧾',
                    'TRANSAKSI',
                    '${data.transaksiHariIni}x',
                    kBlueBg,
                    onTap: () => _showDetail(
                      context,
                      'Transaksi Hari Ini',
                      kBlue,
                      data.detailHariIni,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _miniBarChart(
              data.grafikMingguan,
              ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
              kBlue,
              'Grafik 7 Hari Terakhir',
            ),
            const SizedBox(height: 20),
          ],

          if (isTahunIni) ...[
            _sectionLabel('📆 MINGGU INI', kGreen),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '💰',
                    'PENDAPATAN',
                    _formatRupiah(data.pendapatanMingguIni),
                    kGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    '🧾',
                    'TRANSAKSI',
                    '${data.transaksiMingguIni}x',
                    kGreen,
                    onTap: () => _showDetail(
                      context,
                      'Transaksi Minggu Ini',
                      kGreen,
                      data.detailMingguIni,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          if (isTahunIni) ...[
            _sectionLabel('🗓️ BULAN INI', kOrange),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    '💰',
                    'PENDAPATAN',
                    _formatRupiah(data.pendapatanBulanIni),
                    kOrange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    '🧾',
                    'TRANSAKSI',
                    '${data.transaksiBulanIni}x',
                    kOrange,
                    onTap: () => _showDetail(
                      context,
                      'Transaksi Bulan Ini',
                      kOrange,
                      data.detailBulanIni,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          _sectionLabel('📊 TAHUN ${data.tahun}', kPurple),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _statCard(
                  '💰',
                  'TOTAL PENDAPATAN',
                  _formatRupiah(data.pendapatanTahunIni),
                  kPurple,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  '🧾',
                  'TOTAL TRANSAKSI',
                  '${data.transaksiTahunIni}x',
                  kPurple,
                  onTap: () => _showDetail(
                    context,
                    'Transaksi Tahun ${data.tahun}',
                    kPurple,
                    data.detailTahunIni,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _grafikTahunan(data.grafikBulanan, data.tahun),
          const SizedBox(height: 20),

          _sectionLabel('📈 PERBANDINGAN TAHUN', kGold),
          const SizedBox(height: 10),
          _perbandinganCard(),
        ],
      ),
    );
  }

  // ─── SECTION LABEL ───────────────────────────────────────────
  Widget _sectionLabel(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kTextDark,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ─── STAT CARD ───────────────────────────────────────────────
  Widget _statCard(
    String emoji,
    String label,
    String value,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: onTap != null
              ? Border.all(color: color.withOpacity(0.2), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                if (onTap != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'DETAIL',
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward, size: 10, color: color),
                      ],
                    ),
                  )
                else
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── MINI BAR CHART ──────────────────────────────────────────
  Widget _miniBarChart(
    List<int> values,
    List<String> labels,
    Color color,
    String title,
  ) {
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height:
                90, // ← fix overflow: cukup untuk bar(60) + space(5) + text(~12) + padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (i) {
                final h = maxVal > 0
                    ? (values[i] / maxVal) * 60
                    : 0.0; // ← max bar 60px
                final isMax =
                    values[i] == values.reduce((a, b) => a > b ? a : b);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 50),
                          curve: Curves.easeOut,
                          height: h,
                          decoration: BoxDecoration(
                            color: isMax ? color : color.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          labels[i],
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── GRAFIK TAHUNAN ──────────────────────────────────────────
  Widget _grafikTahunan(List<int> values, int tahun) {
    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PENDAPATAN BULANAN $tahun',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: kWhiteDim,
                  letterSpacing: 1,
                ),
              ),
              Text(
                _formatRupiah(values.reduce((a, b) => a + b) * 1000000),
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height:
                110, // ← cukup untuk bar(80) + space(6) + text(~12) + padding
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final h = maxVal > 0 ? (values[i] / maxVal) * 80 : 0.0;
                final isMax =
                    values[i] == values.reduce((a, b) => a > b ? a : b);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 40),
                          curve: Curves.easeOut,
                          height: h,
                          decoration: BoxDecoration(
                            color: kWhite.withOpacity(isMax ? 1.0 : 0.35),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          months[i],
                          style: GoogleFonts.lato(
                            fontSize: 8,
                            color: kWhiteDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── PERBANDINGAN CARD ───────────────────────────────────────
  Widget _perbandinganCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: _tahunList.map((tahun) {
          final data = _rekapPerTahun[tahun]!;
          final maxP = _rekapPerTahun[_tahunList.first]!.pendapatanTahunIni
              .toDouble();
          final ratio = maxP > 0 ? data.pendapatanTahunIni / maxP : 0.0;
          final isSelected = tahun == _selectedTahun;
          return GestureDetector(
            onTap: () => _changeTahun(tahun),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? kBlue : kBgLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$tahun',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? kWhite : Colors.black45,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 10,
                            backgroundColor: kBgLight,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isSelected ? kBlue : kBlue.withOpacity(0.4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(data.pendapatanTahunIni),
                          style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? kTextDark : Colors.black38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatRupiah(int amount) {
    if (amount >= 1000000000)
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)} M';
    if (amount >= 1000000)
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    return 'Rp $amount';
  }
}

// ─── DETAIL BOTTOM SHEET ─────────────────────────────────────────────────────
class _DetailBottomSheet extends StatelessWidget {
  final String judul;
  final Color color;
  final List<DetailTransaksi> list;

  const _DetailBottomSheet({
    required this.judul,
    required this.color,
    required this.list,
  });

  String _formatRupiah(int amount) {
    if (amount >= 1000000)
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)} jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)} rb';
    return 'Rp $amount';
  }

  Color _kategoriColor(String kat) {
    switch (kat) {
      case 'Makanan':
        return kOrange;
      case 'Minuman':
        return kBlueBg;
      case 'Reguler':
        return kPurple;
      case 'Suite Room':
        return kGold;
      default:
        return kBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPendapatan = list.fold(0, (sum, t) => sum + t.total);
    final totalItem = list.fold(0, (sum, t) => sum + t.jumlah);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${list.length} jenis menu  •  $totalItem item terjual',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: kWhite.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'TOTAL',
                      style: GoogleFonts.lato(
                        fontSize: 9,
                        color: kWhite.withOpacity(0.7),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _formatRupiah(totalPendapatan),
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: kWhite,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada data',
                      style: GoogleFonts.lato(color: Colors.black38),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final t = list[i];
                      final katColor = _kategoriColor(t.kategori);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kWhite,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Inisial
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: katColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  t.inisial,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: katColor,
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
                                    t.nama,
                                    style: GoogleFonts.lato(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: kTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: katColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          t.kategori,
                                          style: GoogleFonts.lato(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: katColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${t.jumlah}x • ${t.waktu}',
                                        style: GoogleFonts.lato(
                                          fontSize: 10,
                                          color: Colors.black38,
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
                                Text(
                                  _formatRupiah(t.total),
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: color,
                                  ),
                                ),
                                Text(
                                  '@${_formatRupiah(t.harga)}',
                                  style: GoogleFonts.lato(
                                    fontSize: 9,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
