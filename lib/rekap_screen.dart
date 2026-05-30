import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ==================== WARNA ====================
const kBlue = Color(0xFF1A5EBF);
const kBlueDark = Color(0xFF0F3B8C);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF9800);
const kPurple = Color(0xFF7C4DFF);
const kBgLight = Color(0xFFF0F4FF);

// -------------------- MODEL (sama seperti awal) --------------------
enum StatusKehadiran { hadir, izin, sakit, alpha, cuti, belum }

enum ShiftKerja { pagi, siang, malam }

class Karyawan {
  final int id;
  final String nama;
  final String jabatan;
  final Color avatarColor;
  final int gajiPokok;
  const Karyawan(
      {required this.id,
      required this.nama,
      required this.jabatan,
      required this.avatarColor,
      required this.gajiPokok});
  String get initial => nama.isNotEmpty ? nama[0].toUpperCase() : '?';
}

class AbsensiHarian {
  final int karyawanId;
  final DateTime tanggal;
  final StatusKehadiran status;
  final ShiftKerja shift;
  final TimeOfDay? jamMasuk;
  final TimeOfDay? jamKeluar;
  final int totalTransaksi;
  final int omzetHari;
  AbsensiHarian({
    required this.karyawanId,
    required this.tanggal,
    required this.status,
    required this.shift,
    this.jamMasuk,
    this.jamKeluar,
    this.totalTransaksi = 0,
    this.omzetHari = 0,
  });
  bool get terlambat {
    if (jamMasuk == null) return false;
    final batas = shift == ShiftKerja.pagi
        ? const TimeOfDay(hour: 8, minute: 15)
        : shift == ShiftKerja.siang
            ? const TimeOfDay(hour: 13, minute: 15)
            : const TimeOfDay(hour: 18, minute: 15);
    return jamMasuk!.hour > batas.hour ||
        (jamMasuk!.hour == batas.hour && jamMasuk!.minute > batas.minute);
  }
}

final List<Karyawan> defaultKaryawan = [
  Karyawan(
      id: 1,
      nama: 'Freya Fauna',
      jabatan: 'Kasir',
      avatarColor: Color(0xFF2255B0),
      gajiPokok: 2500000),
  Karyawan(
      id: 2,
      nama: 'Zaki Ramadan',
      jabatan: 'Barista',
      avatarColor: Color(0xFF6530C8),
      gajiPokok: 2800000),
  Karyawan(
      id: 3,
      nama: 'Anna Kusuma',
      jabatan: 'Pelayan',
      avatarColor: Color(0xFF149650),
      gajiPokok: 2300000),
  Karyawan(
      id: 4,
      nama: 'Ridwan Saputra',
      jabatan: 'Operator',
      avatarColor: Color(0xFFE66414),
      gajiPokok: 2600000),
  Karyawan(
      id: 5,
      nama: 'Mingyu Park',
      jabatan: 'Kasir',
      avatarColor: Color(0xFFB91C1C),
      gajiPokok: 2500000),
  Karyawan(
      id: 6,
      nama: 'Annsa Kuat',
      jabatan: 'Barista',
      avatarColor: Color(0xFF0E7490),
      gajiPokok: 2800000),
];

List<AbsensiHarian> generateAbsensi(int tahun, int bulan) {
  final jumlahHari = DateUtils.getDaysInMonth(tahun, bulan);
  final shifts = [ShiftKerja.pagi, ShiftKerja.siang, ShiftKerja.malam];
  final result = <AbsensiHarian>[];
  final polaPerId = {
    1: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.izin,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir
    ],
    2: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.sakit,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.alpha
    ],
    3: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.izin,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.cuti,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir
    ],
    4: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.alpha,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.sakit,
      StatusKehadiran.hadir
    ],
    5: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.izin,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir
    ],
    6: [
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.sakit,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir,
      StatusKehadiran.alpha,
      StatusKehadiran.hadir,
      StatusKehadiran.hadir
    ],
  };
  for (int hari = 1; hari <= jumlahHari; hari++) {
    final tgl = DateTime(tahun, bulan, hari);
    if (tgl.weekday == DateTime.sunday) continue;
    for (final k in defaultKaryawan) {
      final pola = polaPerId[k.id]!;
      final st = pola[(hari - 1) % pola.length];
      final shift = shifts[(k.id + hari) % 3];
      TimeOfDay? jamMasuk;
      TimeOfDay? jamKeluar;
      int transaksi = 0;
      int omzet = 0;
      if (st == StatusKehadiran.hadir) {
        final terlambat = (k.id + hari) % 7 == 0;
        switch (shift) {
          case ShiftKerja.pagi:
            jamMasuk = TimeOfDay(hour: 7, minute: terlambat ? 45 : 55);
            jamKeluar = const TimeOfDay(hour: 14, minute: 0);
            break;
          case ShiftKerja.siang:
            jamMasuk = TimeOfDay(hour: 12, minute: terlambat ? 30 : 58);
            jamKeluar = const TimeOfDay(hour: 19, minute: 0);
            break;
          case ShiftKerja.malam:
            jamMasuk = TimeOfDay(hour: 17, minute: terlambat ? 25 : 55);
            jamKeluar = const TimeOfDay(hour: 23, minute: 0);
            break;
        }
        transaksi = 5 + (k.id * 3 + hari * 2) % 18;
        omzet = 60000 + (k.id * 40000 + hari * 25000) % 280000;
      }
      result.add(AbsensiHarian(
        karyawanId: k.id,
        tanggal: tgl,
        status: st,
        shift: shift,
        jamMasuk: jamMasuk,
        jamKeluar: jamKeluar,
        totalTransaksi: transaksi,
        omzetHari: omzet,
      ));
    }
  }
  return result;
}

// -------------------- REKAP SCREEN (gabungan dummy absensi + real transaksi) --------------------
class RekapScreen extends StatefulWidget {
  final String role;
  const RekapScreen({super.key, required this.role});
  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  late int _bulan;
  late int _tahun;
  int? _detailKarId;
  late List<AbsensiHarian> _absensi;

  final _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];
  final _hariSingkat = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;
  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _bulan = now.month;
    _tahun = now.year;
    _absensi = generateAbsensi(_tahun, _bulan);
    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _prevBulan() => setState(() {
        if (_bulan == 1) {
          _bulan = 12;
          _tahun--;
        } else
          _bulan--;
        _absensi = generateAbsensi(_tahun, _bulan);
        _detailKarId = null;
      });
  void _nextBulan() => setState(() {
        final now = DateTime.now();
        if (_tahun == now.year && _bulan == now.month) return;
        if (_bulan == 12) {
          _bulan = 1;
          _tahun++;
        } else
          _bulan++;
        _absensi = generateAbsensi(_tahun, _bulan);
        _detailKarId = null;
      });

  List<AbsensiHarian> _absensiKar(int id) =>
      _absensi.where((a) => a.karyawanId == id).toList()
        ..sort((a, b) => a.tanggal.compareTo(b.tanggal));
  int _hadir(int id) =>
      _absensiKar(id).where((a) => a.status == StatusKehadiran.hadir).length;
  int _alpha(int id) =>
      _absensiKar(id).where((a) => a.status == StatusKehadiran.alpha).length;
  int _izin(int id) =>
      _absensiKar(id).where((a) => a.status == StatusKehadiran.izin).length;
  int _sakit(int id) =>
      _absensiKar(id).where((a) => a.status == StatusKehadiran.sakit).length;
  int _cuti(int id) =>
      _absensiKar(id).where((a) => a.status == StatusKehadiran.cuti).length;
  int _totalHari(int id) => _absensiKar(id).length;
  double _persen(int id) =>
      _totalHari(id) == 0 ? 0 : _hadir(id) / _totalHari(id);
  bool _terlambat(AbsensiHarian a) => a.terlambat;
  int _terlambatCount(int id) => _absensiKar(id).where(_terlambat).length;
  int _omzetKar(int id) => _absensiKar(id).fold(0, (s, a) => s + a.omzetHari);
  int _transaksiKar(int id) =>
      _absensiKar(id).fold(0, (s, a) => s + a.totalTransaksi);
  int _gajiKar(int id) {
    final t = _totalHari(id);
    if (t == 0) return 0;
    final k = defaultKaryawan.firstWhere((k) => k.id == id);
    return (k.gajiPokok * _hadir(id) / t).round();
  }

  String _fmtRp(int v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }

  String _fmtJam(TimeOfDay? t) => t == null
      ? '--:--'
      : '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
  Color _statusColor(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:
        return kGreen;
      case StatusKehadiran.izin:
        return kOrange;
      case StatusKehadiran.sakit:
        return kPurple;
      case StatusKehadiran.alpha:
        return kRed;
      case StatusKehadiran.cuti:
        return kBlueDark;
      default:
        return Colors.black38;
    }
  }

  String _statusLabel(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:
        return 'Hadir';
      case StatusKehadiran.izin:
        return 'Izin';
      case StatusKehadiran.sakit:
        return 'Sakit';
      case StatusKehadiran.alpha:
        return 'Alpha';
      case StatusKehadiran.cuti:
        return 'Cuti';
      default:
        return 'Belum';
    }
  }

  String _statusHuruf(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:
        return 'H';
      case StatusKehadiran.izin:
        return 'I';
      case StatusKehadiran.sakit:
        return 'S';
      case StatusKehadiran.alpha:
        return 'A';
      case StatusKehadiran.cuti:
        return 'C';
      default:
        return '?';
    }
  }

  String _shiftLabel(ShiftKerja s) {
    switch (s) {
      case ShiftKerja.pagi:
        return 'Pagi';
      case ShiftKerja.siang:
        return 'Siang';
      case ShiftKerja.malam:
        return 'Malam';
    }
  }

  // =============== AMBIL SEMUA TRANSAKSI (tanpa filter bulan) ===============
  Future<int> _getTotalOmzetFromFirestore() async {
    try {
      final snap =
          await FirebaseFirestore.instance.collection('transaksi').get();
      int total = 0;
      for (var doc in snap.docs) {
        final harga = doc['harga'];
        if (harga is int)
          total += harga;
        else if (harga is double)
          total += harga.toInt();
        else if (harga is num) total += harga.toInt();
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          _buildMonthSelector(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabCtrl,
              children: [
                _detailKarId == null
                    ? _buildKehadiran()
                    : _buildDetailKehadiran(_detailKarId!),
                _detailKarId == null
                    ? _buildPendapatan()
                    : _buildDetailPendapatan(_detailKarId!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final p = _collapseProgress;
    final double eSize = 24 - (24 - 14) * p;
    final double xSize = 40 - (40 - 22) * p;
    final double oticSize = 24 - (24 - 14) * p;
    final double subSize = 11 - (11 - 9) * p;
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;
    final double subOpacity = (1 - p * 2).clamp(0.0, 1.0);

    final logoWidget = RichText(
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
        children: [
          TextSpan(
              text: 'E',
              style: TextStyle(fontSize: eSize, fontWeight: FontWeight.w400)),
          TextSpan(
              text: 'X',
              style: TextStyle(fontSize: xSize, fontWeight: FontWeight.w700)),
          TextSpan(
              text: 'OTIC',
              style:
                  TextStyle(fontSize: oticSize, fontWeight: FontWeight.w400)),
        ],
      ),
    );

    final subWidget = Text('GAMING & CAFE',
        style: GoogleFonts.playfairDisplay(
            fontSize: subSize,
            color: kWhiteDim,
            letterSpacing: 3,
            fontWeight: FontWeight.w400));

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: p < 0.5
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                logoWidget,
                const SizedBox(width: 6),
                Opacity(opacity: subOpacity, child: subWidget),
                const Spacer(),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(_detailKarId == null ? 'REKAP' : 'DETAIL',
                        style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: kWhite))),
              ]),
            ])
          : Row(children: [
              logoWidget,
              const SizedBox(width: 8),
              subWidget,
              const Spacer(),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_detailKarId == null ? 'REKAP' : 'DETAIL',
                      style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: kWhite))),
            ]),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrent = _bulan == now.month && _tahun == now.year;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
              onTap: _prevBulan,
              child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: kBlue, size: 20))),
          const SizedBox(width: 12),
          Expanded(
              child: Center(
                  child: Text('${_namaBulan[_bulan]} $_tahun',
                      style: GoogleFonts.lato(
                          color: kTextDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          GestureDetector(
              onTap: isCurrent ? null : _nextBulan,
              child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ]),
                  child: Icon(Icons.chevron_right_rounded,
                      color: isCurrent ? Colors.grey.shade300 : kBlue,
                      size: 20))),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        tabs: const [Tab(text: 'KEHADIRAN'), Tab(text: 'PENDAPATAN')],
      ),
    );
  }

  // ==================== TAB KEHADIRAN (dummy) ====================
  Widget _buildKehadiran() {
    final totalHadirAll = defaultKaryawan.fold(0, (s, k) => s + _hadir(k.id));
    final totalHariAll =
        defaultKaryawan.fold(0, (s, k) => s + _totalHari(k.id));

    return SingleChildScrollView(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]),
            child: Column(
              children: [
                Text('Tingkat Kehadiran Bulan Ini',
                    style: GoogleFonts.lato(
                        color: kTextDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(children: [
                  Text(
                      totalHariAll == 0
                          ? '0%'
                          : '${(totalHadirAll / totalHariAll * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.lato(
                          color: kGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(children: [
                    Text('$totalHadirAll dari $totalHariAll total hari kerja',
                        style: GoogleFonts.lato(
                            color: Colors.black45, fontSize: 12)),
                    const SizedBox(height: 6),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                            value: totalHariAll == 0
                                ? 0
                                : totalHadirAll / totalHariAll,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kGreen))),
                  ])),
                ]),
                const SizedBox(height: 10),
                Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      StatusKehadiran.hadir,
                      StatusKehadiran.izin,
                      StatusKehadiran.sakit,
                      StatusKehadiran.alpha,
                      StatusKehadiran.cuti,
                    ]
                        .map((s) =>
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: _statusColor(s),
                                      shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              Text(_statusLabel(s),
                                  style: GoogleFonts.lato(
                                      color: Colors.black45, fontSize: 11)),
                            ]))
                        .toList()),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
                color: kBlue, borderRadius: BorderRadius.circular(12)),
            child: Row(children: const [
              SizedBox(width: 44),
              SizedBox(width: 8),
              Expanded(
                  child: Text('Nama',
                      style: TextStyle(
                          color: kWhiteDim,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
              SizedBox(
                  width: 52,
                  child: Text('Hadir',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
              SizedBox(
                  width: 36,
                  child: Text('Alpha',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
              SizedBox(
                  width: 36,
                  child: Text('Izin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
              SizedBox(
                  width: 36,
                  child: Text('Sakit',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: kPurple,
                          fontSize: 11,
                          fontWeight: FontWeight.w800))),
            ]),
          ),
          const SizedBox(height: 6),
          ...defaultKaryawan.map((k) {
            final hadir = _hadir(k.id);
            final alpha = _alpha(k.id);
            final izin = _izin(k.id);
            final sakit = _sakit(k.id);
            final persen = _persen(k.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => setState(() => _detailKarId = k.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ]),
                  child: Column(children: [
                    Row(children: [
                      Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: k.avatarColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: k.avatarColor.withOpacity(0.3))),
                          child: Center(
                              child: Text(k.initial,
                                  style: TextStyle(
                                      color: k.avatarColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800)))),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(k.nama,
                                style: GoogleFonts.lato(
                                    color: kTextDark,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            Text(k.jabatan,
                                style: GoogleFonts.lato(
                                    color: Colors.black45, fontSize: 11)),
                          ])),
                      SizedBox(
                          width: 52,
                          child: Text('$hadir hari',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: persen >= 0.8 ? kGreen : kOrange,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800))),
                      SizedBox(
                          width: 36,
                          child: Text('$alpha',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: alpha > 0 ? kRed : Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700))),
                      SizedBox(
                          width: 36,
                          child: Text('$izin',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: izin > 0 ? kOrange : Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700))),
                      SizedBox(
                          width: 36,
                          child: Text('$sakit',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(
                                  color: sakit > 0 ? kPurple : Colors.black45,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700))),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                  value: persen,
                                  minHeight: 5,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      persen >= 0.8 ? kGreen : kOrange)))),
                      const SizedBox(width: 8),
                      Text('${(persen * 100).toStringAsFixed(0)}%',
                          style: GoogleFonts.lato(
                              color: persen >= 0.8 ? kGreen : kOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.grey, size: 16),
                    ]),
                  ]),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailKehadiran(int karId) {
    final k = defaultKaryawan.firstWhere((k) => k.id == karId);
    final rekap = _absensiKar(karId);
    final hadir = _hadir(karId);
    final totalHari = _totalHari(karId);
    final persen = _persen(karId);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: kWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Row(children: [
            Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: k.avatarColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: k.avatarColor, width: 2)),
                child: Center(
                    child: Text(k.initial,
                        style: TextStyle(
                            color: k.avatarColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w800)))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(k.nama,
                      style: GoogleFonts.lato(
                          color: kTextDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  Text(k.jabatan,
                      style: GoogleFonts.lato(
                          color: Colors.black45, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${_namaBulan[_bulan]} $_tahun',
                      style: TextStyle(
                          color: k.avatarColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                ])),
            Column(children: [
              Text('${(persen * 100).toStringAsFixed(1)}%',
                  style: GoogleFonts.lato(
                      color: persen >= 0.8 ? kGreen : kOrange,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1)),
              Text('kehadiran',
                  style: GoogleFonts.lato(
                      color: persen >= 0.8 ? kGreen : kOrange, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        ...rekap.map((a) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ]),
              child: Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                      color: _statusColor(a.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('${a.tanggal.day}',
                            style: TextStyle(
                                color: _statusColor(a.status),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                height: 1)),
                        Text(_hariSingkat[a.tanggal.weekday % 7],
                            style: TextStyle(
                                color: _statusColor(a.status).withOpacity(0.7),
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Row(children: [
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: _statusColor(a.status).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text(_statusLabel(a.status),
                                style: GoogleFonts.lato(
                                    color: _statusColor(a.status),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700))),
                        const SizedBox(width: 6),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(6)),
                            child: Text('Shift ${_shiftLabel(a.shift)}',
                                style: GoogleFonts.lato(
                                    color: Colors.black45,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600))),
                        if (a.terlambat) ...[
                          const SizedBox(width: 6),
                          Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text('Terlambat',
                                  style: GoogleFonts.lato(
                                      color: kOrange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700))),
                        ],
                      ]),
                      const SizedBox(height: 3),
                      Text(
                          'Masuk: ${_fmtJam(a.jamMasuk)}  ·  Keluar: ${_fmtJam(a.jamKeluar)}',
                          style: GoogleFonts.lato(
                              color: Colors.black45, fontSize: 11)),
                    ])),
                if (a.status == StatusKehadiran.hadir)
                  Text('${a.totalTransaksi} trx',
                      style: GoogleFonts.lato(
                          color: kBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
              ]),
            )),
      ]),
    );
  }

  // ==================== TAB PENDAPATAN (semua transaksi dari Firestore) ====================
  Widget _buildPendapatan() {
    return FutureBuilder<int>(
      future: _getTotalOmzetFromFirestore(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final total = snapshot.data ?? 0;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Total Pendapatan (Semua Transaksi)',
                  style: GoogleFonts.lato(fontSize: 16, color: Colors.black45)),
              const SizedBox(height: 8),
              Text(_fmtRp(total),
                  style: GoogleFonts.lato(
                      fontSize: 32, fontWeight: FontWeight.w900, color: kBlue)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailPendapatan(int karId) {
    return const Center(
        child: Text('Detail pendapatan belum diimplementasikan',
            style: TextStyle(fontSize: 14)));
  }
}
