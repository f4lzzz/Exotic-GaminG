import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

// Warna konsisten dengan tema
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

// ========== PROFIL OWNER SCREEN ==========
class ProfilOwnerScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilOwnerScreen({super.key, this.userData});

  @override
  State<ProfilOwnerScreen> createState() => _ProfilOwnerScreenState();
}

class _ProfilOwnerScreenState extends State<ProfilOwnerScreen>
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
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _userData = widget.userData;
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
                  _buildOwnerCard(),
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
                          builder: (_) => EditProfilScreen(userData: _userData),
                        ),
                      );
                      if (result == true) {
                        final uid = FirebaseAuth.instance.currentUser?.uid;
                        if (uid != null) {
                          final doc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .get();
                          if (doc.exists && mounted)
                            setState(() => _userData = doc.data());
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.lock_rounded,
                    color: kOrange,
                    title: 'UBAH PASSWORD',
                    subtitle: 'Ganti password akun owner',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UbahPasswordScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('TOKO'),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.storefront_rounded,
                    color: kGreen,
                    title: 'INFO TOKO',
                    subtitle: 'Kelola profil toko',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InfoTokoScreen()),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildLogoutButton(),
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
                    _chip('PENGATURAN'),
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
                _chip('PENGATURAN'),
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

  // Kartu profil owner (foto statis)
  Widget _buildOwnerCard() {
    final nama = _userData?['nama'] ?? 'Owner';
    final username = _userData?['username'] ?? 'username';
    final role = _userData?['role'] ?? 'owner';
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
              child: Image.asset(
                'assets/images/owner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: kBlue, size: 30),
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

  Widget _buildLogoutButton() {
    final nama = _userData?['nama'] ?? 'Owner';
    final role = _userData?['role'] ?? 'owner';
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Keluar dari Akun',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: kRed, size: 36),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kYellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$nama — ${role.toUpperCase()}',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: kGold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Yakin ingin keluar dari akun?',
                style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
              ),
            ],
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
              style: ElevatedButton.styleFrom(backgroundColor: kRed),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (ctx.mounted)
                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
              },
              child: Text(
                'KELUAR',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kRed.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kRed.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: kRed, size: 20),
            const SizedBox(width: 10),
            Text(
              'KELUAR DARI AKUN',
              style: GoogleFonts.lato(
                color: kRed,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========== EDIT PROFIL SCREEN ==========
class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfilScreen({super.key, this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
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
    _emailCtrl = TextEditingController(text: user?['email'] ?? '');
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
    _emailCtrl.dispose();
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
        'email': _emailCtrl.text.trim(),
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(authUser.uid)
          .update(updateData);
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
                  const SizedBox(height: 12),
                  _buildField(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    ctrl: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: kWhite,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          logoWidget,
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'EDIT PROFIL',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: kWhite,
                letterSpacing: 0.8,
              ),
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
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.black54,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black26),
              prefixIcon: Icon(icon, color: kBlue, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: kBlue, width: 1.5),
              ),
              filled: true,
              fillColor: kWhite,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
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
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                )
              : const LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: kBlue.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: kWhite,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_rounded, color: kWhite, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'SIMPAN PERUBAHAN',
                      style: GoogleFonts.lato(
                        color: kWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ========== UBAH PASSWORD SCREEN ==========
class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});

  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showOld = false, _showNew = false, _showConfirm = false;
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
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final old = _oldPassCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();
    if (old.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showSnack('Semua field harus diisi', kRed);
      return;
    }
    if (newPass != confirm) {
      _showSnack('Password baru tidak cocok', kRed);
      return;
    }
    if (newPass.length < 8) {
      _showSnack('Password minimal 8 karakter', kRed);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User tidak ditemukan');
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: old,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
      _showSnack('Password berhasil diubah!', kGreen);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      _showSnack(
        e.code == 'wrong-password'
            ? 'Password lama salah'
            : e.code == 'weak-password'
            ? 'Password baru terlalu lemah'
            : e.message ?? 'Gagal mengubah password',
        kRed,
      );
    } catch (e) {
      _showSnack('Error: $e', kRed);
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
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _sectionLabel('KEAMANAN AKUN'),
                  const SizedBox(height: 14),
                  _buildPasswordField(
                    icon: Icons.lock_outline_rounded,
                    label: 'Password Lama',
                    ctrl: _oldPassCtrl,
                    show: _showOld,
                    onToggle: () => setState(() => _showOld = !_showOld),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    icon: Icons.lock_rounded,
                    label: 'Password Baru',
                    ctrl: _newPassCtrl,
                    show: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    accentColor: kBlue,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    icon: Icons.lock_reset_rounded,
                    label: 'Konfirmasi Password',
                    ctrl: _confirmPassCtrl,
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    accentColor: kGreen,
                  ),
                  const SizedBox(height: 10),
                  _buildPasswordRules(),
                  const SizedBox(height: 24),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: kWhite,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          logoWidget,
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'PASSWORD',
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: kWhite,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kOrange.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: kOrange.withOpacity(0.2)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kOrange.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.info_outline, color: kOrange, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Untuk keamanan, masukkan password lama Anda terlebih dahulu sebelum mengubah password baru.',
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildPasswordRules() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: kWhite,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'KETENTUAN PASSWORD',
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: Colors.black38,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        _ruleItem('Minimal 8 karakter'),
        _ruleItem('Kombinasi huruf dan angka direkomendasikan'),
        _ruleItem('Jangan gunakan password yang sama'),
      ],
    ),
  );

  Widget _ruleItem(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        const Icon(Icons.check_circle_outline, color: kGreen, size: 14),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.lato(fontSize: 11, color: Colors.black54),
        ),
      ],
    ),
  );

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

  Widget _buildPasswordField({
    required IconData icon,
    required String label,
    required TextEditingController ctrl,
    required bool show,
    required VoidCallback onToggle,
    Color accentColor = kOrange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: ctrl,
        obscureText: !show,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(fontSize: 12, color: Colors.black38),
          prefixIcon: Icon(icon, color: accentColor, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: Colors.black38,
              size: 20,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kWhite,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _changePassword,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kOrange, kOrange.withRed(220)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: kOrange.withOpacity(0.3), blurRadius: 12),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: kWhite,
                    strokeWidth: 2.5,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_reset_rounded,
                      color: kWhite,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'SIMPAN PASSWORD',
                      style: GoogleFonts.lato(
                        color: kWhite,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ========== INFO TOKO SCREEN ==========
class InfoTokoScreen extends StatefulWidget {
  const InfoTokoScreen({super.key});

  @override
  State<InfoTokoScreen> createState() => _InfoTokoScreenState();
}

class _InfoTokoScreenState extends State<InfoTokoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  bool _isEditing = false;
  bool _isLoading = false;
  final _namaTokoCtrl = TextEditingController(text: 'Exotic Gaming & Cafe');
  final _alamatCtrl = TextEditingController(
    text: 'Jl. Contoh No. 1, Kota Anda',
  );
  final _noTelpCtrl = TextEditingController(text: '08xxxxxxxxxx');
  final _jamBukaCtrl = TextEditingController(text: '10:00');
  final _jamTutupCtrl = TextEditingController(text: '23:00');
  final _deskripsiCtrl = TextEditingController(
    text: 'Tempat gaming dan cafe terbaik di kota.',
  );
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
    _loadTokoData();
  }

  Future<void> _loadTokoData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('toko')
          .get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _namaTokoCtrl.text = data['nama'] ?? _namaTokoCtrl.text;
          _alamatCtrl.text = data['alamat'] ?? _alamatCtrl.text;
          _noTelpCtrl.text = data['noTelp'] ?? _noTelpCtrl.text;
          _jamBukaCtrl.text = data['jamBuka'] ?? _jamBukaCtrl.text;
          _jamTutupCtrl.text = data['jamTutup'] ?? _jamTutupCtrl.text;
          _deskripsiCtrl.text = data['deskripsi'] ?? _deskripsiCtrl.text;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveToko() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('settings').doc('toko').set({
        'nama': _namaTokoCtrl.text.trim(),
        'alamat': _alamatCtrl.text.trim(),
        'noTelp': _noTelpCtrl.text.trim(),
        'jamBuka': _jamBukaCtrl.text.trim(),
        'jamTutup': _jamTutupCtrl.text.trim(),
        'deskripsi': _deskripsiCtrl.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Info toko berhasil disimpan!',
              style: GoogleFonts.lato(color: kWhite),
            ),
            backgroundColor: kGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: $e', style: GoogleFonts.lato(color: kWhite)),
            backgroundColor: kRed,
          ),
        );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _namaTokoCtrl.dispose();
    _alamatCtrl.dispose();
    _noTelpCtrl.dispose();
    _jamBukaCtrl.dispose();
    _jamTutupCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
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
                  _buildTokoCard(),
                  const SizedBox(height: 20),
                  _sectionLabel('DETAIL TOKO'),
                  const SizedBox(height: 14),
                  _buildInfoField(
                    Icons.storefront_rounded,
                    'Nama Toko',
                    _namaTokoCtrl,
                    kGreen,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoField(
                    Icons.location_on_rounded,
                    'Alamat',
                    _alamatCtrl,
                    kBlue,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoField(
                    Icons.phone_rounded,
                    'No. Telepon',
                    _noTelpCtrl,
                    kOrange,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('JAM OPERASIONAL'),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoField(
                          Icons.access_time_rounded,
                          'Jam Buka',
                          _jamBukaCtrl,
                          kGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoField(
                          Icons.access_time_filled_rounded,
                          'Jam Tutup',
                          _jamTutupCtrl,
                          kRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _sectionLabel('DESKRIPSI'),
                  const SizedBox(height: 14),
                  _buildInfoField(
                    Icons.description_rounded,
                    'Deskripsi Toko',
                    _deskripsiCtrl,
                    kTextDark,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),
                  if (_isEditing) _buildSaveButton(),
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
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: kWhite,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          logoWidget,
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _isEditing = !_isEditing),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: _isEditing
                    ? kYellow.withOpacity(0.3)
                    : kWhite.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isEditing ? Icons.close_rounded : Icons.edit_rounded,
                    color: kWhite,
                    size: 13,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isEditing ? 'BATAL' : 'EDIT',
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokoCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: kBlue.withOpacity(0.3), blurRadius: 16)],
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: kWhite.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.storefront_rounded, color: kWhite, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EXOTIC',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: kWhite,
                  letterSpacing: 1,
                ),
              ),
              Text(
                'Gaming & Cafe',
                style: GoogleFonts.lato(fontSize: 12, color: kWhiteDim),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: kGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'AKTIF',
                      style: GoogleFonts.lato(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: kGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

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

  Widget _buildInfoField(
    IconData icon,
    String label,
    TextEditingController ctrl,
    Color accentColor, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: TextField(
        controller: ctrl,
        enabled: _isEditing,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.lato(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.lato(fontSize: 12, color: Colors.black38),
          prefixIcon: Icon(
            icon,
            color: _isEditing ? accentColor : Colors.black26,
            size: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: accentColor, width: 1.5),
          ),
          filled: true,
          fillColor: _isEditing ? kWhite : Colors.black.withOpacity(0.02),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() => GestureDetector(
    onTap: _isLoading ? null : _saveToko,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: kGreen.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Center(
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: kWhite,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.save_rounded, color: kWhite, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SIMPAN INFO TOKO',
                    style: GoogleFonts.lato(
                      color: kWhite,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    ),
  );
}
