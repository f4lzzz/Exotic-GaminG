import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';

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

// ═══════════════════════════════════════════════════════════════
// PROFIL OWNER SCREEN (dengan data dari Firebase)
// ═══════════════════════════════════════════════════════════════
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

  // Data user dari Firebase
  Map<String, dynamic>? get user => widget.userData;

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
                    subtitle: 'Ubah nama, foto dan info akun',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilScreen(userData: user),
                      ),
                    ),
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
                    subtitle: 'Exotic Gaming & Cafe',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InfoTokoScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _menuItem(
                    icon: Icons.credit_card_rounded,
                    color: kGold,
                    title: 'METODE PEMBAYARAN',
                    subtitle: 'Tunai, Transfer, QRIS',
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _buildLogoutButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────────
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
              crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _chip(String label) {
    return Container(
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
  }

  // ─── OWNER CARD (data dari Firebase) ─────────────────────────
  Widget _buildOwnerCard() {
    final nama = user?['nama'] ?? 'Owner';
    final username = user?['username'] ?? 'username';
    final role = user?['role'] ?? 'owner';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: kYellow.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: kYellow, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/owner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: kGold, size: 30),
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
                    boxShadow: [
                      BoxShadow(
                        color: kGold.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
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

  // ─── SECTION LABEL ───────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Row(
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
  }

  // ─── MENU ITEM ───────────────────────────────────────────────
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
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
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
            Icon(Icons.chevron_right_rounded, color: Colors.black26, size: 22),
          ],
        ),
      ),
    );
  }

  // ─── LOGOUT BUTTON ───────────────────────────────────────────
  Widget _buildLogoutButton() {
    final nama = user?['nama'] ?? 'Owner';
    final role = user?['role'] ?? 'owner';
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.lato(
                  color: Colors.black45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                // Tunggu sebentar agar state benar-benar berubah
                await Future.delayed(const Duration(milliseconds: 300));
                if (ctx.mounted) {
                  // Gunakan ctx (context dari dialog) untuk navigasi
                  Navigator.of(ctx).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
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
          border: Border.all(color: kRed.withOpacity(0.2), width: 1),
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
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EDIT PROFIL SCREEN (menerima data user)
// ═══════════════════════════════════════════════════════════════
class EditProfilScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EditProfilScreen({super.key, this.userData});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  late TextEditingController _namaCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _emailCtrl;
  String _selectedRole = 'owner';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = widget.userData;
    _namaCtrl = TextEditingController(text: user?['nama'] ?? '');
    _usernameCtrl = TextEditingController(text: user?['username'] ?? '');
    _emailCtrl = TextEditingController(text: user?['email'] ?? '');
    _selectedRole = user?['role'] ?? 'owner';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
            'nama': _namaCtrl.text.trim(),
            'username': _usernameCtrl.text.trim(),
            'email': _emailCtrl.text.trim(),
            'role': _selectedRole,
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: kGreen,
          ),
        );
        Navigator.pop(context, true); // kembali dengan flag refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: kRed),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: kBlue,
        foregroundColor: kWhite,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _saveProfile,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTextField('Nama Lengkap', _namaCtrl),
            const SizedBox(height: 16),
            _buildTextField('Username', _usernameCtrl),
            const SizedBox(height: 16),
            _buildTextField(
              'Email',
              _emailCtrl,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'owner', child: Text('Owner')),
                DropdownMenuItem(value: 'karyawan', child: Text('Karyawan')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 32),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UBAH PASSWORD SCREEN (tetap seperti sebelumnya)
// ═══════════════════════════════════════════════════════════════
class UbahPasswordScreen extends StatefulWidget {
  const UbahPasswordScreen({super.key});
  @override
  State<UbahPasswordScreen> createState() => _UbahPasswordScreenState();
}

class _UbahPasswordScreenState extends State<UbahPasswordScreen> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _showOld = false, _showNew = false, _showConfirm = false;
  bool _isLoading = false;

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
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String msg;
      if (e.code == 'wrong-password')
        msg = 'Password lama salah';
      else if (e.code == 'weak-password')
        msg = 'Password baru terlalu lemah';
      else
        msg = e.message ?? 'Gagal mengubah password';
      _showSnack(msg, kRed);
    } catch (e) {
      _showSnack('Error: $e', kRed);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: kOrange,
        foregroundColor: kWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPasswordField(
              'Password Lama',
              _oldPassCtrl,
              _showOld,
              () => setState(() => _showOld = !_showOld),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'Password Baru',
              _newPassCtrl,
              _showNew,
              () => setState(() => _showNew = !_showNew),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              'Konfirmasi Password',
              _confirmPassCtrl,
              _showConfirm,
              () => setState(() => _showConfirm = !_showConfirm),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _changePassword,
              style: ElevatedButton.styleFrom(backgroundColor: kOrange),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Simpan Password'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController ctrl,
    bool obscure,
    VoidCallback toggle,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: !obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggle,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INFO TOKO SCREEN (tetap seperti sebelumnya, bisa dikembangkan)
// ═══════════════════════════════════════════════════════════════
class InfoTokoScreen extends StatelessWidget {
  const InfoTokoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Toko'),
        backgroundColor: kGreen,
        foregroundColor: kWhite,
      ),
      body: const Center(
        child: Text('Halaman info toko (masih dalam pengembangan)'),
      ),
    );
  }
}
