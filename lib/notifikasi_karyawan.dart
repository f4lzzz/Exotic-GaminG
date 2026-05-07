import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'karyawan_dashboard.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum NotifType { jadwal, pesan, absen }

class NotifItem {
  final String title;
  final String desc;
  final String time;
  final String badge;
  final NotifType type;
  bool isRead;

  NotifItem({
    required this.title,
    required this.desc,
    required this.time,
    required this.badge,
    required this.type,
    this.isRead = false,
  });
}

// ─── Data dummy (nanti ganti dengan stream Firestore) ─────────────────────────

List<NotifItem> _hariIniData = [
  NotifItem(
    title: 'Jadwal Shift Kamu Hari Ini',
    desc:
        'Kamu dijadwalkan masuk Shift Siang pukul 13:00 – 21:00. Jangan lupa check-in tepat waktu.',
    time: '07:00 hari ini',
    badge: 'Shift Siang',
    type: NotifType.jadwal,
  ),
  NotifItem(
    title: 'Pesan dari Owner',
    desc:
        'Harap pastikan area meja bersih sebelum shift dimulai. Ada inspeksi mendadak sore ini pukul 16:00.',
    time: '08:30 hari ini',
    badge: 'Pengumuman',
    type: NotifType.pesan,
  ),
  NotifItem(
    title: 'Pengingat: Absen Belum Diisi',
    desc:
        'Kamu belum mengisi absensi untuk kemarin (Senin, 27 April). Segera isi sebelum pukul 23:59.',
    time: '09:00 hari ini',
    badge: 'Perlu Tindakan',
    type: NotifType.absen,
  ),
];

List<NotifItem> _kemarinData = [
  NotifItem(
    title: 'Jadwal Shift Besok',
    desc:
        'Pengingat: kamu dijadwalkan masuk Shift Pagi pukul 07:00 – 13:00 esok hari (Selasa, 28 April).',
    time: '20:00 kemarin',
    badge: 'Shift Pagi',
    type: NotifType.jadwal,
    isRead: true,
  ),
  NotifItem(
    title: 'Pesan dari Owner',
    desc:
        'Seragam baru akan dibagikan Rabu depan. Harap hadir saat pembagian sebelum shift dimulai.',
    time: '14:00 kemarin',
    badge: 'Pengumuman',
    type: NotifType.pesan,
    isRead: true,
  ),
];

// ─── Warna helper per tipe ────────────────────────────────────────────────────

Color _cardBg(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return const Color(0xFFF0F7FF);
    case NotifType.pesan:
      return const Color(0xFFFFFBEB);
    case NotifType.absen:
      return const Color(0xFFFFF5F5);
  }
}

Color _cardBorder(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return const Color(0xFFBFDBFE);
    case NotifType.pesan:
      return const Color(0xFFFDE68A);
    case NotifType.absen:
      return const Color(0xFFFECACA);
  }
}

Color _accentBar(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return kBlue;
    case NotifType.pesan:
      return kOrange;
    case NotifType.absen:
      return kRed;
  }
}

Color _iconBg(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return const Color(0xFFDBEAFE);
    case NotifType.pesan:
      return const Color(0xFFFEF3C7);
    case NotifType.absen:
      return const Color(0xFFFEE2E2);
  }
}

Color _titleColor(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return kTextDark;
    case NotifType.pesan:
      return const Color(0xFFB45309);
    case NotifType.absen:
      return kRed;
  }
}

IconData _notifIcon(NotifType t) {
  switch (t) {
    case NotifType.jadwal:
      return Icons.calendar_today_rounded;
    case NotifType.pesan:
      return Icons.chat_bubble_rounded;
    case NotifType.absen:
      return Icons.timer_off_rounded;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotifikasiKaryawanScreen extends StatefulWidget {
  const NotifikasiKaryawanScreen({super.key});

  @override
  State<NotifikasiKaryawanScreen> createState() =>
      _NotifikasiKaryawanScreenState();
}

class _NotifikasiKaryawanScreenState extends State<NotifikasiKaryawanScreen> {
  int _selectedTab = 0; // 0=Semua 1=Jadwal 2=Pesan 3=Absen
  final List<String> _tabs = ['Semua', 'Jadwal', 'Pesan', 'Absen'];

  List<NotifItem> get _allItems => [..._hariIniData, ..._kemarinData];

  int get _totalBelumBaca => _allItems.where((e) => !e.isRead).length;
  int get _totalPerluAksi =>
      _allItems.where((e) => e.type == NotifType.absen && !e.isRead).length;

  List<NotifItem> _filtered(List<NotifItem> items) {
    if (_selectedTab == 0) return items;
    final types = [null, NotifType.jadwal, NotifType.pesan, NotifType.absen];
    return items.where((e) => e.type == types[_selectedTab]).toList();
  }

  void _hapusNotif(NotifItem item) {
    setState(() {
      _hariIniData.remove(item);
      _kemarinData.remove(item);
    });
  }

  void _hapusSemua() {
    setState(() {
      _hariIniData.clear();
      _kemarinData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTabs(),
                  if (_filtered(_hariIniData).isNotEmpty) ...[
                    _sectionLabel('HARI INI'),
                    ..._filtered(_hariIniData)
                        .map((e) => _NotifCard(item: e, onDismiss: () => _hapusNotif(e))),
                  ],
                  if (_filtered(_kemarinData).isNotEmpty) ...[
                    _sectionLabel('KEMARIN'),
                    ..._filtered(_kemarinData)
                        .map((e) => _NotifCard(item: e, onDismiss: () => _hapusNotif(e))),
                  ],
                  if (_filtered(_hariIniData).isEmpty &&
                      _filtered(_kemarinData).isEmpty)
                    _buildEmpty(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kBlueBg, kBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol back
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: kWhite,
                        size: 24,
                      ),
                    ),
                  ),
                  // Brand
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.playfairDisplay(
                        color: kWhite,
                        height: 1.0,
                      ),
                      children: const [
                        TextSpan(
                          text: 'E',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: 'X',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        TextSpan(
                          text: 'OTIC  ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        TextSpan(
                          text: 'GAMING & CAFE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 2,
                            color: kWhiteDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol hapus semua
                  GestureDetector(
                    onTap: _hapusSemua,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: kWhite,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Stat cards
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _statCard(
                        icon: Icons.notifications_active_rounded,
                        iconColor: kBlue,
                        value: _allItems.length.toString(),
                        label: 'TOTAL',
                        showDivider: true,
                      ),
                      _statCard(
                        icon: Icons.chat_bubble_rounded,
                        iconColor: kOrange,
                        value: _totalBelumBaca.toString(),
                        label: 'BELUM BACA',
                        showDivider: true,
                      ),
                      _statCard(
                        icon: Icons.timer_off_rounded,
                        iconColor: kRed,
                        value: _totalPerluAksi.toString(),
                        label: 'PERLU AKSI',
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool showDivider,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: showDivider
              ? const Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 0.5))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: kTextDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                color: Colors.black38,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tabs ────────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            final active = _selectedTab == i;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? kBlue : kWhite,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? kBlue : Colors.black12,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _tabs[i],
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: active ? kWhite : Colors.black45,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.black12, thickness: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Colors.black38,
                letterSpacing: 1,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.black12, thickness: 0.5)),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          const Icon(Icons.notifications_off_outlined, size: 52, color: Colors.black12),
          const SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black26,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notif Card ───────────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotifItem item;
  final VoidCallback onDismiss;

  const _NotifCard({required this.item, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg(item.type),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder(item.type), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Accent bar kiri
              Container(width: 4, color: _accentBar(item.type)),

              // Konten
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 40, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: _iconBg(item.type),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _notifIcon(item.type),
                          color: _accentBar(item.type),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Teks
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _titleColor(item.type),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.desc,
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded,
                                    size: 11, color: Colors.black26),
                                const SizedBox(width: 4),
                                Text(
                                  item.time,
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    color: Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _iconBg(item.type),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                item.badge,
                                style: GoogleFonts.lato(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: _titleColor(item.type),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tombol X
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: GestureDetector(
                  onTap: onDismiss,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12, color: Colors.black38),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}