import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/models.dart';
import 'services/firestore_service.dart';

// ─── Constants ─────────────────────────────────────────────────────────────────

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kOrange = Color(0xFFFFA500);
const kRed = Color(0xFFE53935);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kTextDark = Color(0xFF1A237E);
const kBgLight = Color(0xFFF0F4FF);

// ─── Screen ───────────────────────────────────────────────────────────────────

class NotifikasiKaryawanScreen extends StatefulWidget {
  const NotifikasiKaryawanScreen({super.key});

  @override
  State<NotifikasiKaryawanScreen> createState() =>
      _NotifikasiKaryawanScreenState();
}

class _NotifikasiKaryawanScreenState extends State<NotifikasiKaryawanScreen> {
  int _selectedTab = 0; // 0=Semua 1=Pengumuman 2=Jadwal 3=Absensi
  final List<String> _tabs = ['Semua', 'Pengumuman', 'Jadwal', 'Absensi'];
  
  late FirestoreService _firestoreService;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreService();
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  List<NotificationModel> _filterNotifications(List<NotificationModel> all) {
    if (_selectedTab == 0) {
      // Tampilkan semua notifikasi
      return all;
    }
    
    // Filter berdasarkan tab yang dipilih
    final notificationTypes = {
      1: NotificationType.pengumuman,
      2: NotificationType.jadwal,
      3: NotificationType.absensi,
    };
    
    final selectedType = notificationTypes[_selectedTab];
    if (selectedType == null) return all;
    
    return all.where((n) => n.tipe == selectedType).toList();
  }

  Future<void> _deleteNotification(String notifId) async {
    if (_currentUser == null) return;
    await _firestoreService.deleteNotification(_currentUser!.uid, notifId);
  }

  Future<void> _deleteAllNotifications() async {
    if (_currentUser == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Semua Notifikasi?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: kRed),
            child: const Text('Hapus', style: TextStyle(color: kWhite)),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _firestoreService.deleteAllNotifications(_currentUser!.uid);
    }
  }

  Future<void> _markNotificationAsRead(String notifId) async {
    if (_currentUser == null) return;
    await _firestoreService.markNotificationAsRead(_currentUser!.uid, notifId);
  }

  void _showDetailDialog(NotificationModel notif) {
    if (!notif.sudahDibaca) {
      _markNotificationAsRead(notif.id);
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [kWhite, Color(0xFFF8F9FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getAccentColor(notif.tipe).withOpacity(0.1),
                      _getAccentColor(notif.tipe).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getAccentColor(notif.tipe).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getIconFromType(notif.tipe),
                        color: _getAccentColor(notif.tipe),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getAccentColor(notif.tipe).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getTipeLabel(notif.tipe),
                              style: GoogleFonts.lato(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: _getAccentColor(notif.tipe),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notif.judul,
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: kTextDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notif.deskripsi,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          height: 1.6,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pengirim',
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.pengirim,
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: kTextDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Waktu',
                                  style: GoogleFonts.lato(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black38,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDetailTime(notif.timestamp),
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: kTextDark,
                                  ),
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(
                        'Tutup',
                        style: GoogleFonts.lato(fontWeight: FontWeight.w800),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: _getAccentColor(notif.tipe),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
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
    );
  }

  String _getTipeLabel(NotificationType tipe) {
    switch (tipe) {
      case NotificationType.pengumuman:
        return 'Pengumuman';
      case NotificationType.jadwal:
        return 'Jadwal';
      case NotificationType.absensi:
        return 'Absensi';
      case NotificationType.lainnya:
        return 'Lainnya';
    }
  }

  IconData _getIconFromType(NotificationType tipe) {
    switch (tipe) {
      case NotificationType.pengumuman:
        return Icons.chat_bubble_rounded;
      case NotificationType.jadwal:
        return Icons.calendar_today_rounded;
      case NotificationType.absensi:
        return Icons.timer_off_rounded;
      case NotificationType.lainnya:
        return Icons.notifications_rounded;
    }
  }

  Color _getAccentColor(NotificationType tipe) {
    switch (tipe) {
      case NotificationType.pengumuman:
        return kOrange;
      case NotificationType.jadwal:
        return kBlue;
      case NotificationType.absensi:
        return kRed;
      case NotificationType.lainnya:
        return Colors.grey;
    }
  }

  String _formatDetailTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Text('Silakan login terlebih dahulu',
              style: GoogleFonts.lato(color: kTextDark)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<NotificationModel>>(
              stream: _firestoreService.getNotificationsStream(_currentUser!.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifList = snapshot.data ?? [];
                final filtered = _filterNotifications(notifList);

                // Kelompokkan notifikasi berdasarkan tanggal
                final today = DateTime.now();
                final yesterday = today.subtract(const Duration(days: 1));
                
                final todayNotifs = filtered.where((n) {
                  final nDate = n.timestamp;
                  return nDate.year == today.year &&
                      nDate.month == today.month &&
                      nDate.day == today.day;
                }).toList();

                final yesterdayNotifs = filtered.where((n) {
                  final nDate = n.timestamp;
                  return nDate.year == yesterday.year &&
                      nDate.month == yesterday.month &&
                      nDate.day == yesterday.day;
                }).toList();

                final olderNotifs = filtered.where((n) {
                  final nDate = n.timestamp;
                  return !((nDate.year == today.year &&
                          nDate.month == today.month &&
                          nDate.day == today.day) ||
                      (nDate.year == yesterday.year &&
                          nDate.month == yesterday.month &&
                          nDate.day == yesterday.day));
                }).toList();

                if (filtered.isEmpty) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTabs(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 80),
                          child: Column(
                            children: [
                              const Icon(Icons.notifications_off_outlined,
                                  size: 60, color: Colors.black12),
                              const SizedBox(height: 16),
                              Text(
                                _selectedTab == 0
                                    ? 'Tidak ada notifikasi'
                                    : 'Tidak ada ${_tabs[_selectedTab].toLowerCase()}',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black26,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedTab != 0)
                                Text(
                                  'Coba tab "Semua" untuk melihat semua notifikasi',
                                  style: GoogleFonts.lato(
                                    fontSize: 12,
                                    color: Colors.black38,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTabs(),
                      if (todayNotifs.isNotEmpty) ...[
                        _sectionLabel('HARI INI'),
                        ...todayNotifs.map((n) => _NotifCard(
                          notif: n,
                          onTap: () => _showDetailDialog(n),
                          onDismiss: () => _deleteNotification(n.id),
                        )),
                      ],
                      if (yesterdayNotifs.isNotEmpty) ...[
                        _sectionLabel('KEMARIN'),
                        ...yesterdayNotifs.map((n) => _NotifCard(
                          notif: n,
                          onTap: () => _showDetailDialog(n),
                          onDismiss: () => _deleteNotification(n.id),
                        )),
                      ],
                      if (olderNotifs.isNotEmpty) ...[
                        _sectionLabel('LEBIH LAMA'),
                        ...olderNotifs.map((n) => _NotifCard(
                          notif: n,
                          onTap: () => _showDetailDialog(n),
                          onDismiss: () => _deleteNotification(n.id),
                        )),
                      ],
                      const SizedBox(height: 24),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, color: kWhite, size: 24),
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
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
                  GestureDetector(
                    onTap: _deleteAllNotifications,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: kWhite, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: StreamBuilder<List<NotificationModel>>(
                stream: _firestoreService.getNotificationsStream(_currentUser!.uid),
                builder: (context, snapshot) {
                  final allNotifs = snapshot.data ?? [];
                  final unread = allNotifs.where((n) => !n.sudahDibaca).length;
                  final pengumuman =
                      allNotifs.where((n) => n.tipe == NotificationType.pengumuman).length;

                  return Container(
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
                            value: allNotifs.length.toString(),
                            label: 'TOTAL',
                            showDivider: true,
                          ),
                          _statCard(
                            icon: Icons.mail_outline_rounded,
                            iconColor: kOrange,
                            value: pengumuman.toString(),
                            label: 'PENGUMUMAN',
                            showDivider: true,
                          ),
                          _statCard(
                            icon: Icons.mark_email_unread_rounded,
                            iconColor: kRed,
                            value: unread.toString(),
                            label: 'BELUM BACA',
                            showDivider: false,
                          ),
                        ],
                      ),
                    ),
                  );
                },
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

// ─── Notif Card Widget ─────────────────────────────────────────────────────────

class _NotifCard extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotifCard({
    required this.notif,
    required this.onTap,
    required this.onDismiss,
  });

  Color _getCardBg(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return const Color(0xFFFFFBEB);
      case NotificationType.jadwal:
        return const Color(0xFFF0F7FF);
      case NotificationType.absensi:
        return const Color(0xFFFFF5F5);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _getCardBorder(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return const Color(0xFFFDE68A);
      case NotificationType.jadwal:
        return const Color(0xFFBFDBFE);
      case NotificationType.absensi:
        return const Color(0xFFFECACA);
      default:
        return Colors.black12;
    }
  }

  Color _getAccentBar(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return kOrange;
      case NotificationType.jadwal:
        return kBlue;
      case NotificationType.absensi:
        return kRed;
      default:
        return Colors.grey;
    }
  }

  Color _getIconBg(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return const Color(0xFFFEF3C7);
      case NotificationType.jadwal:
        return const Color(0xFFDBEAFE);
      case NotificationType.absensi:
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  Color _getTitleColor(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return const Color(0xFFB45309);
      case NotificationType.jadwal:
        return kTextDark;
      case NotificationType.absensi:
        return kRed;
      default:
        return kTextDark;
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.pengumuman:
        return Icons.chat_bubble_rounded;
      case NotificationType.jadwal:
        return Icons.calendar_today_rounded;
      case NotificationType.absensi:
        return Icons.timer_off_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return 'Baru saja';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else if (diff.inDays == 1) {
      return '1 hari yang lalu';
    } else {
      return '${dt.day}/${dt.month}/${dt.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _getCardBg(notif.tipe),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getCardBorder(notif.tipe), width: 0.5),
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
                Container(width: 4, color: _getAccentBar(notif.tipe)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 14, 40, 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: _getIconBg(notif.tipe),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIcon(notif.tipe),
                            color: _getAccentBar(notif.tipe),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notif.judul,
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: _getTitleColor(notif.tipe),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.deskripsi,
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 11, color: Colors.black26),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatTime(notif.timestamp),
                                    style: GoogleFonts.lato(
                                      fontSize: 11,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getIconBg(notif.tipe),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  notif.sudahDibaca ? 'Sudah dibaca' : 'Belum dibaca',
                                  style: GoogleFonts.lato(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: _getTitleColor(notif.tipe),
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
      ),
    );
  }
}