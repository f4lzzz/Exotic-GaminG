import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const _kBlue = Color(0xFF1A5EBF);
const _kBlueBg = Color(0xFF4A90D9);
const _kWhite = Color(0xFFFFFFFF);
const _kWhiteDim = Color(0xFFDDE8FF);
const _kTextDark = Color(0xFF1A237E);
const _kRed = Color(0xFFE53935);
const _kGreen = Color(0xFF4CAF50);
const _kBgLight = Color(0xFFF0F4FF);

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

  String _selectedTarget = 'Semua';
  String _selectedPrioritas = 'Normal';
  bool _isSending = false;
  bool _sentSuccess = false;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final List<String> _targetOptions = ['Semua', 'Karyawan', 'Kasir', 'Dapur'];
  final List<Map<String, dynamic>> _prioritasOptions = [
    {'label': 'Normal', 'color': _kBlue, 'icon': Icons.info_outline},
    {'label': 'Penting', 'color': Color(0xFFFF9800), 'icon': Icons.warning_amber_outlined},
    {'label': 'Darurat', 'color': _kRed, 'icon': Icons.error_outline},
  ];

  List<Map<String, dynamic>> _riwayat = [];
  bool _loadingRiwayat = true;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadRiwayat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('pengumuman')
          .orderBy('timestamp', descending: true)
          .limit(10)
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
      await FirebaseFirestore.instance.collection('pengumuman').add({
        'judul': _judulCtrl.text.trim(),
        'isi': _isiCtrl.text.trim(),
        'target': _selectedTarget,
        'prioritas': _selectedPrioritas,
        'pengirim': user?.email ?? 'owner',
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
          _selectedTarget = 'Semua';
          _selectedPrioritas = 'Normal';
        });
        _loadRiwayat();
        _showSnack('Pengumuman berhasil dikirim! 🎉', _kGreen);
      }
    } catch (e) {
      setState(() => _isSending = false);
      _showSnack('Gagal mengirim: $e', _kRed);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(fontWeight: FontWeight.w700, color: _kWhite)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
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

  // ── HEADER ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlueBg, _kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _kWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: _kWhite, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📢 Kirim Pengumuman',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: _kWhite,
                  ),
                ),
                Text(
                  'Broadcast ke seluruh karyawan',
                  style: GoogleFonts.lato(fontSize: 11, color: _kWhiteDim),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _kWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OWNER',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: _kWhite,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FORM CARD ──────────────────────────────────────────────────
  Widget _buildFormCard() {
    final prioritasMap = {
      for (var p in _prioritasOptions) p['label'] as String: p,
    };
    final curPrioritas = prioritasMap[_selectedPrioritas]!;
    final curColor = curPrioritas['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kWhite,
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
            // ── Judul ──
            _label('Judul Pengumuman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _judulCtrl,
              style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: _kTextDark),
              decoration: _inputDecoration('Masukkan judul pengumuman...', Icons.title),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // ── Isi ──
            _label('Isi Pengumuman'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _isiCtrl,
              style: GoogleFonts.lato(fontSize: 13, color: _kTextDark),
              maxLines: 5,
              decoration: _inputDecoration('Tulis isi pengumuman di sini...', Icons.edit_note).copyWith(
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi pengumuman wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // ── Target & Prioritas ──
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Target Penerima'),
                      const SizedBox(height: 8),
                      _dropdownTarget(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Prioritas'),
                      const SizedBox(height: 8),
                      _dropdownPrioritas(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Tombol Kirim ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _sentSuccess
                    ? _successBtn()
                    : _isSending
                        ? _loadingBtn()
                        : _sendBtn(curColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sendBtn(Color color) {
    return ElevatedButton.icon(
      key: const ValueKey('send'),
      onPressed: _kirimPengumuman,
      icon: const Icon(Icons.send_rounded, size: 20),
      label: Text(
        'KIRIM PENGUMUMAN',
        style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBlue,
        foregroundColor: _kWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        shadowColor: _kBlue.withOpacity(0.4),
      ),
    );
  }

  Widget _loadingBtn() {
    return Container(
      key: const ValueKey('loading'),
      decoration: BoxDecoration(
        color: _kBlue.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(color: _kWhite, strokeWidth: 2.5),
        ),
      ),
    );
  }

  Widget _successBtn() {
    return Container(
      key: const ValueKey('success'),
      decoration: BoxDecoration(
        color: _kGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: _kWhite, size: 22),
          const SizedBox(width: 8),
          Text(
            'TERKIRIM!',
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w900, color: _kWhite),
          ),
        ],
      ),
    );
  }

  // ── TARGET DROPDOWN ────────────────────────────────────────────
  Widget _dropdownTarget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: _kBgLight,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTarget,
          isExpanded: true,
          style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextDark),
          icon: const Icon(Icons.keyboard_arrow_down, color: _kBlue, size: 20),
          items: _targetOptions.map((t) {
            return DropdownMenuItem(
              value: t,
              child: Row(
                children: [
                  Icon(
                    t == 'Semua' ? Icons.people : Icons.person_outline,
                    size: 16,
                    color: _kBlue,
                  ),
                  const SizedBox(width: 6),
                  Text(t),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedTarget = v!),
        ),
      ),
    );
  }

  // ── PRIORITAS DROPDOWN ─────────────────────────────────────────
  Widget _dropdownPrioritas() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: _kBgLight,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPrioritas,
          isExpanded: true,
          style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w700, color: _kTextDark),
          icon: const Icon(Icons.keyboard_arrow_down, color: _kBlue, size: 20),
          items: _prioritasOptions.map((p) {
            return DropdownMenuItem(
              value: p['label'] as String,
              child: Row(
                children: [
                  Icon(p['icon'] as IconData, size: 16, color: p['color'] as Color),
                  const SizedBox(width: 6),
                  Text(p['label'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _selectedPrioritas = v!),
        ),
      ),
    );
  }

  // ── RIWAYAT SECTION ────────────────────────────────────────────
  Widget _buildRiwayatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.history, color: _kBlue, size: 18),
            const SizedBox(width: 8),
            Text(
              'RIWAYAT PENGUMUMAN',
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _kTextDark,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_loadingRiwayat)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(color: _kBlue),
            ),
          )
        else if (_riwayat.isEmpty)
          _emptyRiwayat()
        else
          ...(_riwayat.map((item) => _riwayatCard(item)).toList()),
      ],
    );
  }

  Widget _emptyRiwayat() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Text('📭', style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'Belum ada pengumuman',
            style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black38),
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
        ? _kRed
        : prioritas == 'Penting'
            ? const Color(0xFFFF9800)
            : _kBlue;
    final ts = item['timestamp'];
    String waktu = '';
    if (ts != null && ts is Timestamp) {
      final dt = ts.toDate();
      waktu = '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3)),
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
                          color: _kTextDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item['isi'] ?? '',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.people_outline, size: 12, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(
                      item['target'] ?? 'Semua',
                      style: GoogleFonts.lato(fontSize: 10, color: Colors.black38),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 11, color: Colors.black26),
                    const SizedBox(width: 3),
                    Text(waktu, style: GoogleFonts.lato(fontSize: 10, color: Colors.black26)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPERS ────────────────────────────────────────────────────
  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _kTextDark,
        letterSpacing: 0.3,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black26),
      prefixIcon: Icon(icon, color: _kBlue, size: 20),
      filled: true,
      fillColor: _kBgLight,
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
        borderSide: const BorderSide(color: _kBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kRed, width: 1.5),
      ),
    );
  }
}
