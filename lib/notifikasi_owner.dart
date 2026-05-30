import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'service/exotic_sound_service.dart';

const _noBlue = Color(0xFF1A5EBF);
const _noBlueBg = Color(0xFF4A90D9);
const _noWhite = Color(0xFFFFFFFF);
const _noWhiteDim = Color(0xFFDDE8FF);
const _noTextDark = Color(0xFF1A237E);
const _noGreen = Color(0xFF4CAF50);
const _noRed = Color(0xFFE53935);
const _noOrange = Color(0xFFFF9800);
const _noPurple = Color(0xFF7C4DFF);
const _noBgLight = Color(0xFFF0F4FF);

class NotifikasiOwnerScreen extends StatefulWidget {
  const NotifikasiOwnerScreen({super.key});

  @override
  State<NotifikasiOwnerScreen> createState() => _NotifikasiOwnerScreenState();
}

class _NotifikasiOwnerScreenState extends State<NotifikasiOwnerScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  final _tabs = ['Semua', 'Absensi', 'Pengumuman'];
  final _sound = ExoticSoundService();

  final Set<String> _knownIds = {};
  bool _firstLoad = true;

  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  bool _isDeletingAllPeng = false;
  bool _isMarkingAllReadPeng = false;
  bool _isDeletingAllAbs = false;
  bool _isMarkingAllReadAbs = false;
  bool _isDeletingAllCombined = false;
  bool _isMarkingAllReadCombined = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Helper: format nama pengirim hanya username (sebelum @ atau kata pertama)
  String _formatPengirim(String pengirim) {
    if (pengirim.contains('@')) return pengirim.split('@').first;
    final parts = pengirim.trim().split(' ');
    if (parts.length > 1) return parts[0];
    return pengirim;
  }

  // ==================== FUNGSI PENGUMUMAN ====================
  Future<void> _hapusSemuaPengumuman() async {
    final confirm = await _confirmDialog('Hapus Semua Pengumuman?',
        'Semua pengumuman akan dihapus permanen.', _noRed);
    if (confirm != true) return;
    setState(() => _isDeletingAllPeng = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('pengumuman').get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) batch.delete(doc.reference);
      await batch.commit();
      _showSnack('Semua pengumuman berhasil dihapus', _noGreen);
    } catch (e) {
      _showSnack('Gagal menghapus: $e', _noRed);
    } finally {
      if (mounted) setState(() => _isDeletingAllPeng = false);
    }
  }

  Future<void> _tandaiSemuaPengumumanBaca() async {
    final confirm = await _confirmDialog(
        'Tandai Semua Pengumuman Telah Dibaca?',
        'Semua pengumuman akan ditandai sebagai sudah dibaca.',
        _noBlue);
    if (confirm != true) return;
    setState(() => _isMarkingAllReadPeng = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pengumuman')
          .where('dibaca', isEqualTo: 0)
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) batch.update(doc.reference, {'dibaca': 1});
      await batch.commit();
      _showSnack('Semua pengumuman ditandai telah dibaca', _noGreen);
    } catch (e) {
      _showSnack('Gagal: $e', _noRed);
    } finally {
      if (mounted) setState(() => _isMarkingAllReadPeng = false);
    }
  }

  Future<void> _hapusPengumuman(String id) async {
    final confirm = await _confirmDialog(
        'Hapus Pengumuman?', 'Yakin hapus pengumuman ini?', _noRed);
    if (confirm != true) return;
    try {
      await FirebaseFirestore.instance
          .collection('pengumuman')
          .doc(id)
          .delete();
      _showSnack('Pengumuman dihapus', _noGreen);
    } catch (e) {
      _showSnack('Gagal menghapus: $e', _noRed);
    }
  }

  Future<void> _markPengumumanAsRead(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('pengumuman')
          .doc(id)
          .update({'dibaca': 1});
    } catch (e) {}
  }

  void _showDetailDialogPengumuman(Map<String, dynamic> data, String id) async {
    if (data['dibaca'] == 0) await _markPengumumanAsRead(id);
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

  // ==================== FUNGSI ABSENSI (notif_owner) ====================
  Future<void> _tandaiBacaAbsensi(String id) async {
    await FirebaseFirestore.instance
        .collection('notif_owner')
        .doc(id)
        .update({'dibaca': true});
  }

  Future<void> _tandaiSemuaAbsensiBaca() async {
    final confirm = await _confirmDialog('Tandai Semua Notifikasi Absensi?',
        'Semua notifikasi absensi akan ditandai sudah dibaca.', _noBlue);
    if (confirm != true) return;
    setState(() => _isMarkingAllReadAbs = true);
    final snap = await FirebaseFirestore.instance
        .collection('notif_owner')
        .where('dibaca', isEqualTo: false)
        .get();
    for (var doc in snap.docs) await doc.reference.update({'dibaca': true});
    if (mounted) setState(() => _isMarkingAllReadAbs = false);
    _showSnack('Semua notifikasi absensi ditandai dibaca', _noGreen);
  }

  Future<void> _hapusSemuaAbsensi() async {
    final confirm = await _confirmDialog('Hapus Semua Notifikasi Absensi?',
        'Semua notifikasi absensi akan dihapus permanen.', _noRed);
    if (confirm != true) return;
    setState(() => _isDeletingAllAbs = true);
    final snap =
        await FirebaseFirestore.instance.collection('notif_owner').get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snap.docs) batch.delete(doc.reference);
    await batch.commit();
    if (mounted) setState(() => _isDeletingAllAbs = false);
    _showSnack('Semua notifikasi absensi dihapus', _noGreen);
  }

  void _showDetailDialogAbsensi(Map<String, dynamic> data) {
    final type = data['type'] ?? 'absensi';
    final jam = data['jam'] ?? '';
    final nama = data['namaKaryawan'] ?? data['nama'] ?? 'Karyawan';
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _noWhite,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(type == 'masuk' ? Icons.login : Icons.logout,
                  size: 48, color: _noBlue),
              const SizedBox(height: 12),
              Text(data['judul'] ?? 'Notifikasi Absensi',
                  style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: _noTextDark)),
              const SizedBox(height: 8),
              Text(
                  '$nama ${type == 'masuk' ? 'masuk' : 'pulang'} pada jam $jam',
                  style: GoogleFonts.lato(fontSize: 13, color: Colors.black54)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Tutup',
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w800, color: _noBlue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== FUNGSI GABUNGAN (Semua) ====================
  Future<void> _tandaiSemuaCombinedBaca() async {
    final confirm = await _confirmDialog(
        'Tandai Semua Notifikasi?',
        'Semua notifikasi (absensi & pengumuman) akan ditandai sudah dibaca.',
        _noBlue);
    if (confirm != true) return;
    setState(() => _isMarkingAllReadCombined = true);
    final snapAbs = await FirebaseFirestore.instance
        .collection('notif_owner')
        .where('dibaca', isEqualTo: false)
        .get();
    for (var doc in snapAbs.docs) await doc.reference.update({'dibaca': true});
    final snapPeng = await FirebaseFirestore.instance
        .collection('pengumuman')
        .where('dibaca', isEqualTo: 0)
        .get();
    for (var doc in snapPeng.docs) await doc.reference.update({'dibaca': 1});
    if (mounted) setState(() => _isMarkingAllReadCombined = false);
    _showSnack('Semua notifikasi ditandai dibaca', _noGreen);
  }

  Future<void> _hapusSemuaCombined() async {
    final confirm = await _confirmDialog(
        'Hapus Semua Notifikasi?',
        'Semua notifikasi (absensi & pengumuman) akan dihapus permanen.',
        _noRed);
    if (confirm != true) return;
    setState(() => _isDeletingAllCombined = true);
    final snapAbs =
        await FirebaseFirestore.instance.collection('notif_owner').get();
    final snapPeng =
        await FirebaseFirestore.instance.collection('pengumuman').get();
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in snapAbs.docs) batch.delete(doc.reference);
    for (var doc in snapPeng.docs) batch.delete(doc.reference);
    await batch.commit();
    if (mounted) setState(() => _isDeletingAllCombined = false);
    _showSnack('Semua notifikasi dihapus', _noGreen);
  }

  Future<bool?> _confirmDialog(String title, String content, Color color) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: color)),
        content: Text(content,
            style: GoogleFonts.lato(fontSize: 13, color: _noTextDark)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Batal',
                  style: GoogleFonts.lato(color: Colors.black45))),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: color),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('Ya', style: GoogleFonts.lato(color: _noWhite))),
        ],
      ),
    );
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.lato(color: _noWhite)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ==================== UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _noBgLight,
      body: Column(
        children: [
          FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
          _buildTabBar(),
          Expanded(
            child: IndexedStack(
              index: _tabIndex,
              children: [
                _buildCombinedStream(),
                _buildAbsensiStream(),
                _buildPengumumanStream(),
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
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;

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

    Widget actionButtons;
    if (_tabIndex == 2) {
      actionButtons = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _tandaiSemuaPengumumanBaca,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isMarkingAllReadPeng
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.done_all_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _hapusSemuaPengumuman,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isDeletingAllPeng
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.delete_sweep_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
        ],
      );
    } else if (_tabIndex == 1) {
      actionButtons = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _tandaiSemuaAbsensiBaca,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isMarkingAllReadAbs
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.done_all_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _hapusSemuaAbsensi,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isDeletingAllAbs
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.delete_sweep_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
        ],
      );
    } else {
      actionButtons = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _tandaiSemuaCombinedBaca,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isMarkingAllReadCombined
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.done_all_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _hapusSemuaCombined,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: _isDeletingAllCombined
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: _noWhite))
                  : const Icon(Icons.delete_sweep_rounded,
                      color: _noWhite, size: 20),
            ),
          ),
        ],
      );
    }

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
            color: _noWhite.withOpacity(0.2), shape: BoxShape.circle),
        child: const Icon(Icons.arrow_back_ios_new, color: _noWhite, size: 16),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: _noWhite,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Container(
                margin: EdgeInsets.only(right: i < _tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? _noBlue : _noBgLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isActive ? _noWhite : Colors.black45)),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ==================== STREAM SEMUA (gabungan) ====================
  Widget _buildCombinedStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notif_owner')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, notifSnap) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('pengumuman')
              .orderBy('timestamp', descending: true)
              .snapshots(),
          builder: (context, pengSnap) {
            if (notifSnap.hasData && !_firstLoad) {
              final currentIds = notifSnap.data!.docs.map((d) => d.id).toSet();
              final newIds = currentIds.difference(_knownIds);
              if (newIds.isNotEmpty) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _sound.playNotif());
              }
              _knownIds.clear();
              _knownIds.addAll(currentIds);
            }
            _firstLoad = false;

            final List<_CombinedItem> items = [];

            if (notifSnap.hasData) {
              for (var doc in notifSnap.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                items.add(_CombinedItem(
                  id: doc.id,
                  judul: d['judul'] ?? 'Notifikasi Absensi',
                  isi: d['isi'] ?? '',
                  tipe: 'absensi',
                  waktu: (d['timestamp'] as Timestamp?)?.toDate(),
                  dibaca: d['dibaca'] == true,
                  extra: d,
                ));
              }
            }
            if (pengSnap.hasData) {
              for (var doc in pengSnap.data!.docs) {
                final d = doc.data() as Map<String, dynamic>;
                items.add(_CombinedItem(
                  id: doc.id,
                  judul: d['judul'] ?? 'Pengumuman',
                  isi: d['isi'] ?? '',
                  tipe: 'pengumuman',
                  waktu: (d['timestamp'] as Timestamp?)?.toDate(),
                  dibaca: d['dibaca'] == 1,
                  extra: d,
                ));
              }
            }

            items.sort((a, b) {
              if (a.waktu == null && b.waktu == null) return 0;
              if (a.waktu == null) return 1;
              if (b.waktu == null) return -1;
              return b.waktu!.compareTo(a.waktu!);
            });

            if (items.isEmpty) return _emptyState('Belum ada notifikasi');

            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final yesterday = today.subtract(const Duration(days: 1));

            final todayItems = items
                .where((i) =>
                    i.waktu != null &&
                    DateTime(i.waktu!.year, i.waktu!.month, i.waktu!.day) ==
                        today)
                .toList();
            final yesterdayItems = items
                .where((i) =>
                    i.waktu != null &&
                    DateTime(i.waktu!.year, i.waktu!.month, i.waktu!.day) ==
                        yesterday)
                .toList();
            final olderItems = items
                .where((i) =>
                    i.waktu == null ||
                    DateTime(i.waktu!.year, i.waktu!.month, i.waktu!.day)
                        .isBefore(yesterday))
                .toList();

            return ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                if (todayItems.isNotEmpty) ...[
                  _sectionLabel('HARI INI'),
                  ...todayItems.map((i) => _buildCombinedCard(i))
                ],
                if (yesterdayItems.isNotEmpty) ...[
                  _sectionLabel('KEMARIN'),
                  ...yesterdayItems.map((i) => _buildCombinedCard(i))
                ],
                if (olderItems.isNotEmpty) ...[
                  _sectionLabel('SEBELUMNYA'),
                  ...olderItems.map((i) => _buildCombinedCard(i))
                ],
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCombinedCard(_CombinedItem item) {
    final isAbsensi = item.tipe == 'absensi';
    final color = isAbsensi ? _noBlue : _noOrange;
    final icon = isAbsensi
        ? (item.extra['type'] == 'masuk' ? Icons.login : Icons.logout)
        : Icons.campaign_outlined;
    final waktuStr =
        item.waktu != null ? DateFormat('HH:mm').format(item.waktu!) : '';

    return GestureDetector(
      onTap: () {
        if (isAbsensi) {
          _showDetailDialogAbsensi(item.extra);
          if (!item.dibaca) _tandaiBacaAbsensi(item.id);
        } else {
          _showDetailDialogPengumuman(item.extra, item.id);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: item.dibaca ? _noWhite : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: item.dibaca
              ? null
              : Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(item.judul,
                            style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _noTextDark))),
                    if (!item.dibaca)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 4),
                  Text(item.isi,
                      style:
                          GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(waktuStr,
                          style: GoogleFonts.lato(
                              fontSize: 10, color: Colors.black38)),
                      if (isAbsensi && item.extra['jam'] != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item.extra['type'] == 'masuk'
                                    ? _noGreen
                                    : _noOrange)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item.extra['type'] == 'masuk' ? 'Masuk' : 'Pulang'} ${item.extra['jam']}',
                            style: GoogleFonts.lato(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: item.extra['type'] == 'masuk'
                                    ? _noGreen
                                    : _noOrange),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STREAM ABSENSI ====================
  Widget _buildAbsensiStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('notif_owner')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: _noBlue));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return _emptyState('Belum ada notifikasi absensi');

        final docs = snapshot.data!.docs;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final List<QueryDocumentSnapshot> todayItems = [];
        final List<QueryDocumentSnapshot> yesterdayItems = [];
        final List<QueryDocumentSnapshot> olderItems = [];

        for (var doc in docs) {
          final ts = doc['timestamp'] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            if (DateTime(date.year, date.month, date.day) == today)
              todayItems.add(doc);
            else if (DateTime(date.year, date.month, date.day) == yesterday)
              yesterdayItems.add(doc);
            else
              olderItems.add(doc);
          } else {
            olderItems.add(doc);
          }
        }

        return ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (todayItems.isNotEmpty) ...[
              _sectionLabel('HARI INI'),
              ...todayItems.map((doc) => _buildAbsensiCard(doc))
            ],
            if (yesterdayItems.isNotEmpty) ...[
              _sectionLabel('KEMARIN'),
              ...yesterdayItems.map((doc) => _buildAbsensiCard(doc))
            ],
            if (olderItems.isNotEmpty) ...[
              _sectionLabel('SEBELUMNYA'),
              ...olderItems.map((doc) => _buildAbsensiCard(doc))
            ],
          ],
        );
      },
    );
  }

  Widget _buildAbsensiCard(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final id = doc.id;
    final judul = data['judul'] ?? 'Notifikasi Absensi';
    final isi = data['isi'] ?? '';
    final ts = data['timestamp'] as Timestamp?;
    final waktuStr = ts != null ? DateFormat('HH:mm').format(ts.toDate()) : '';
    final dibaca = data['dibaca'] == true;
    final type = data['type'] ?? 'absensi';
    final jam = data['jam'] ?? '';
    final color = _noBlue;
    final icon = type == 'masuk' ? Icons.login : Icons.logout;

    return GestureDetector(
      onTap: () {
        _showDetailDialogAbsensi(data);
        if (!dibaca) _tandaiBacaAbsensi(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dibaca ? _noWhite : color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: dibaca
              ? null
              : Border.all(color: color.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child: Text(judul,
                            style: GoogleFonts.lato(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: _noTextDark))),
                    if (!dibaca)
                      Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                  ]),
                  const SizedBox(height: 4),
                  Text(isi,
                      style:
                          GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 10, color: Colors.black38),
                      const SizedBox(width: 4),
                      Text(waktuStr,
                          style: GoogleFonts.lato(
                              fontSize: 10, color: Colors.black38)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (type == 'masuk' ? _noGreen : _noOrange)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                            '${type == 'masuk' ? 'Masuk' : 'Pulang'} $jam',
                            style: GoogleFonts.lato(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: type == 'masuk' ? _noGreen : _noOrange)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== STREAM PENGUMUMAN (lengkap) ====================
  Widget _buildPengumumanStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator(color: _noBlue));
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
          return _emptyState('Belum ada pengumuman');

        final docs = snapshot.data!.docs;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final List<QueryDocumentSnapshot> todayItems = [];
        final List<QueryDocumentSnapshot> yesterdayItems = [];
        final List<QueryDocumentSnapshot> olderItems = [];

        for (var doc in docs) {
          final ts = doc['timestamp'] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            if (DateTime(date.year, date.month, date.day) == today)
              todayItems.add(doc);
            else if (DateTime(date.year, date.month, date.day) == yesterday)
              yesterdayItems.add(doc);
            else
              olderItems.add(doc);
          } else {
            olderItems.add(doc);
          }
        }

        return ListView(
          controller: _scrollCtrl,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (todayItems.isNotEmpty) ...[
              _sectionLabel('HARI INI'),
              ...todayItems.map((doc) => _buildPengumumanCard(doc))
            ],
            if (yesterdayItems.isNotEmpty) ...[
              _sectionLabel('KEMARIN'),
              ...yesterdayItems.map((doc) => _buildPengumumanCard(doc))
            ],
            if (olderItems.isNotEmpty) ...[
              _sectionLabel('SEBELUMNYA'),
              ...olderItems.map((doc) => _buildPengumumanCard(doc))
            ],
          ],
        );
      },
    );
  }

  Widget _buildPengumumanCard(QueryDocumentSnapshot doc) {
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
      onTap: () => _showDetailDialogPengumuman(data, id),
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
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _hapusPengumuman(id),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8)),
                  child:
                      const Icon(Icons.close, size: 15, color: Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(label,
          style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.black38,
              letterSpacing: 0.8)),
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_off_outlined,
              size: 56, color: Colors.black26),
          const SizedBox(height: 14),
          Text(message,
              style: GoogleFonts.lato(fontSize: 13, color: Colors.black38)),
        ],
      ),
    );
  }
}

class _CombinedItem {
  final String id;
  final String judul;
  final String isi;
  final String tipe;
  final DateTime? waktu;
  final bool dibaca;
  final Map<String, dynamic> extra;
  _CombinedItem(
      {required this.id,
      required this.judul,
      required this.isi,
      required this.tipe,
      required this.waktu,
      required this.dibaca,
      required this.extra});
}
