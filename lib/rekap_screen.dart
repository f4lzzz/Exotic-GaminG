import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

enum PeriodeFilter { none, hariIni, mingguIni }

class RekapScreen extends StatefulWidget {
  final String role;
  const RekapScreen({super.key, required this.role});
  @override
  State<RekapScreen> createState() => _RekapScreenState();
}

class _RekapScreenState extends State<RekapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;
  String? _detailKarUid;
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
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;
  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  final List<Map<String, dynamic>> _karyawanDummy = const [
    {
      'nama': 'Freya Fauna',
      'jabatan': 'Kasir',
      'hadir': 22,
      'izin': 1,
      'sakit': 0,
      'alpha': 0
    },
    {
      'nama': 'Zaki Ramadan',
      'jabatan': 'Barista',
      'hadir': 20,
      'izin': 0,
      'sakit': 1,
      'alpha': 1
    },
    {
      'nama': 'Anna Kusuma',
      'jabatan': 'Pelayan',
      'hadir': 21,
      'izin': 1,
      'sakit': 0,
      'alpha': 0
    },
    {
      'nama': 'Ridwan Saputra',
      'jabatan': 'Operator',
      'hadir': 19,
      'izin': 0,
      'sakit': 0,
      'alpha': 2
    },
    {
      'nama': 'Mingyu Park',
      'jabatan': 'Kasir',
      'hadir': 22,
      'izin': 0,
      'sakit': 0,
      'alpha': 0
    },
    {
      'nama': 'Annsa Kuat',
      'jabatan': 'Barista',
      'hadir': 20,
      'izin': 0,
      'sakit': 1,
      'alpha': 1
    },
  ];

  PeriodeFilter _periodeFilter = PeriodeFilter.none;
  int _totalOmzet = 0;
  int _totalTransaksi = 0;
  bool _loadingPendapatan = true;
  String? _pendapatanError;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));
    _loadPendapatan();
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
        _detailKarUid = null;
        _periodeFilter = PeriodeFilter.none;
        _loadPendapatan();
      });
  void _nextBulan() => setState(() {
        final now = DateTime.now();
        if (_tahun == now.year && _bulan == now.month) return;
        if (_bulan == 12) {
          _bulan = 1;
          _tahun++;
        } else
          _bulan++;
        _detailKarUid = null;
        _periodeFilter = PeriodeFilter.none;
        _loadPendapatan();
      });

  String _fmtRp(int v) {
    if (v >= 1000000) return 'Rp ${(v / 1000000).toStringAsFixed(1)}jt';
    if (v >= 1000) return 'Rp ${(v / 1000).toStringAsFixed(0)}rb';
    return 'Rp $v';
  }

  Future<void> _loadPendapatan() async {
    setState(() {
      _loadingPendapatan = true;
      _pendapatanError = null;
    });
    try {
      final snap = await FirebaseFirestore.instance
          .collection('transaksi')
          .where('isClosed', isEqualTo: true)
          .get();

      DateTime startDate, endDate;
      if (_periodeFilter == PeriodeFilter.hariIni) {
        final now = DateTime.now();
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate;
      } else if (_periodeFilter == PeriodeFilter.mingguIni) {
        final now = DateTime.now();
        startDate = now.subtract(Duration(days: now.weekday - 1));
        endDate = startDate.add(const Duration(days: 6));
      } else {
        startDate = DateTime(_tahun, _bulan, 1);
        endDate = DateTime(_tahun, _bulan + 1, 0);
      }
      final endDatePlus = endDate.add(const Duration(days: 1));

      int total = 0;
      int trxCount = 0;
      for (var doc in snap.docs) {
        final timestamp = doc['timestamp'] as Timestamp?;
        if (timestamp == null) continue;
        final tgl = timestamp.toDate();
        if (tgl.isAfter(startDate.subtract(const Duration(days: 1))) &&
            tgl.isBefore(endDatePlus)) {
          final harga = doc['harga'];
          total += harga is int
              ? harga
              : (harga is double ? harga.toInt() : (harga as num).toInt());
          trxCount++;
        }
      }
      setState(() {
        _totalOmzet = total;
        _totalTransaksi = trxCount;
        _loadingPendapatan = false;
      });
    } catch (e) {
      setState(() {
        _pendapatanError = e.toString();
        _loadingPendapatan = false;
      });
    }
  }

  String _getPeriodeLabel() {
    if (_periodeFilter == PeriodeFilter.hariIni) return 'HARI INI';
    if (_periodeFilter == PeriodeFilter.mingguIni) return 'MINGGU INI';
    return '${_namaBulan[_bulan]} $_tahun';
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
                _buildKehadiranDummy(),
                _buildPendapatan(),
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
                    child: Text(_detailKarUid == null ? 'REKAP' : 'DETAIL',
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
                  child: Text(_detailKarUid == null ? 'REKAP' : 'DETAIL',
                      style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: kWhite))),
            ]),
    );
  }

  Widget _buildMonthSelector() {
    final now = DateTime.now();
    final isCurrent = _tahun == now.year && _bulan == now.month;
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
                    color: kBlue, size: 20)),
          ),
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
                    color: isCurrent ? Colors.grey.shade300 : kBlue, size: 20)),
          ),
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

  Widget _buildKehadiranDummy() {
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
                  Text('92.5%',
                      style: GoogleFonts.lato(
                          color: kGreen,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          height: 1)),
                  const SizedBox(width: 14),
                  Expanded(
                      child: Column(children: [
                    Text('124 dari 134 hari kerja',
                        style: GoogleFonts.lato(
                            color: Colors.black45, fontSize: 12)),
                    const SizedBox(height: 6),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                            value: 0.925,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(kGreen))),
                  ])),
                ]),
                const SizedBox(height: 10),
                Wrap(spacing: 12, runSpacing: 4, children: [
                  _buildLegenda('Hadir', kGreen),
                  _buildLegenda('Izin', kOrange),
                  _buildLegenda('Sakit', kPurple),
                  _buildLegenda('Alpha', kRed),
                  _buildLegenda('Cuti', kBlueDark),
                ]),
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
          const SizedBox(height: 8),
          ..._karyawanDummy.map((k) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                  child: Row(children: [
                    Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                            color: kBlue.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: kBlue.withOpacity(0.3))),
                        child: Center(
                            child: Text(k['nama'][0].toUpperCase(),
                                style: GoogleFonts.lato(
                                    color: kBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800)))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(k['nama'],
                              style: GoogleFonts.lato(
                                  color: kTextDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                          Text(k['jabatan'],
                              style: GoogleFonts.lato(
                                  color: Colors.black45, fontSize: 11)),
                        ])),
                    SizedBox(
                        width: 52,
                        child: Text('${k['hadir']} hari',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: kGreen,
                                fontSize: 13,
                                fontWeight: FontWeight.w800))),
                    SizedBox(
                        width: 36,
                        child: Text('${k['alpha']}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: k['alpha'] > 0 ? kRed : Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w700))),
                    SizedBox(
                        width: 36,
                        child: Text('${k['izin']}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color: k['izin'] > 0 ? kOrange : Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w700))),
                    SizedBox(
                        width: 36,
                        child: Text('${k['sakit']}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lato(
                                color:
                                    k['sakit'] > 0 ? kPurple : Colors.black45,
                                fontSize: 13,
                                fontWeight: FontWeight.w700))),
                  ]),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildLegenda(String label, Color color) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.lato(color: Colors.black45, fontSize: 11)),
    ]);
  }

  Widget _buildPendapatan() {
    return Column(
      children: [
        _buildFilterChips(),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: _loadingPendapatan
                ? const Center(child: CircularProgressIndicator())
                : _pendapatanError != null
                    ? Center(
                        child: Column(children: [
                        Icon(Icons.error, color: kRed),
                        Text(_pendapatanError!),
                        ElevatedButton(
                            onPressed: _loadPendapatan,
                            child: const Text('Refresh'))
                      ]))
                    : Column(
                        children: [
                          _buildOmzetCard(),
                          const SizedBox(height: 16),
                          _buildInfoCard(),
                        ],
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          _filterChip(PeriodeFilter.none, 'Bulan Ini'),
          _filterChip(PeriodeFilter.hariIni, 'Hari Ini'),
          _filterChip(PeriodeFilter.mingguIni, 'Minggu Ini'),
        ],
      ),
    );
  }

  Widget _filterChip(PeriodeFilter filter, String label) {
    final isSelected = _periodeFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_periodeFilter == filter) return;
          setState(() {
            _periodeFilter = filter;
          });
          _loadPendapatan();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? kBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isSelected ? kWhite : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOmzetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kBlue, kBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getPeriodeLabel(),
            style: GoogleFonts.lato(
                fontSize: 13, color: kWhiteDim, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _fmtRp(_totalOmzet),
            style: GoogleFonts.lato(
                fontSize: 32, fontWeight: FontWeight.w900, color: kWhite),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.receipt_rounded, size: 16, color: kWhiteDim),
              const SizedBox(width: 4),
              Text(
                '$_totalTransaksi transaksi',
                style: GoogleFonts.lato(fontSize: 12, color: kWhiteDim),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info',
            style: GoogleFonts.lato(
                fontSize: 14, fontWeight: FontWeight.w800, color: kTextDark),
          ),
          const SizedBox(height: 8),
          Text(
            'Data pendapatan hanya dari transaksi yang shift-nya sudah diakhiri (closed). Gunakan filter di atas untuk melihat periode tertentu.',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
