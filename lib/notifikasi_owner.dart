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

class NotifikasiOwnerScreen extends StatefulWidget {
  const NotifikasiOwnerScreen({super.key});

  @override
  State<NotifikasiOwnerScreen> createState() => _NotifikasiOwnerScreenState();
}

class _NotifikasiOwnerScreenState extends State<NotifikasiOwnerScreen>
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

  bool _isDeletingAll = false;

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

  Future<void> _hapusSemuaPengumuman() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Semua Pengumuman?',
          style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kRed),
        ),
        content: Text(
          'Semua pengumuman akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child:
                Text('Batal', style: GoogleFonts.lato(color: Colors.black45)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Hapus', style: GoogleFonts.lato(color: kWhite)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isDeletingAll = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('pengumuman').get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _showSnack('Semua pengumuman berhasil dihapus', kGreen);
    } catch (e) {
      _showSnack('Gagal menghapus: $e', kRed);
    } finally {
      if (mounted) setState(() => _isDeletingAll = false);
    }
  }

  Future<void> _hapusPengumuman(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Pengumuman?',
            style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kRed)),
        content: Text('Yakin hapus pengumuman ini?',
            style: GoogleFonts.lato(fontSize: 13, color: kTextDark)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: GoogleFonts.lato(color: Colors.black45))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kRed),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Hapus', style: GoogleFonts.lato(color: kWhite))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('pengumuman')
          .doc(id)
          .delete();
      _showSnack('Pengumuman dihapus', kGreen);
    } catch (e) {
      _showSnack('Gagal menghapus: $e', kRed);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
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
            child: SingleChildScrollView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 12),
                  _buildPengumumanList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────────────────────
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

    final subWidget = Text(
      'GAMING & CAFE',
      style: GoogleFonts.playfairDisplay(
        fontSize: subSize,
        color: kWhiteDim,
        letterSpacing: 3,
        fontWeight: FontWeight.w400,
      ),
    );

    final actionButtons = GestureDetector(
      onTap: _hapusSemuaPengumuman,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
        child: _isDeletingAll
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: kWhite))
            : const Icon(Icons.delete_sweep_rounded, color: kWhite, size: 20),
      ),
    );

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
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
                    actionButtons,
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
                actionButtons,
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
            color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new, color: kWhite, size: 16),
      ),
    );
  }

  // ─── SUMMARY ROW (total pengumuman) ────────────────────────────────────────
  Widget _buildSummaryRow() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('pengumuman').snapshots(),
      builder: (context, snapshot) {
        int total = 0;
        if (snapshot.hasData) {
          total = snapshot.data!.docs.length;
        }
        return Row(
          children: [
            Expanded(
                child: _summaryCard('TOTAL PENGUMUMAN', total.toString(),
                    Icons.announcement, kBlue)),
          ],
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
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: GoogleFonts.lato(
                  fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.lato(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.black38,
                  letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ─── LIST PENGUMUMAN ──────────────────────────────────────────────────────
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
                  child: CircularProgressIndicator(color: kBlue)));
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: GoogleFonts.lato(color: kRed)));
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

        // kelompokkan berdasarkan tanggal (hari ini, lebih lama)
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final todayList = <QueryDocumentSnapshot>[];
        final olderList = <QueryDocumentSnapshot>[];

        for (var doc in docs) {
          final ts = doc['timestamp'] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            if (date.isAfter(today)) {
              todayList.add(doc);
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
    final pengirim = data['pengirim'] ?? 'owner';
    final prioritas = data['prioritas'] ?? 'Normal';
    final ts = data['timestamp'] as Timestamp?;
    String waktu = '';
    if (ts != null) {
      final dt = ts.toDate();
      waktu = DateFormat('d MMM yyyy, HH:mm').format(dt);
    }
    final dibaca = data['dibaca'] ?? 0;
    final bool isUnread = dibaca == 0;

    Color borderColor;
    IconData iconData;
    switch (prioritas) {
      case 'Darurat':
        borderColor = kRed;
        iconData = Icons.error_outline;
        break;
      case 'Penting':
        borderColor = kOrange;
        iconData = Icons.warning_amber_outlined;
        break;
      default:
        borderColor = kBlue;
        iconData = Icons.notifications_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isUnread ? const Color(0xFFFFF8E1) : kWhite,
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
                  color: borderColor.withOpacity(0.12), shape: BoxShape.circle),
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
                              color: kBlue, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(isi,
                      style:
                          GoogleFonts.lato(fontSize: 11, color: Colors.black54),
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
            GestureDetector(
              onTap: () => _hapusPengumuman(id),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close, size: 15, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
