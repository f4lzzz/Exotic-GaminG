import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'registrasi_wajah_screen.dart';
import 'login.dart';

// ==================== WARNA (sama dengan owner) ====================
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

// ==================== PROFIL KARYAWAN SCREEN ====================
class ProfilKaryawanScreen extends StatefulWidget {
  const ProfilKaryawanScreen({super.key});

  @override
  State<ProfilKaryawanScreen> createState() => _ProfilKaryawanScreenState();
}

class _ProfilKaryawanScreenState extends State<ProfilKaryawanScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

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
    _loadUserData();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userData = doc.data();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: kBlue.withOpacity(0.1), width: 4),
                ),
                child: const Icon(
                  Icons.power_settings_new_rounded,
                  color: kBlue,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Konfirmasi Keluar',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin mengakhiri sesi dan keluar dari akun?',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.lato(
                          color: Colors.black38,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (ctx.mounted) {
                          Navigator.of(ctx).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keluar',
                        style: GoogleFonts.lato(
                          color: kWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirm == true) {
      // sudah di-handle di dalam tombol, tapi biar aman
    }
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(color: kBlue),
                      ),
                    )
                  else
                    _buildKaryawanCard(),
                  const SizedBox(height: 20),
                  _sectionLabel('AKUN'),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.edit_rounded,
                    color: kBlue,
                    title: 'EDIT PROFIL',
                    subtitle: 'Ubah nama dan info akun',
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfilKaryawanScreen(
                            userData: _userData,
                          ),
                        ),
                      );
                      if (result == true) {
                        await _loadUserData();
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.face_rounded,
                    color: kGreen,
                    title: 'DAFTARKAN WAJAH',
                    subtitle: 'Registrasi wajah untuk absensi',
                    onTap: () {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      final nama = _userData?['nama'] ?? 'Karyawan';
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegistrasiWajahScreen(
                            uid: uid,
                            namaKaryawan: nama,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('LAINNYA'),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.logout_rounded,
                    color: kRed,
                    title: 'LOGOUT',
                    subtitle: 'Keluar dari akun ini',
                    onTap: () => _logout(context),
                  ),
                  const SizedBox(height: 28),
                ],
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
                    const Spacer(),
                    _chip('PROFIL'),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                _backBtn(),
                const SizedBox(width: 8),
                logoWidget,
                const Spacer(),
                _chip('PROFIL'),
              ],
            ),
    );
  }

  Widget _backBtn() => GestureDetector(
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

  Widget _chip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: kWhite,
            letterSpacing: 0.8,
          ),
        ),
      );

  Widget _buildKaryawanCard() {
    final nama = _userData?['nama'] ??
        FirebaseAuth.instance.currentUser?.displayName ??
        'Karyawan';
    final username = _userData?['username'] ?? 'username';
    final role = _userData?['role'] ?? 'karyawan';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBlueBg.withOpacity(0.15),
              border: Border.all(color: kBlue, width: 2),
            ),
            child: ClipOval(
              child: Icon(
                Icons.person,
                color: kBlue,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '@$username',
                  style: GoogleFonts.lato(fontSize: 11, color: Colors.black45),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kYellow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Row(
        children: [
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black38,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      );

  Widget _menuItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: kTextDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.black26,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EDIT PROFIL KARYAWAN SCREEN (tanpa foto) ====================
class EditProfilKaryawanScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfilKaryawanScreen({super.key, this.userData});

  @override
  State<EditProfilKaryawanScreen> createState() =>
      _EditProfilKaryawanScreenState();
}

class _EditProfilKaryawanScreenState extends State<EditProfilKaryawanScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  bool _isLoading = false;

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
    final user = widget.userData;
    _namaCtrl = TextEditingController(text: user?['nama'] ?? '');
    _usernameCtrl = TextEditingController(text: user?['username'] ?? '');
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
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return;
    if (_namaCtrl.text.trim().isEmpty) {
      _showSnack('Nama tidak boleh kosong', kRed);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final Map<String, dynamic> updateData = {
        'nama': _namaCtrl.text.trim(),
        'username': _usernameCtrl.text.trim(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .update(updateData);
      // Update displayName di Auth
      await authUser.updateDisplayName(_namaCtrl.text.trim());
      if (mounted) {
        _showSnack('Profil berhasil diperbarui!', kGreen);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) _showSnack('Gagal: ${e.toString()}', kRed);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  _sectionLabel('INFORMASI AKUN'),
                  const SizedBox(height: 14),
                  _buildField(
                    icon: Icons.person_rounded,
                    label: 'Nama Lengkap',
                    ctrl: _namaCtrl,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    icon: Icons.alternate_email_rounded,
                    label: 'Username',
                    ctrl: _usernameCtrl,
                  ),
                  const SizedBox(height: 32),
                  _buildSaveButton(),
                ],
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
    final double padTop = 36 - (36 - 16) * p;
    final double padBot = 16 - (16 - 10) * p;

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

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
              child:
                  const Icon(Icons.arrow_back_ios_new, color: kWhite, size: 16),
            ),
          ),
          const SizedBox(width: 8),
          logoWidget,
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20)),
            child: Text(
              'EDIT PROFIL',
              style: GoogleFonts.lato(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                  letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Row(
        children: [
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(label,
                style: GoogleFonts.lato(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.black38,
                    letterSpacing: 0.8)),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      );

  Widget _buildField({
    required IconData icon,
    required String label,
    required TextEditingController ctrl,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(label,
              style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                  letterSpacing: 0.3)),
        ),
        Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black26),
              prefixIcon: Icon(icon, color: kBlue, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: kBlue, width: 1.5)),
              filled: true,
              fillColor: kWhite,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveProfile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: _isLoading
              ? LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500])
              : const LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: kBlue.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: kWhite, strokeWidth: 2.5))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, color: kWhite, size: 18),
                    const SizedBox(width: 8),
                    Text('SIMPAN PERUBAHAN',
                        style: GoogleFonts.lato(
                            color: kWhite,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5)),
                  ],
                ),
        ),
      ),
    );
  }
}
