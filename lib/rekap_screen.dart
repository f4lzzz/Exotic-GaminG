import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// MODEL — karyawan.dart
// ═══════════════════════════════════════════════════════════════

enum StatusKehadiran { hadir, izin, sakit, alpha, cuti }
enum ShiftKerja { pagi, siang, malam }

class Karyawan {
  final int id;
  final String nama;
  final String jabatan;
  final Color avatarColor;
  final int gajiPokok;

  const Karyawan({
    required this.id,
    required this.nama,
    required this.jabatan,
    required this.avatarColor,
    required this.gajiPokok,
  });

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
  Karyawan(id: 1, nama: 'Freya Fauna',    jabatan: 'Kasir',    avatarColor: Color(0xFF2255B0), gajiPokok: 2500000),
  Karyawan(id: 2, nama: 'Zaki Ramadan',   jabatan: 'Barista',  avatarColor: Color(0xFF6530C8), gajiPokok: 2800000),
  Karyawan(id: 3, nama: 'Anna Kusuma',    jabatan: 'Pelayan',  avatarColor: Color(0xFF149650), gajiPokok: 2300000),
  Karyawan(id: 4, nama: 'Ridwan Saputra', jabatan: 'Operator', avatarColor: Color(0xFFE66414), gajiPokok: 2600000),
  Karyawan(id: 5, nama: 'Mingyu Park',    jabatan: 'Kasir',    avatarColor: Color(0xFFB91C1C), gajiPokok: 2500000),
  Karyawan(id: 6, nama: 'Annsa Kuat',     jabatan: 'Barista',  avatarColor: Color(0xFF0E7490), gajiPokok: 2800000),
];

List<AbsensiHarian> generateAbsensi(int tahun, int bulan) {
  final jumlahHari = DateUtils.getDaysInMonth(tahun, bulan);
  final shifts = [ShiftKerja.pagi, ShiftKerja.siang, ShiftKerja.malam];
  final result = <AbsensiHarian>[];

  final polaPerId = {
    1: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.izin,  StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir],
    2: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.sakit, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.alpha],
    3: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.izin,  StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.cuti,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir],
    4: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.alpha,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.sakit, StatusKehadiran.hadir],
    5: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.izin,  StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir],
    6: [StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.sakit,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.hadir, StatusKehadiran.hadir, StatusKehadiran.hadir,
        StatusKehadiran.alpha, StatusKehadiran.hadir, StatusKehadiran.hadir],
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
          case ShiftKerja.siang:
            jamMasuk = TimeOfDay(hour: 12, minute: terlambat ? 30 : 58);
            jamKeluar = const TimeOfDay(hour: 19, minute: 0);
          case ShiftKerja.malam:
            jamMasuk = TimeOfDay(hour: 17, minute: terlambat ? 25 : 55);
            jamKeluar = const TimeOfDay(hour: 23, minute: 0);
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

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGETS — shared_widgets.dart (hanya yang dipakai Rekap)
// ═══════════════════════════════════════════════════════════════

const kBgDark       = Color(0xFFCDE0F5);
const kBlueDark     = Color(0xFF1A3A6B);
const kBlue         = Color(0xFF2255B0);
const kBlueBorder   = Color(0xFF3A6DD4);
const kBlueAccent   = Color(0xFF1A3A6B);
const kGreen        = Color(0xFF1A7A4A);
const kOrange       = Color(0xFFB86A00);
const kRed          = Color(0xFFCC3333);
const kWhite55      = Color(0xFF3A5070);
const kWhite30      = Color(0xFF7A9ABB);
const kWhite10      = Color(0xFFB0C8E0);
const kWhite07      = Color(0xFFEAF2FB);

// ═══════════════════════════════════════════════════════════════
// REKAP SCREEN
// ═══════════════════════════════════════════════════════════════

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
  late List<AbsensiHarian> _absensi;
  int? _detailKarId;

  final _namaBulan = ['','Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember'];
  final _hariSingkat = ['Min','Sen','Sel','Rab','Kam','Jum','Sab'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    final now = DateTime.now();
    _bulan = now.month;
    _tahun = now.year;
    _absensi = generateAbsensi(_tahun, _bulan);
  }

  @override
  void dispose() { _tabCtrl.dispose(); super.dispose(); }

  bool get isOwner => widget.role == 'owner';

  void _prevBulan() => setState(() {
    if (_bulan == 1) { _bulan = 12; _tahun--; } else _bulan--;
    _absensi = generateAbsensi(_tahun, _bulan);
    _detailKarId = null;
  });

  void _nextBulan() => setState(() {
    final now = DateTime.now();
    if (_tahun == now.year && _bulan == now.month) return;
    if (_bulan == 12) { _bulan = 1; _tahun++; } else _bulan++;
    _absensi = generateAbsensi(_tahun, _bulan);
    _detailKarId = null;
  });

  List<AbsensiHarian> _absensiKar(int id) =>
      _absensi.where((a) => a.karyawanId == id).toList()
        ..sort((a, b) => a.tanggal.compareTo(b.tanggal));

  int _hadir(int id)  => _absensiKar(id).where((a) => a.status == StatusKehadiran.hadir).length;
  int _alpha(int id)  => _absensiKar(id).where((a) => a.status == StatusKehadiran.alpha).length;
  int _izin(int id)   => _absensiKar(id).where((a) => a.status == StatusKehadiran.izin).length;
  int _sakit(int id)  => _absensiKar(id).where((a) => a.status == StatusKehadiran.sakit).length;
  int _cuti(int id)   => _absensiKar(id).where((a) => a.status == StatusKehadiran.cuti).length;
  int _totalHari(int id) => _absensiKar(id).length;
  double _persen(int id) {
    final t = _totalHari(id);
    return t == 0 ? 0 : _hadir(id) / t;
  }
  bool _terlambat(AbsensiHarian a) => a.terlambat;
  int _terlambatCount(int id) => _absensiKar(id).where(_terlambat).length;

  int _omzetKar(int id)     => _absensiKar(id).fold(0, (s, a) => s + a.omzetHari);
  int _transaksiKar(int id) => _absensiKar(id).fold(0, (s, a) => s + a.totalTransaksi);
  int _gajiKar(int id) {
    final t = _totalHari(id);
    if (t == 0) return 0;
    final k = defaultKaryawan.firstWhere((k) => k.id == id);
    return (k.gajiPokok * _hadir(id) / t).round();
  }

  int get _totalOmzet      => _absensi.fold(0, (s, a) => s + a.omzetHari);
  int get _totalTransaksi  => _absensi.fold(0, (s, a) => s + a.totalTransaksi);
  int get _totalGaji       => defaultKaryawan.fold(0, (s, k) => s + _gajiKar(k.id));
  int get _profit          => _totalOmzet - _totalGaji;

  String _fmtRp(int v) {
    if (v >= 1000000) return 'Rp ${(v/1000000).toStringAsFixed(1)}jt';
    if (v >= 1000)    return 'Rp ${(v/1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }
  String _fmtJam(TimeOfDay? t) => t == null ? '--:--'
      : '${t.hour.toString().padLeft(2,'0')}.${t.minute.toString().padLeft(2,'0')}';

  Color _statusColor(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:  return kGreen;
      case StatusKehadiran.izin:   return kOrange;
      case StatusKehadiran.sakit:  return kBlueAccent;
      case StatusKehadiran.alpha:  return kRed;
      case StatusKehadiran.cuti:   return kBlueDark;
    }
  }
  String _statusLabel(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:  return 'Hadir';
      case StatusKehadiran.izin:   return 'Izin';
      case StatusKehadiran.sakit:  return 'Sakit';
      case StatusKehadiran.alpha:  return 'Alpha';
      case StatusKehadiran.cuti:   return 'Cuti';
    }
  }
  String _statusHuruf(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir:  return 'H';
      case StatusKehadiran.izin:   return 'I';
      case StatusKehadiran.sakit:  return 'S';
      case StatusKehadiran.alpha:  return 'A';
      case StatusKehadiran.cuti:   return 'C';
    }
  }
  String _shiftLabel(ShiftKerja s) {
    switch (s) {
      case ShiftKerja.pagi:   return 'Pagi';
      case ShiftKerja.siang:  return 'Siang';
      case ShiftKerja.malam:  return 'Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = kBlueDark;
    return Scaffold(
      backgroundColor: kBgDark,
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Row(children: [
            Icon(Icons.bar_chart_rounded, color: accent, size: 20),
            const SizedBox(width: 8),
            Text(_detailKarId == null ? 'Rekap' :
                defaultKaryawan.firstWhere((k) => k.id == _detailKarId).nama.split(' ').first,
                style: const TextStyle(color: kBlueDark, fontSize: 18, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (_detailKarId != null)
              GestureDetector(
                onTap: () => setState(() => _detailKarId = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF2FB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFB0C8E0)),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.arrow_back_ios_new_rounded, color: kWhite55, size: 11),
                    SizedBox(width: 4),
                    Text('Kembali', style: TextStyle(color: kWhite55, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
          ]),
        ),
        _buildMonthSelector(),
        Container(
          margin: const EdgeInsets.fromLTRB(18, 0, 18, 12),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2FB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFB0C8E0)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              color: kBlueDark,
              borderRadius: BorderRadius.circular(10),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: kWhite30,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            padding: const EdgeInsets.all(4),
            tabs: const [
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.calendar_month_rounded, size: 14),
                SizedBox(width: 5),
                Text('Kehadiran'),
              ])),
              Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.monetization_on_outlined, size: 14),
                SizedBox(width: 5),
                Text('Pendapatan'),
              ])),
            ],
          ),
        ),
        Expanded(child: TabBarView(
          controller: _tabCtrl,
          children: [
            _detailKarId == null ? _buildKehadiran() : _buildDetailKehadiran(_detailKarId!),
            _detailKarId == null ? _buildPendapatan() : _buildDetailPendapatan(_detailKarId!),
          ],
        )),
      ])),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrent = _bulan == now.month && _tahun == now.year;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(children: [
        GestureDetector(
          onTap: _prevBulan,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB0C8E0))),
            child: const Icon(Icons.chevron_left_rounded, color: kWhite55, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Center(child: Text(
          '${_namaBulan[_bulan]} $_tahun',
          style: const TextStyle(color: kBlueDark, fontSize: 15, fontWeight: FontWeight.w800),
        ))),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: isCurrent ? null : _nextBulan,
          child: Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFB0C8E0))),
            child: Icon(Icons.chevron_right_rounded, color: isCurrent ? kWhite10 : kWhite55, size: 20),
          ),
        ),
      ]),
    );
  }

  Widget _buildKehadiran() {
    final totalHadirAll = defaultKaryawan.fold(0, (s, k) => s + _hadir(k.id));
    final totalHariAll  = defaultKaryawan.fold(0, (s, k) => s + _totalHari(k.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFEAF2FB), Color(0xFFD6E8F5)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x403A6DD4)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tingkat Kehadiran Bulan Ini',
                style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            Row(children: [
              Text(
                totalHariAll == 0 ? '0%' : '${(totalHadirAll / totalHariAll * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: kGreen, fontSize: 32, fontWeight: FontWeight.w800, height: 1),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('$totalHadirAll dari $totalHariAll total hari kerja',
                    style: const TextStyle(color: kWhite55, fontSize: 12)),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: totalHariAll == 0 ? 0 : totalHadirAll / totalHariAll,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFB0C8E0),
                    valueColor: const AlwaysStoppedAnimation<Color>(kGreen),
                  ),
                ),
              ])),
            ]),
            const SizedBox(height: 10),
            Wrap(spacing: 12, runSpacing: 4, children: [
              StatusKehadiran.hadir, StatusKehadiran.izin,
              StatusKehadiran.sakit, StatusKehadiran.alpha, StatusKehadiran.cuti,
            ].map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(s), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(_statusLabel(s), style: const TextStyle(color: kWhite30, fontSize: 11)),
            ])).toList()),
          ]),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1A3A6B), borderRadius: BorderRadius.circular(10)),
          child: Row(children: const [
            SizedBox(width: 44),
            SizedBox(width: 8),
            Expanded(child: Text('Nama', style: TextStyle(color: kBlueAccent, fontSize: 11, fontWeight: FontWeight.w800))),
            SizedBox(width: 52, child: Text('Hadir', textAlign: TextAlign.center, style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w800))),
            SizedBox(width: 36, child: Text('Alpha', textAlign: TextAlign.center, style: TextStyle(color: kRed, fontSize: 11, fontWeight: FontWeight.w800))),
            SizedBox(width: 36, child: Text('Izin', textAlign: TextAlign.center, style: TextStyle(color: kOrange, fontSize: 11, fontWeight: FontWeight.w800))),
            SizedBox(width: 36, child: Text('Sakit', textAlign: TextAlign.center, style: TextStyle(color: kBlueAccent, fontSize: 11, fontWeight: FontWeight.w800))),
          ]),
        ),
        const SizedBox(height: 6),
        ...defaultKaryawan.map((k) {
          final hadir  = _hadir(k.id);
          final alpha  = _alpha(k.id);
          final izin   = _izin(k.id);
          final sakit  = _sakit(k.id);
          final persen = _persen(k.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => setState(() => _detailKarId = k.id),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFD6E8F5)),
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: k.avatarColor.withAlpha(70),
                        shape: BoxShape.circle,
                        border: Border.all(color: k.avatarColor.withAlpha(130)),
                      ),
                      child: Center(child: Text(k.initial,
                          style: TextStyle(color: k.avatarColor, fontSize: 18, fontWeight: FontWeight.w800))),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(k.nama, style: const TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text(k.jabatan, style: const TextStyle(color: kWhite30, fontSize: 11)),
                    ])),
                    SizedBox(width: 52, child: Text('$hadir hari',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: persen >= 0.8 ? kGreen : kOrange, fontSize: 13, fontWeight: FontWeight.w800))),
                    SizedBox(width: 36, child: Text('$alpha',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: alpha > 0 ? kRed : kWhite30, fontSize: 13, fontWeight: FontWeight.w700))),
                    SizedBox(width: 36, child: Text('$izin',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: izin > 0 ? kOrange : kWhite30, fontSize: 13, fontWeight: FontWeight.w700))),
                    SizedBox(width: 36, child: Text('$sakit',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: sakit > 0 ? kBlueAccent : kWhite30, fontSize: 13, fontWeight: FontWeight.w700))),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: persen, minHeight: 5,
                        backgroundColor: const Color(0xFFB0C8E0),
                        valueColor: AlwaysStoppedAnimation<Color>(persen >= 0.8 ? kGreen : kOrange),
                      ),
                    )),
                    const SizedBox(width: 8),
                    Text('${(persen * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: persen >= 0.8 ? kGreen : kOrange, fontSize: 11, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: kWhite10, size: 16),
                  ]),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildDetailKehadiran(int karId) {
    final k      = defaultKaryawan.firstWhere((k) => k.id == karId);
    final rekap  = _absensiKar(karId);
    final hadir  = _hadir(karId);
    final alpha  = _alpha(karId);
    final izin   = _izin(karId);
    final sakit  = _sakit(karId);
    final cuti   = _cuti(karId);
    final terlambat = _terlambatCount(karId);
    final totalHari = _totalHari(karId);
    final persen    = _persen(karId);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [k.avatarColor.withAlpha(30), const Color(0xFFEAF2FB)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: k.avatarColor.withAlpha(80)),
          ),
          child: Row(children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: k.avatarColor.withAlpha(80), shape: BoxShape.circle,
                border: Border.all(color: k.avatarColor, width: 2),
              ),
              child: Center(child: Text(k.initial,
                  style: TextStyle(color: k.avatarColor, fontSize: 24, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k.nama, style: const TextStyle(color: kBlueDark, fontSize: 16, fontWeight: FontWeight.w800)),
              Text(k.jabatan, style: const TextStyle(color: kWhite55, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${_namaBulan[_bulan]} $_tahun',
                  style: TextStyle(color: k.avatarColor, fontSize: 12, fontWeight: FontWeight.w700)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${(persen * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: persen >= 0.8 ? kGreen : kOrange,
                      fontSize: 28, fontWeight: FontWeight.w800, height: 1)),
              Text('kehadiran', style: TextStyle(color: persen >= 0.8 ? kGreen : kOrange, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
          childAspectRatio: 1.55, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _MiniStat(label: 'Hadir',    value: '$hadir hari',    color: kGreen),
            _MiniStat(label: 'Alpha',    value: '$alpha hari',    color: kRed),
            _MiniStat(label: 'Izin',     value: '$izin hari',     color: kOrange),
            _MiniStat(label: 'Sakit',    value: '$sakit hari',    color: kBlueAccent),
            _MiniStat(label: 'Cuti',     value: '$cuti hari',     color: kBlueDark),
            _MiniStat(label: 'Terlambat',value: '$terlambat kali',color: const Color(0xFFFF9F43)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD6E8F5))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Kehadiran Bulan Ini',
                  style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w700)),
              Text('$hadir / $totalHari hari kerja',
                  style: const TextStyle(color: kWhite55, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: persen, minHeight: 10,
                backgroundColor: const Color(0xFFB0C8E0),
                valueColor: AlwaysStoppedAnimation<Color>(persen >= 0.8 ? kGreen : kOrange),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        _buildKalender(rekap),
        const SizedBox(height: 12),
        const Row(children: [
          Icon(Icons.list_alt_rounded, color: kBlueAccent, size: 14),
          SizedBox(width: 6),
          Text('Detail Absensi Harian',
              style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ...rekap.map((a) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: _AbsensiRow(
            absensi: a,
            hariSingkat: _hariSingkat,
            statusColor: _statusColor,
            statusLabel: _statusLabel,
            shiftLabel: _shiftLabel,
            fmtJam: _fmtJam,
          ),
        )),
      ]),
    );
  }

  Widget _buildKalender(List<AbsensiHarian> rekap) {
    final jumlahHari = DateUtils.getDaysInMonth(_tahun, _bulan);
    final hariPertama = DateTime(_tahun, _bulan, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD6E8F5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.grid_view_rounded, color: kBlueAccent, size: 14),
          SizedBox(width: 6),
          Text('Kalender Kehadiran', style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 10),
        Row(children: _hariSingkat.map((h) => Expanded(
          child: Center(child: Text(h, style: const TextStyle(color: kWhite30, fontSize: 10, fontWeight: FontWeight.w700))),
        )).toList()),
        const SizedBox(height: 6),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4, childAspectRatio: 1),
          itemCount: hariPertama + jumlahHari,
          itemBuilder: (_, idx) {
            if (idx < hariPertama) return const SizedBox();
            final hari = idx - hariPertama + 1;
            final tgl  = DateTime(_tahun, _bulan, hari);
            if (tgl.weekday == DateTime.sunday) {
              return Container(
                decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('$hari', style: const TextStyle(color: kWhite10, fontSize: 10))),
              );
            }
            final ab = rekap.where((a) => a.tanggal.day == hari).toList();
            if (ab.isEmpty) {
              return Container(
                decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(6)),
                child: Center(child: Text('$hari', style: const TextStyle(color: kWhite30, fontSize: 10))),
              );
            }
            final col = _statusColor(ab.first.status);
            return Container(
              decoration: BoxDecoration(
                color: col.withAlpha(40), borderRadius: BorderRadius.circular(6),
                border: Border.all(color: col.withAlpha(80)),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('$hari', style: TextStyle(color: col, fontSize: 9, fontWeight: FontWeight.w700, height: 1.2)),
                Text(_statusHuruf(ab.first.status), style: TextStyle(color: col, fontSize: 8, fontWeight: FontWeight.w800)),
              ]),
            );
          },
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 10, runSpacing: 4, children: [
          StatusKehadiran.hadir, StatusKehadiran.izin, StatusKehadiran.sakit,
          StatusKehadiran.alpha, StatusKehadiran.cuti,
        ].map((s) => Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: _statusColor(s), shape: BoxShape.circle)),
          const SizedBox(width: 4),
          Text(_statusLabel(s), style: const TextStyle(color: kWhite30, fontSize: 10)),
        ])).toList()),
      ]),
    );
  }

  Widget _buildPendapatan() {
    final sorted = List<Karyawan>.from(defaultKaryawan)
      ..sort((a, b) => _omzetKar(b.id).compareTo(_omzetKar(a.id)));
    final maxOmzet = _omzetKar(sorted.first.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFFEAF2FB), Color(0xFFD6E8F5)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x408B5CF6)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Total Pendapatan Bulan Ini',
                style: TextStyle(color: kWhite55, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(_fmtRp(_totalOmzet),
                style: const TextStyle(color: kBlueDark, fontSize: 30, fontWeight: FontWeight.w800, height: 1)),
            const SizedBox(height: 12),
            Row(children: [
              _HeroStatBox(label: 'Transaksi', value: '$_totalTransaksi', color: kBlueAccent),
              const SizedBox(width: 8),
              _HeroStatBox(label: 'Est. Gaji', value: _fmtRp(_totalGaji), color: kOrange),
              const SizedBox(width: 8),
              _HeroStatBox(label: 'Profit', value: _fmtRp(_profit),
                  color: _profit >= 0 ? kGreen : kRed),
            ]),
          ]),
        ),
        const SizedBox(height: 14),
        _buildChartMinggu(),
        const SizedBox(height: 14),
        const Row(children: [
          Icon(Icons.emoji_events_rounded, color: kOrange, size: 15),
          SizedBox(width: 6),
          Text('Kontribusi Per Karyawan',
              style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ...sorted.asMap().entries.map((e) {
          final rank = e.key + 1;
          final k    = e.value;
          final omzet = _omzetKar(k.id);
          final trx   = _transaksiKar(k.id);
          final gaji  = _gajiKar(k.id);
          final barPct = maxOmzet == 0 ? 0.0 : omzet / maxOmzet;
          final rankEmoji = rank == 1 ? '🥇' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '$rank';

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() { _detailKarId = k.id; _tabCtrl.animateTo(1); }),
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: rank == 1 ? const Color(0x1AFFB84D) : const Color(0xFFEAF2FB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: rank == 1 ? const Color(0x40FFB84D) : const Color(0xFFD6E8F5)),
                ),
                child: Column(children: [
                  Row(children: [
                    Text(rankEmoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: k.avatarColor.withAlpha(70), shape: BoxShape.circle,
                        border: Border.all(color: k.avatarColor.withAlpha(120)),
                      ),
                      child: Center(child: Text(k.initial,
                          style: TextStyle(color: k.avatarColor, fontSize: 16, fontWeight: FontWeight.w800))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(k.nama, style: const TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w700)),
                      Text('${k.jabatan} · $trx transaksi',
                          style: const TextStyle(color: kWhite30, fontSize: 11)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(_fmtRp(omzet),
                          style: TextStyle(color: rank == 1 ? kOrange : kBlueDark,
                              fontSize: 15, fontWeight: FontWeight.w800)),
                      Text('Gaji: ${_fmtRp(gaji)}',
                          style: const TextStyle(color: kWhite30, fontSize: 11)),
                    ]),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: kWhite10, size: 16),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(height: 6, child: Row(children: [
                        Expanded(flex: (barPct * 100).round().clamp(1, 100),
                            child: Container(decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [k.avatarColor, kBlue]),
                            ))),
                        Expanded(flex: ((1-barPct)*100).round().clamp(0, 99),
                            child: Container(color: const Color(0xFFB0C8E0))),
                      ])),
                    )),
                    const SizedBox(width: 8),
                    Text('${(barPct * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(color: kWhite30, fontSize: 11, fontWeight: FontWeight.w700)),
                  ]),
                ]),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildDetailPendapatan(int karId) {
    final k      = defaultKaryawan.firstWhere((k) => k.id == karId);
    final rekap  = _absensiKar(karId).where((a) => a.status == StatusKehadiran.hadir).toList();
    final omzet  = _omzetKar(karId);
    final trx    = _transaksiKar(karId);
    final hadir  = _hadir(karId);
    final gaji   = _gajiKar(karId);
    final profit = omzet - gaji;
    final avg    = hadir == 0 ? 0 : omzet ~/ hadir;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [k.avatarColor.withAlpha(30), const Color(0xFFEAF2FB)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: k.avatarColor.withAlpha(80)),
          ),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: k.avatarColor.withAlpha(80), shape: BoxShape.circle,
                  border: Border.all(color: k.avatarColor, width: 2)),
              child: Center(child: Text(k.initial,
                  style: TextStyle(color: k.avatarColor, fontSize: 22, fontWeight: FontWeight.w800))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k.nama, style: const TextStyle(color: kBlueDark, fontSize: 15, fontWeight: FontWeight.w800)),
              Text(k.jabatan, style: const TextStyle(color: kWhite55, fontSize: 12)),
              Text('${_namaBulan[_bulan]} $_tahun',
                  style: TextStyle(color: k.avatarColor, fontSize: 11, fontWeight: FontWeight.w700)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(_fmtRp(omzet),
                  style: const TextStyle(color: kBlueDark, fontSize: 20, fontWeight: FontWeight.w800, height: 1)),
              const Text('total omzet', style: TextStyle(color: kWhite30, fontSize: 11)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
          childAspectRatio: 2.1, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _MiniStat(label: 'Total Omzet',   value: _fmtRp(omzet),   color: kBlueDark),
            _MiniStat(label: 'Transaksi',      value: '$trx order',    color: kBlueAccent),
            _MiniStat(label: 'Rata-rata/Hari', value: _fmtRp(avg),     color: kGreen),
            _MiniStat(label: 'Est. Gaji',      value: _fmtRp(gaji),    color: kOrange),
            _MiniStat(label: 'Hari Hadir',     value: '$hadir hari',   color: kGreen),
            _MiniStat(label: 'Profit Bersih',  value: _fmtRp(profit),
                color: profit >= 0 ? kGreen : kRed),
          ],
        ),
        const SizedBox(height: 14),
        const Row(children: [
          Icon(Icons.receipt_long_rounded, color: kBlueDark, size: 14),
          SizedBox(width: 6),
          Text('Omzet Per Hari Masuk',
              style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 10),
        ...rekap.map((a) {
          final d   = a.tanggal;
          final pct = omzet == 0 ? 0.0 : a.omzetHari / omzet;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD6E8F5)),
              ),
              child: Row(children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: k.avatarColor.withAlpha(30), borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('${d.day}', style: TextStyle(color: k.avatarColor, fontSize: 13, fontWeight: FontWeight.w800, height: 1)),
                    Text(_hariSingkat[d.weekday % 7],
                        style: TextStyle(color: k.avatarColor.withAlpha(160), fontSize: 9, fontWeight: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFB0C8E0), borderRadius: BorderRadius.circular(6)),
                      child: Text('Shift ${_shiftLabel(a.shift)}',
                          style: const TextStyle(color: kWhite55, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 6),
                    Text('${a.totalTransaksi} transaksi',
                        style: const TextStyle(color: kWhite30, fontSize: 11)),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: SizedBox(
                      height: 5,
                      child: Row(children: [
                        Expanded(flex: (pct * 100).round().clamp(1, 100),
                            child: Container(color: k.avatarColor)),
                        Expanded(flex: ((1-pct)*100).round().clamp(0, 99),
                            child: Container(color: const Color(0xFFB0C8E0))),
                      ]),
                    ),
                  ),
                ])),
                const SizedBox(width: 10),
                Text(_fmtRp(a.omzetHari),
                    style: const TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w800)),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  Widget _buildChartMinggu() {
    final jumlahHari = DateUtils.getDaysInMonth(_tahun, _bulan);
    final weeks = <int, int>{};
    for (int h = 1; h <= jumlahHari; h++) {
      final mingguKe = ((h - 1) ~/ 7) + 1;
      final total = _absensi.where((a) => a.tanggal.day == h).fold(0, (s, a) => s + a.omzetHari);
      weeks[mingguKe] = (weeks[mingguKe] ?? 0) + total;
    }
    final sorted = weeks.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final maxVal = sorted.fold(0, (m, e) => e.value > m ? e.value : m);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFD6E8F5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.bar_chart_rounded, color: kBlueDark, size: 14),
          SizedBox(width: 6),
          Text('Omzet Per Minggu', style: TextStyle(color: kBlueDark, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          height: 80,
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: sorted.map((e) {
            final pct = maxVal == 0 ? 0.05 : (e.value / maxVal).clamp(0.05, 1.0);
            return Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(_fmtRp(e.value),
                    style: const TextStyle(color: kBlueDark, fontSize: 9, fontWeight: FontWeight.w700), maxLines: 1),
                const SizedBox(height: 3),
                Expanded(child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: pct,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [kBlueDark, kBlue], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                      ),
                    ),
                  ),
                )),
                const SizedBox(height: 4),
                Text('Mgg ${e.key}', style: const TextStyle(color: kWhite30, fontSize: 10, fontWeight: FontWeight.w600)),
              ]),
            ));
          }).toList()),
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGET PENDUKUNG
// ═══════════════════════════════════════════════════════════════

class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: color.withAlpha(25), borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(60)),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w800, height: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
      const SizedBox(height: 3),
      Text(label, style: const TextStyle(color: kWhite30, fontSize: 10, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _HeroStatBox extends StatelessWidget {
  final String label, value;
  final Color color;
  const _HeroStatBox({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FB), borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6E8F5)),
      ),
      child: Column(children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800, height: 1), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: kWhite30, fontSize: 9, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
      ]),
    ),
  );
}

class _AbsensiRow extends StatelessWidget {
  final AbsensiHarian absensi;
  final List<String> hariSingkat;
  final Color Function(StatusKehadiran) statusColor;
  final String Function(StatusKehadiran) statusLabel;
  final String Function(ShiftKerja) shiftLabel;
  final String Function(TimeOfDay?) fmtJam;
  const _AbsensiRow({required this.absensi, required this.hariSingkat,
      required this.statusColor, required this.statusLabel,
      required this.shiftLabel, required this.fmtJam});

  @override
  Widget build(BuildContext context) {
    final col = statusColor(absensi.status);
    final d   = absensi.tanggal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: col.withAlpha(15), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: col.withAlpha(50)),
      ),
      child: Row(children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: col.withAlpha(30), borderRadius: BorderRadius.circular(10)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${d.day}', style: TextStyle(color: col, fontSize: 13, fontWeight: FontWeight.w800, height: 1)),
            Text(hariSingkat[d.weekday % 7], style: TextStyle(color: col.withAlpha(180), fontSize: 9, fontWeight: FontWeight.w700)),
          ]),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: col.withAlpha(40), borderRadius: BorderRadius.circular(6)),
              child: Text(statusLabel(absensi.status), style: TextStyle(color: col, fontSize: 11, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: const Color(0xFFB0C8E0), borderRadius: BorderRadius.circular(6)),
              child: Text('Shift ${shiftLabel(absensi.shift)}',
                  style: const TextStyle(color: kWhite55, fontSize: 10, fontWeight: FontWeight.w600)),
            ),
            if (absensi.terlambat) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: const Color(0x26FF9F43), borderRadius: BorderRadius.circular(6)),
                child: const Text('Terlambat', style: TextStyle(color: Color(0xFFFF9F43), fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ],
          ]),
          const SizedBox(height: 3),
          Text('Masuk: ${fmtJam(absensi.jamMasuk)}  ·  Keluar: ${fmtJam(absensi.jamKeluar)}',
              style: const TextStyle(color: kWhite30, fontSize: 11)),
        ])),
        if (absensi.status == StatusKehadiran.hadir)
          Text('${absensi.totalTransaksi} trx',
              style: const TextStyle(color: kWhite55, fontSize: 11, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}