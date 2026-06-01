import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Warna (sama dengan tema aplikasi)
const _noBlue = Color(0xFF1A5EBF);
const _noWhite = Color(0xFFFFFFFF);
const _noWhiteDim = Color(0xFFDDE8FF);
const _noTextDark = Color(0xFF1A237E);
const _noRed = Color(0xFFE53935);
const _noOrange = Color(0xFFFF9800);
const _noBgLight = Color(0xFFF0F4FF);

class NotifikasiKaryawanScreen extends StatefulWidget {
  const NotifikasiKaryawanScreen({super.key});

  @override
  State<NotifikasiKaryawanScreen> createState() =>
      _NotifikasiKaryawanScreenState();
}

class _NotifikasiKaryawanScreenState extends State<NotifikasiKaryawanScreen>
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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  String _formatPengirim(String pengirim) {
    if (pengirim.contains('@')) return pengirim.split('@').first;
    final parts = pengirim.trim().split(' ');
    if (parts.length > 1) return parts[0];
    return pengirim;
  }

  Future<void> _markAsRead(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('pengumuman')
          .doc(id)
          .update({'dibaca': 1});
    } catch (e) {
      // ignore
    }
  }

  void _showDetailDialog(Map<String, dynamic> data, String id) async {
    if (data['dibaca'] == 0) await _markAsRead(id);
    final prioritas = data['prioritas'] ?? 'Normal';
    final Color pColor = prioritas == 'Darurat'
        ? _noRed
        : prioritas == 'Penting'
            ? _noOrange
            : _noBlue;
    final ts = data['timestamp'] as Timestamp?;
    String waktu =
        ts != null ? DateFormat('d MMM yyyy, HH:mm').format(ts.toDate()) : '';
    final pengirim = _formatPengirim(data['pengirim'] ?? 'owner');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
              maxWidth: 400, maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [_noWhite, Color(0xFFF8F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                decoration: BoxDecoration(
                    color: pColor.withOpacity(0.1),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24))),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                          color: pColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14)),
                      child: Icon(
                        prioritas == 'Darurat'
                            ? Icons.error_outline
                            : prioritas == 'Penting'
                                ? Icons.warning_amber_outlined
                                : Icons.notifications_outlined,
                        color: pColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['judul'] ?? 'Pengumuman',
                              style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: _noTextDark),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                    color: pColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(prioritas,
                                    style: GoogleFonts.lato(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: pColor)),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.people_outline,
                                  size: 12, color: Colors.black38),
                              const SizedBox(width: 4),
                              Text(data['target'] ?? 'Semua',
                                  style: GoogleFonts.lato(
                                      fontSize: 11, color: Colors.black38)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['isi'] ?? '',
                          style: GoogleFonts.lato(
                              fontSize: 14, height: 1.4, color: _noTextDark)),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.person_outline,
                              size: 14, color: Colors.black38),
                          const SizedBox(width: 6),
                          Expanded(
                              child: Text('Pengirim: $pengirim',
                                  style: GoogleFonts.lato(
                                      fontSize: 11, color: Colors.black45))),
                          const SizedBox(width: 8),
                          const Icon(Icons.access_time,
                              size: 12, color: Colors.black38),
                          const SizedBox(width: 4),
                          Text(waktu,
                              style: GoogleFonts.lato(
                                  fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                        foregroundColor: _noBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))),
                    child: Text('Tutup',
                        style: GoogleFonts.lato(
                            fontWeight: FontWeight.w800, fontSize: 13)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noBgLight,
      body: Column(
        children: [
          FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: _buildPengumumanList(),
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
        style: GoogleFonts.playfairDisplay(color: _noWhite, height: 1.0),
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

    final subWidget = Text(
      'GAMING & CAFE',
      style: GoogleFonts.playfairDisplay(
        fontSize: subSize,
        color: _noWhiteDim,
        letterSpacing: 3,
        fontWeight: FontWeight.w400,
      ),
    );

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90D9), _noBlue]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: p < 0.5
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    _backBtn(),
                    const SizedBox(width: 8),
                    logoWidget,
                    const SizedBox(width: 6),
                    Opacity(opacity: subOpacity, child: subWidget),
                    const Spacer(),
                  ],
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _backBtn(),
                const SizedBox(width: 8),
                logoWidget,
                const SizedBox(width: 8),
                subWidget,
                const Spacer(),
              ],
            ),
    );
  }

  Widget _backBtn() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new, color: _noWhite, size: 16),
      ),
    );
  }

  Widget _buildPengumumanList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: _noBlue)));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.lato(color: _noRed)));
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Column(
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 52, color: Colors.black26),
                  const SizedBox(height: 12),
                  Text('Tidak ada pengumuman',
                      style: GoogleFonts.lato(
                          fontSize: 14, color: Colors.black38)),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final todayList = <QueryDocumentSnapshot>[];
        final yesterdayList = <QueryDocumentSnapshot>[];
        final olderList = <QueryDocumentSnapshot>[];

        for (var doc in docs) {
          final ts = doc['timestamp'] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            final dateOnly = DateTime(date.year, date.month, date.day);
            if (dateOnly == today) {
              todayList.add(doc);
            } else if (dateOnly == yesterday) {
              yesterdayList.add(doc);
            } else {
              olderList.add(doc);
            }
          } else {
            olderList.add(doc);
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todayList.isNotEmpty) ...[
              _sectionLabel('HARI INI'),
              ...todayList.map((doc) => _pengumumanCard(doc)),
            ],
            if (yesterdayList.isNotEmpty) ...[
              const SizedBox(height: 4),
              _sectionLabel('KEMARIN'),
              ...yesterdayList.map((doc) => _pengumumanCard(doc)),
            ],
            if (olderList.isNotEmpty) ...[
              const SizedBox(height: 4),
              _sectionLabel('SEBELUMNYA'),
              ...olderList.map((doc) => _pengumumanCard(doc)),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.black38,
                    letterSpacing: 0.8)),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      ),
    );
  }

  Widget _pengumumanCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final judul = data['judul'] ?? 'Tanpa Judul';
    final isi = data['isi'] ?? '';
    final prioritas = data['prioritas'] ?? 'Normal';
    final ts = data['timestamp'] as Timestamp?;
    String waktu =
        ts != null ? DateFormat('d MMM yyyy, HH:mm').format(ts.toDate()) : '';
    final dibaca = data['dibaca'] == 1;
    final isUnread = !dibaca;

    Color borderColor;
    IconData iconData;
    switch (prioritas) {
      case 'Darurat':
        borderColor = _noRed;
        iconData = Icons.error_outline;
        break;
      case 'Penting':
        borderColor = _noOrange;
        iconData = Icons.warning_amber_outlined;
        break;
      default:
        borderColor = _noBlue;
        iconData = Icons.notifications_outlined;
    }

    final pengirim = _formatPengirim(data['pengirim'] ?? 'owner');

    return GestureDetector(
      onTap: () => _showDetailDialog(data, id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFFFFF8E1) : _noWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: borderColor, width: 4)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: borderColor.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: Icon(iconData, color: borderColor, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            judul,
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight:
                                  isUnread ? FontWeight.w800 : FontWeight.w700,
                              color: borderColor,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(left: 6, top: 2),
                              decoration: const BoxDecoration(
                                  color: _noBlue, shape: BoxShape.circle)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(isi,
                        style: GoogleFonts.lato(
                            fontSize: 11, color: Colors.black54),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline,
                            size: 11, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(pengirim,
                            style: GoogleFonts.lato(
                                fontSize: 10, color: Colors.black38)),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time,
                            size: 11, color: Colors.black38),
                        const SizedBox(width: 4),
                        Text(waktu,
                            style: GoogleFonts.lato(
                                fontSize: 10, color: Colors.black38)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
