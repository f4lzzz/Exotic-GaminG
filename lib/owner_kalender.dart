import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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

class OwnerKalenderScreen extends StatefulWidget {
  final String uid;
  final String nama;

  const OwnerKalenderScreen({super.key, required this.uid, required this.nama});

  @override
  State<OwnerKalenderScreen> createState() => _OwnerKalenderScreenState();
}

class _OwnerKalenderScreenState extends State<OwnerKalenderScreen>
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

  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  Map<String, String> _statusMap = {};
  bool _isLoading = false;

  static const _statusList = [
    _StatusItem('hadir', 'HADIR', kGreen, Icons.check_circle_rounded),
    _StatusItem('libur', 'LIBUR', kRed, Icons.cancel_rounded),
    _StatusItem('izin', 'IZIN', kOrange, Icons.event_note_rounded),
    _StatusItem('sakit', 'SAKIT', kPurple, Icons.healing_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollCtrl.addListener(
      () => setState(() => _scrollOffset = _scrollCtrl.offset),
    );
    _loadAbsensi();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAbsensi() async {
    setState(() => _isLoading = true);
    try {
      final startOf = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
      final endOf = DateTime(
        _focusedMonth.year,
        _focusedMonth.month + 1,
        0,
        23,
        59,
        59,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('absensi')
          .where('uid', isEqualTo: widget.uid)
          .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(startOf))
          .where('tanggal', isLessThanOrEqualTo: Timestamp.fromDate(endOf))
          .get();

      final map = <String, String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final tanggal = (data['tanggal'] as Timestamp).toDate();
        final key = DateFormat('yyyy-MM-dd').format(tanggal);
        map[key] = data['status'] ?? 'hadir';
      }
      setState(() {
        _statusMap = map;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memuat data: $e',
              style: GoogleFonts.lato(color: kWhite),
            ),
            backgroundColor: kRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _saveAbsensi(DateTime tanggal, String status) async {
    final key = DateFormat('yyyy-MM-dd').format(tanggal);
    final docId = '${widget.uid}_$key';

    try {
      await FirebaseFirestore.instance.collection('absensi').doc(docId).set({
        'uid': widget.uid,
        'nama': widget.nama,
        'tanggal': Timestamp.fromDate(
          DateTime(tanggal.year, tanggal.month, tanggal.day),
        ),
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() => _statusMap[key] = status);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(_statusIcon(status), color: kWhite, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('d MMM yyyy').format(tanggal)} → ${_statusLabel(status)}',
                  style: GoogleFonts.lato(
                    color: kWhite,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            backgroundColor: _statusColor(status),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal simpan: $e',
              style: GoogleFonts.lato(color: kWhite),
            ),
            backgroundColor: kRed,
          ),
        );
      }
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
      _selectedDate = null;
    });
    _loadAbsensi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildLegend(),
                  const SizedBox(height: 16),
                  _buildCalendar(),
                  const SizedBox(height: 16),
                  _buildMonthSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER DIPERBAIKI: hanya logo EXOTIC + tombol back + chip KALENDER
  Widget _buildHeader() {
    final p = _collapseProgress;
    final double eSize = 24 - (24 - 14) * p;
    final double xSize = 40 - (40 - 22) * p;
    final double oticSize = 24 - (24 - 14) * p;
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;

    final logoWidget = RichText(
      text: TextSpan(
        style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
        children: [
          TextSpan(
            text: 'E',
            style: TextStyle(fontSize: eSize, fontWeight: FontWeight.w400),
          ),
          TextSpan(
            text: 'X',
            style: TextStyle(fontSize: xSize, fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: 'OTIC',
            style: TextStyle(fontSize: oticSize, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );

    final backBtn = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: kWhite, size: 16),
      ),
    );

    final chipWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'KALENDER',
        style: GoogleFonts.lato(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: kWhite,
          letterSpacing: 0.8,
        ),
      ),
    );

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
          backBtn,
          const SizedBox(width: 10),
          logoWidget,
          const Spacer(),
          chipWidget,
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final initials = widget.nama
        .trim()
        .split(' ')
        .take(2)
        .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
        .join();
    final totalHadir = _statusMap.values.where((s) => s == 'hadir').length;
    final totalAbsen = _statusMap.values.length - totalHadir;

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kWhite.withOpacity(0.2),
              border: Border.all(color: kWhite.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                initials,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nama,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: kWhite,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: GoogleFonts.lato(fontSize: 12, color: kWhiteDim),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _miniStat('$totalHadir', 'Hadir', kGreen),
                    const SizedBox(width: 12),
                    _miniStat('$totalAbsen', 'Tidak Hadir', kRed),
                    const SizedBox(width: 12),
                    _miniStat('${_statusMap.length}', 'Tercatat', kYellow),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _loadAbsensi,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        color: kWhite,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded, color: kWhite, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(label, style: GoogleFonts.lato(fontSize: 9, color: kWhiteDim)),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _statusList
            .map(
              (s) => Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    s.label,
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4A90D9), kBlue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _changeMonth(-1),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: kWhite,
                      size: 22,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _changeMonth(1),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: kWhite,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Row(
              children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'].map((
                d,
              ) {
                final isWeekend = d == 'Sab' || d == 'Min';
                return Expanded(
                  child: Text(
                    d,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isWeekend ? kRed.withOpacity(0.6) : Colors.black38,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: Colors.black.withOpacity(0.05)),

          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: kBlue,
                    strokeWidth: 2,
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                  child: _buildDaysGrid(),
                ),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    int startWeekday = firstDay.weekday;
    final today = DateTime.now();
    final isCurrentMonth =
        _focusedMonth.year == today.year && _focusedMonth.month == today.month;

    final cells = <Widget>[];

    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final key = DateFormat('yyyy-MM-dd').format(date);
      final status = _statusMap[key];
      final isToday = isCurrentMonth && day == today.day;
      final isSelected =
          _selectedDate != null &&
          _selectedDate!.day == day &&
          _selectedDate!.month == _focusedMonth.month &&
          _selectedDate!.year == _focusedMonth.year;
      final isWeekend = date.weekday == 6 || date.weekday == 7;
      final isFuture = date.isAfter(today);

      cells.add(
        _dayCell(
          day: day,
          date: date,
          status: status,
          isToday: isToday,
          isSelected: isSelected,
          isWeekend: isWeekend,
          isFuture: isFuture,
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 4,
      childAspectRatio: 0.85,
      children: cells,
    );
  }

  Widget _dayCell({
    required int day,
    required DateTime date,
    required String? status,
    required bool isToday,
    required bool isSelected,
    required bool isWeekend,
    required bool isFuture,
  }) {
    Color bgColor = Colors.transparent;
    Color textColor = isWeekend ? kRed.withOpacity(0.7) : Colors.black87;

    if (status != null) {
      bgColor = _statusColor(status).withOpacity(0.15);
    }
    if (isToday) {
      bgColor = kBlue.withOpacity(0.1);
      textColor = kBlue;
    }
    if (isSelected) {
      bgColor = kBlue.withOpacity(0.15);
    }
    if (isFuture) {
      textColor = Colors.black26;
    }

    return GestureDetector(
      onTap: isFuture
          ? null
          : () {
              setState(() => _selectedDate = date);
              _showStatusBottomSheet(date);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: kBlue, width: 1.5)
              : isSelected
              ? Border.all(color: kBlue.withOpacity(0.5), width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status != null
                    ? _statusColor(status)
                    : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusBottomSheet(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    final currentStatus = _statusMap[key];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: kBgLight,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: kBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, d MMMM yyyy').format(date),
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: kTextDark,
                        ),
                      ),
                      Text(
                        'Pilih status kehadiran',
                        style: GoogleFonts.lato(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Divider(color: Colors.black12),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                children: _statusList.map((s) {
                  final isActive = currentStatus == s.value;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _saveAbsensi(date, s.value);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? s.color.withOpacity(0.1) : kWhite,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive ? s.color : Colors.black12,
                          width: isActive ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: s.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(s.icon, color: s.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.label,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isActive ? s.color : kTextDark,
                                  ),
                                ),
                                Text(
                                  _statusDesc(s.value),
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: s.color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: kWhite,
                                size: 14,
                              ),
                            )
                          else
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.black26,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSummary() {
    final counts = <String, int>{};
    for (final s in _statusList) counts[s.value] = 0;
    for (final status in _statusMap.values) {
      counts[status] = (counts[status] ?? 0) + 1;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              const Icon(Icons.summarize_rounded, color: kBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                'RINGKASAN BULAN INI',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...(_statusList.map((s) {
            final count = counts[s.value] ?? 0;
            final daysInMonth = DateTime(
              _focusedMonth.year,
              _focusedMonth.month + 1,
              0,
            ).day;
            final ratio = daysInMonth > 0 ? count / daysInMonth : 0.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: s.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(s.icon, color: s.color, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              s.label,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              '$count hari',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: s.color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: ratio.clamp(0.0, 1.0),
                            minHeight: 7,
                            backgroundColor: Colors.black.withOpacity(0.06),
                            valueColor: AlwaysStoppedAnimation<Color>(s.color),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })).toList(),
          Divider(color: Colors.black.withOpacity(0.06)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Tercatat',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black45,
                ),
              ),
              Text(
                '${_statusMap.length} hari',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'hadir':
        return kGreen;
      case 'libur':
        return kRed;
      case 'izin':
        return kOrange;
      case 'sakit':
        return kPurple;
      default:
        return kGreen;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'hadir':
        return Icons.check_circle_rounded;
      case 'libur':
        return Icons.cancel_rounded;
      case 'izin':
        return Icons.event_note_rounded;
      case 'sakit':
        return Icons.healing_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'hadir':
        return 'HADIR';
      case 'libur':
        return 'LIBUR';
      case 'izin':
        return 'IZIN';
      case 'sakit':
        return 'SAKIT';
      default:
        return status.toUpperCase();
    }
  }

  String _statusDesc(String status) {
    switch (status) {
      case 'hadir':
        return 'Karyawan masuk kerja';
      case 'libur':
        return 'Hari libur / tidak masuk';
      case 'izin':
        return 'Izin dengan keterangan';
      case 'sakit':
        return 'Tidak masuk karena sakit';
      default:
        return '';
    }
  }
}

class _StatusItem {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatusItem(this.value, this.label, this.color, this.icon);
}
