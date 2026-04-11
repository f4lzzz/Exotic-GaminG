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

// ─── MODEL ───────────────────────────────────────────────────────────────────
enum NotifCategory { transaksi, stok, karyawan }

class NotifItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final NotifCategory category;
  final bool isUnread;

  const NotifItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.category,
    this.isUnread = false,
  });
}

// ─── DATA ────────────────────────────────────────────────────────────────────
const _allNotifs = [
  NotifItem(
    id: '1',
    title: 'Transaksi Baru — Meja 5',
    body:
        'Order baru masuk dari Meja 5: 2x Kopi Susu + 1x Roti Bakar senilai Rp 59.000',
    time: '08:00 hari ini',
    category: NotifCategory.transaksi,
    isUnread: true,
  ),
  NotifItem(
    id: '2',
    title: 'Stok Habis — Teh Hijau',
    body:
        'Stok teh hijau habis (0 pcs). Segera lakukan restock untuk menghindari kehabisan.',
    time: '08:15 hari ini',
    category: NotifCategory.stok,
    isUnread: true,
  ),
  NotifItem(
    id: '3',
    title: 'Karyawan Tidak Hadir — Bagas',
    body:
        'Karyawan Bagas Nugroho (Chef — Shift Siang) tidak hadir tanpa keterangan.',
    time: '09:00 hari ini',
    category: NotifCategory.karyawan,
    isUnread: false,
  ),
  NotifItem(
    id: '4',
    title: 'Transaksi Baru — Suite Room 2',
    body:
        'Order baru masuk dari Suite Room 2: 2x Kopi Susu + 1x Roti Bakar senilai Rp 59.000',
    time: '10:30 hari ini',
    category: NotifCategory.transaksi,
    isUnread: false,
  ),
  NotifItem(
    id: '5',
    title: 'Karyawan Tidak Hadir — Anna',
    body: 'Karyawan Anna (Chef — Shift Siang) tidak hadir tanpa keterangan.',
    time: '08:00 kemarin',
    category: NotifCategory.karyawan,
    isUnread: false,
  ),
  NotifItem(
    id: '6',
    title: 'Stok Kritis — Gula Pasir',
    body: 'Stok gula pasir tinggal 2 kg. Segera lakukan restock.',
    time: '14:00 kemarin',
    category: NotifCategory.stok,
    isUnread: false,
  ),
];

// ─── SCREEN ──────────────────────────────────────────────────────────────────
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

  NotifCategory? _selectedCategory;
  final List<String> _dismissed = [];

  List<NotifItem> get _visible => _allNotifs
      .where(
        (n) =>
            !_dismissed.contains(n.id) &&
            (_selectedCategory == null || n.category == _selectedCategory),
      )
      .toList();

  int get _totalCount => _allNotifs.length;
  int get _unreadCount => _allNotifs.where((n) => n.isUnread).length;
  int get _transaksiCount =>
      _allNotifs.where((n) => n.category == NotifCategory.transaksi).length;

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

  void _dismiss(String id) => setState(() => _dismissed.add(id));

  void _dismissAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Semua Notifikasi',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        content: Text(
          'Yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.lato(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _dismissed.addAll(_allNotifs.map((n) => n.id)));
            },
            child: Text(
              'Hapus Semua',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w800,
                color: kWhite,
              ),
            ),
          ),
        ],
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
                  _buildFilterTabs(),
                  const SizedBox(height: 12),
                  _buildNotifList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER (sama persis owner dashboard) ────────────────────────────────
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
      onTap: _dismissAll,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: kWhite, size: 20),
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
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: kWhite, size: 16),
      ),
    );
  }

  // ─── SUMMARY ROW ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'TOTAL',
            '$_totalCount',
            Icons.notifications_active,
            kBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'BELUM BACA',
            '$_unreadCount',
            Icons.mark_chat_unread,
            kOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            'TRANSAKSI',
            '$_transaksiCount',
            Icons.attach_money,
            kGreen,
          ),
        ),
      ],
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 2),
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
    );
  }

  // ─── FILTER TABS ─────────────────────────────────────────────────────────
  Widget _buildFilterTabs() {
    final tabs = <String, NotifCategory?>{
      'SEMUA': null,
      'TRANSAKSI': NotifCategory.transaksi,
      'STOK': NotifCategory.stok,
      'KARYAWAN': NotifCategory.karyawan,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.entries.map((e) {
          final isActive = _selectedCategory == e.value;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = e.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? kBlue : kWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                e.key,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isActive ? kWhite : Colors.black45,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── NOTIF LIST ──────────────────────────────────────────────────────────
  Widget _buildNotifList() {
    final items = _visible;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 52,
                color: Colors.black26,
              ),
              const SizedBox(height: 12),
              Text(
                'Tidak ada notifikasi',
                style: GoogleFonts.lato(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }

    final hariIni = items.where((n) => n.time.contains('hari ini')).toList();
    final lebihLama = items.where((n) => !n.time.contains('hari ini')).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hariIni.isNotEmpty) ...[
          _sectionLabel('HARI INI'),
          ...hariIni.map((n) => _notifCard(n)),
        ],
        if (lebihLama.isNotEmpty) ...[
          const SizedBox(height: 4),
          _sectionLabel('LEBIH LAMA'),
          ...lebihLama.map((n) => _notifCard(n)),
        ],
      ],
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
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      ),
    );
  }

  Widget _notifCard(NotifItem n) {
    final color = _categoryColor(n.category);
    final icon = _categoryIcon(n.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: n.isUnread ? const Color(0xFFFFF8E1) : kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
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
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
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
                          n.title,
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: n.isUnread
                                ? FontWeight.w800
                                : FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      if (n.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 2),
                          decoration: const BoxDecoration(
                            color: kBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 11,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        n.time,
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
            GestureDetector(
              onTap: () => _dismiss(n.id),
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 15, color: Colors.black38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(NotifCategory cat) {
    switch (cat) {
      case NotifCategory.transaksi:
        return kBlue;
      case NotifCategory.stok:
        return kOrange;
      case NotifCategory.karyawan:
        return kRed;
    }
  }

  IconData _categoryIcon(NotifCategory cat) {
    switch (cat) {
      case NotifCategory.transaksi:
        return Icons.attach_money_rounded;
      case NotifCategory.stok:
        return Icons.warning_amber_rounded;
      case NotifCategory.karyawan:
        return Icons.person_off_rounded;
    }
  }
}
