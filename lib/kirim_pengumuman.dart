import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profil_owner.dart';
import 'notifikasi_owner.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kBgLight = Color(0xFFF0F4FF);

class KirimPengumumanScreen extends StatefulWidget {
  const KirimPengumumanScreen({super.key});

  @override
  State<KirimPengumumanScreen> createState() => _KirimPengumumanScreenState();
}

class _KirimPengumumanScreenState extends State<KirimPengumumanScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  bool _isSending = false;
  bool _sentSuccess = false;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  String _ownerUsername = 'owner';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;

  List<Map<String, dynamic>> _riwayat = [];
  bool _loadingRiwayat = true;
  bool _isDeletingAll = false;

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();

    _scrollCtrl.addListener(() {
      setState(() {
        _scrollOffset = _scrollCtrl.offset;
      });
    });

    _loadUserData();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _scrollCtrl.dispose();
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _userData = data;
          _ownerUsername = data?['username'] ?? 'owner';
        });
      }
    } catch (_) {}
  }

  Future<void> _loadRiwayat() async {
    setState(() => _loadingRiwayat = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('pengumuman')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();
      setState(() {
        _riwayat = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
        _loadingRiwayat = false;
      });
    } catch (_) {
      setState(() => _loadingRiwayat = false);
    }
  }

  Future<void> _kirimPengumuman() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final pengirim = _ownerUsername;
      await FirebaseFirestore.instance.collection('pengumuman').add({
        'judul': _judulCtrl.text.trim(),
        'isi': _isiCtrl.text.trim(),
        'target': 'Semua',
        'prioritas': 'Normal',
        'pengirim': pengirim,
        'pengirim_email': user?.email ?? 'owner',
        'timestamp': FieldValue.serverTimestamp(),
        'dibaca': 0,
      });

      setState(() {
        _isSending = false;
        _sentSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _sentSuccess = false;
          _judulCtrl.clear();
          _isiCtrl.clear();
        });
        _loadRiwayat();
        _showSnack('Pengumuman berhasil dikirim! 🎉', kGreen);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showSnack('Gagal mengirim: $e', kRed);
    }
  }

  Future<void> _hapusPengumuman(String id, String judul) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Pengumuman?',
          style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kRed),
        ),
        content: Text(
          'Yakin hapus pengumuman "$judul"?',
          style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.lato(color: Colors.black45),
            ),
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

    try {
      await FirebaseFirestore.instance
          .collection('pengumuman')
          .doc(id)
          .delete();
      _showSnack('Pengumuman dihapus', kGreen);
      await _loadRiwayat();
    } catch (e) {
      _showSnack('Gagal menghapus: $e', kRed);
    }
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
            child: Text(
              'Batal',
              style: GoogleFonts.lato(color: Colors.black45),
            ),
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
      final snapshot = await FirebaseFirestore.instance
          .collection('pengumuman')
          .get();
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _showSnack('Semua pengumuman berhasil dihapus', kGreen);
      await _loadRiwayat();
    } catch (e) {
      _showSnack('Gagal menghapus: $e', kRed);
    } finally {
      if (mounted) setState(() => _isDeletingAll = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.lato(fontWeight: FontWeight.w700, color: kWhite),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> item) {
    final prioritas = item['prioritas'] ?? 'Normal';
    final Color pColor = prioritas == 'Darurat'
        ? kRed
        : prioritas == 'Penting'
        ? const Color(0xFFFF9800)
        : kBlue;
    final ts = item['timestamp'];
    String waktu = '';
    if (ts != null && ts is Timestamp) {
      final dt = ts.toDate();
      waktu =
          '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    String pengirim = item['pengirim'] ?? 'owner';
    if (pengirim.contains('@')) {
      pengirim = pengirim.split('@').first;
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
            maxWidth: 400,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
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
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
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
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: pColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
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
                          Text(
                            item['judul'] ?? 'Pengumuman',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: kTextDark,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: pColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  prioritas,
                                  style: GoogleFonts.lato(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: pColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.people_outline,
                                size: 12,
                                color: Colors.black38,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item['target'] ?? 'Semua',
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: Colors.black38,
                                ),
                              ),
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
                      Text(
                        item['isi'] ?? '',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          height: 1.4,
                          color: kTextDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.black12),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Pengirim: $pengirim',
                              style: GoogleFonts.lato(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            waktu,
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            softWrap: true,
                          ),
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
                      foregroundColor: kBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
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
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 24),
                    _buildRiwayatSection(),
                  ],
                ),
              ),
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

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerIconBtn(
          Icons.settings_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilOwnerScreen(userData: _userData),
            ),
          ),
        ),
        const SizedBox(width: 6),
        _headerIconBtn(
          Icons.notifications_outlined,
          badge: 3,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiOwnerScreen()),
          ),
        ),
      ],
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
                    logoWidget,
                    const SizedBox(width: 6),
                    Opacity(opacity: subOpacity, child: subWidget),
                    const Spacer(),
                    iconButtons,
                  ],
                ),
              ],
            )
          : Row(
              children: [
                logoWidget,
                const SizedBox(width: 8),
                subWidget,
                const Spacer(),
                iconButtons,
              ],
            ),
    );
  }

  Widget _headerIconBtn(
    IconData icon, {
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: kRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Judul Pengumuman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulCtrl,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextDark,
              ),
              decoration: _inputDecoration(
                'Masukkan judul pengumuman...',
                Icons.title,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            _label('Isi Pengumuman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _isiCtrl,
              style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
              maxLines: 5,
              decoration: _inputDecoration(
                'Tulis isi pengumuman di sini...',
                Icons.edit_note,
              ).copyWith(alignLabelWithHint: true),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Isi pengumuman wajib diisi'
                  : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _sentSuccess
                    ? _successBtn()
                    : _isSending
                    ? _loadingBtn()
                    : _sendBtn(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendBtn() {
    return ElevatedButton.icon(
      key: const ValueKey('send'),
      onPressed: _kirimPengumuman,
      icon: const Icon(Icons.send_rounded, size: 20),
      label: Text(
        'KIRIM PENGUMUMAN',
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: kBlue.withOpacity(0.4),
      ),
    );
  }

  Widget _loadingBtn() {
    return Container(
      key: const ValueKey('loading'),
      decoration: BoxDecoration(
        color: kBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: kWhite, strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _successBtn() {
    return Container(
      key: const ValueKey('success'),
      decoration: BoxDecoration(
        color: kGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: kWhite, size: 22),
          const SizedBox(width: 8),
          Text(
            'TERKIRIM!',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: kWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: kBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              'RIWAYAT PENGUMUMAN',
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: kTextDark,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            if (!_loadingRiwayat && _riwayat.isNotEmpty)
              _actionBtn(
                Icons.delete_sweep,
                kRed,
                _hapusSemuaPengumuman,
                isLoading: _isDeletingAll,
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingRiwayat)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: kBlue),
            ),
          )
        else if (_riwayat.isEmpty)
          _emptyRiwayat()
        else
          ..._riwayat.map((item) => _riwayatCard(item)),
      ],
    );
  }

  Widget _actionBtn(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              )
            : Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _emptyRiwayat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text('📭', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'Belum ada pengumuman',
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
            ),
          ),
          Text(
            'Pengumuman yang kamu kirim\nakan muncul di sini',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(fontSize: 12, color: Colors.black26),
          ),
        ],
      ),
    );
  }

  Widget _riwayatCard(Map<String, dynamic> item) {
    final prioritas = item['prioritas'] ?? 'Normal';
    final Color pColor = prioritas == 'Darurat'
        ? kRed
        : prioritas == 'Penting'
        ? const Color(0xFFFF9800)
        : kBlue;
    final ts = item['timestamp'];
    String waktu = '';
    if (ts != null && ts is Timestamp) {
      final dt = ts.toDate();
      waktu =
          '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final id = item['id'] as String?;

    return GestureDetector(
      onTap: () => _showDetailDialog(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: pColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: pColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  prioritas == 'Darurat'
                      ? Icons.error_outline
                      : prioritas == 'Penting'
                      ? Icons.warning_amber_outlined
                      : Icons.notifications_outlined,
                  color: pColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['judul'] ?? '-',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: kTextDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (id != null) {
                            _hapusPengumuman(id, item['judul'] ?? 'Pengumuman');
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: kRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: kRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['isi'] ?? '',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 12,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item['target'] ?? 'Semua',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 11, color: Colors.black26),
                      const SizedBox(width: 3),
                      Text(
                        waktu,
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: Colors.black26,
                        ),
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

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: kTextDark,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black26),
      prefixIcon: Icon(icon, color: kBlue, size: 20),
      filled: true,
      fillColor: kBgLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kRed, width: 1.5),
      ),
    );
  }
}
