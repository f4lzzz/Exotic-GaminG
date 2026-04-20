import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'forgot_password.dart';
import 'owner_dashboard.dart';

// Warna konstanta
const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);

// ========== LOGIN SCREEN ==========
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  String _selectedRole = 'owner';
  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  double _scrollOffset = 0;

  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;

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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);

  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('MASUK SEBAGAI'),
                    const SizedBox(height: 14),
                    _buildRoleSelector(),
                    const SizedBox(height: 28),
                    _sectionLabel('EMAIL'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _emailCtrl,
                      hint: 'Masukkan email...',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('PASSWORD'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: 'Masukkan password...',
                      icon: Icons.lock_outline,
                      obscure: _obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 22,
                              height: 22,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (v) =>
                                    setState(() => _rememberMe = v ?? false),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: kBlue,
                                side: const BorderSide(
                                  color: Color(0xFFBBBBBB),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Ingat saya',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          ),
                          child: Text(
                            'Lupa password?',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: kBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildLoginButton(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildCreateAccountButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Text(
                'exotic gaming & cafe - portal management',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black38),
              ),
            ),
          ],
        ),
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
                logoWidget,
                const SizedBox(height: 4),
                Opacity(opacity: subOpacity, child: subWidget),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [logoWidget, const SizedBox(width: 8), subWidget],
            ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.lato(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: kTextDark,
      letterSpacing: 1,
    ),
  );

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _roleCard(
            role: 'owner',
            imagePath: 'assets/images/owner.jpg',
            label: 'Owner',
            sublabel: 'Pemilik / admin',
            cardColor: const Color(0xFFEFF4FF),
            borderColor: kBlue,
            labelColor: kBlue,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _roleCard(
            role: 'karyawan',
            imagePath: 'assets/images/karyawan.jpg',
            label: 'Karyawan',
            sublabel: 'staff / pegawai',
            cardColor: const Color(0xFFEFF4FF),
            borderColor: kBlue,
            labelColor: kBlue,
          ),
        ),
      ],
    );
  }

  Widget _roleCard({
    required String role,
    required String imagePath,
    required String label,
    required String sublabel,
    required Color cardColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? borderColor : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? borderColor : Colors.transparent,
                  border: Border.all(
                    color: selected ? borderColor : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Image.asset(imagePath, width: 48, height: 48, fit: BoxFit.contain),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: selected ? labelColor : Colors.black54,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              sublabel,
              style: GoogleFonts.lato(fontSize: 11, color: Colors.black38),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 14, color: Colors.black26),
          prefixIcon: Icon(icon, color: Colors.black38, size: 20),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: kBlue,
          foregroundColor: kWhite,
          elevation: 3,
          shadowColor: kBlue.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Masuk',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau',
            style: GoogleFonts.lato(fontSize: 12, color: Colors.black38),
          ),
        ),
        Expanded(child: Divider(color: Colors.black12, thickness: 1)),
      ],
    );
  }

  Widget _buildCreateAccountButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: kBlue.withOpacity(0.5), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: kWhite,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add_outlined, size: 20, color: kBlue),
            const SizedBox(width: 8),
            Text(
              'Buat Akun',
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: kBlue,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Email dan password wajib diisi', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Ambil data user dari Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // Jika tidak ada dokumen user (misal data korup)
        await FirebaseAuth.instance.signOut();
        _showSnackbar(
          'Data pengguna tidak lengkap. Silakan hubungi admin.',
          Colors.redAccent,
        );
        setState(() => _isLoading = false);
        return;
      }

      String role = userDoc.get('role');

      // Cek kesesuaian role yang dipilih di UI (opsional)
      if (role != _selectedRole) {
        _showSnackbar(
          'Role yang dipilih tidak sesuai dengan akun ini.',
          Colors.orange,
        );
        // Tetap lanjutkan? Atau bisa logout. Kita pilih tetap lanjut sesuai role sebenarnya.
      }

      // Simpan status "Ingat saya" jika diperlukan (bisa pakai shared_preferences)
      // Untuk sementara lewati.

      if (role == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OwnerDashboardScreen()),
        );
      } else if (role == 'karyawan') {
        // TODO: ganti dengan halaman dashboard karyawan jika sudah ada
        // Sementara tampilkan pesan dan kembali ke login
        _showSnackbar(
          'Halaman karyawan belum tersedia. Silakan hubungi owner.',
          Colors.orange,
        );
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
      } else {
        _showSnackbar('Role tidak dikenal', Colors.redAccent);
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
      }
    } on FirebaseAuthException catch (e) {
      String pesan;
      if (e.code == 'user-not-found')
        pesan = 'Email tidak terdaftar';
      else if (e.code == 'wrong-password')
        pesan = 'Password salah';
      else if (e.code == 'invalid-email')
        pesan = 'Format email tidak valid';
      else
        pesan = 'Login gagal: ${e.message}';
      _showSnackbar(pesan, Colors.redAccent);
      setState(() => _isLoading = false);
    } catch (e) {
      _showSnackbar('Terjadi kesalahan: $e', Colors.redAccent);
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

// ========== REGISTER SCREEN ==========
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _namaCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  bool _obscurePass = true;
  bool _obscureKonfirmasi = true;
  String _selectedRole = 'owner';
  bool _isLoading = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
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
    _namaCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    _scrollCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('DAFTAR SEBAGAI'),
                    const SizedBox(height: 14),
                    _buildRoleSelector(),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'INFORMASI AKUN',
                      icon: Icons.person_outline,
                      color: kBlue,
                      children: [
                        _buildField(
                          _namaCtrl,
                          'NAMA LENGKAP',
                          'Nama lengkap',
                          Icons.badge_outlined,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _usernameCtrl,
                          'USERNAME',
                          'Username unik',
                          Icons.alternate_email,
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _emailCtrl,
                          'EMAIL',
                          'Email aktif',
                          Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      title: 'KEAMANAN',
                      icon: Icons.lock_outline,
                      color: kTextDark,
                      children: [
                        _buildField(
                          _passwordCtrl,
                          'PASSWORD',
                          'Minimal 8 karakter',
                          Icons.lock_outline,
                          obscure: _obscurePass,
                          suffix: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildField(
                          _konfirmasiCtrl,
                          'KONFIRMASI PASSWORD',
                          'Ulangi password',
                          Icons.lock_reset_outlined,
                          obscure: _obscureKonfirmasi,
                          suffix: IconButton(
                            icon: Icon(
                              _obscureKonfirmasi
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () => setState(
                              () => _obscureKonfirmasi = !_obscureKonfirmasi,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kBlue,
                          foregroundColor: kWhite,
                          elevation: 3,
                          shadowColor: kBlue.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.person_add_rounded,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Buat Akun',
                                    style: GoogleFonts.lato(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: RichText(
                          text: TextSpan(
                            style: GoogleFonts.lato(fontSize: 13),
                            children: [
                              const TextSpan(
                                text: 'Sudah punya akun? ',
                                style: TextStyle(color: Colors.black45),
                              ),
                              TextSpan(
                                text: 'Masuk',
                                style: TextStyle(
                                  color: kBlue,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Text(
                'exotic gaming & cafe - portal management',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black38),
              ),
            ),
          ],
        ),
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

    final backBtn = GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: kWhite.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back_ios_new, color: kWhite, size: 15),
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
                    backBtn,
                    const SizedBox(width: 10),
                    logoWidget,
                    const SizedBox(width: 6),
                    Opacity(opacity: subOpacity, child: subWidget),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: kWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'DAFTAR',
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
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                backBtn,
                const SizedBox(width: 10),
                logoWidget,
                const SizedBox(width: 8),
                subWidget,
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'DAFTAR',
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

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _roleChip(
            'owner',
            Icons.emoji_events_rounded,
            'Owner',
            'Pemilik / admin',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _roleChip(
            'karyawan',
            Icons.badge_rounded,
            'Karyawan',
            'Staff / pegawai',
          ),
        ),
      ],
    );
  }

  Widget _roleChip(String role, IconData icon, String label, String sub) {
    final selected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFF4FF) : kWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kBlue : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: kBlue.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? kBlue.withOpacity(0.1)
                    : Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(
                icon,
                color: selected ? kBlue : Colors.black38,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? kBlue : Colors.black54,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.black38,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.06)),
          ),
          child: TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black26),
              prefixIcon: Icon(icon, color: Colors.black38, size: 18),
              suffixIcon: suffix,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    final nama = _namaCtrl.text.trim();
    final username = _usernameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final konfirmasi = _konfirmasiCtrl.text.trim();

    if (nama.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnack('Semua field wajib diisi', Colors.redAccent);
      return;
    }
    if (password != konfirmasi) {
      _showSnack('Password tidak cocok!', Colors.redAccent);
      return;
    }
    if (password.length < 8) {
      _showSnack('Password minimal 8 karakter', Colors.redAccent);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Buat user di Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Simpan data tambahan ke Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'nama': nama,
            'username': username,
            'email': email,
            'role': _selectedRole,
            'createdAt': FieldValue.serverTimestamp(),
          });

      _showSnack(
        'Akun berhasil dibuat! Silakan masuk.',
        const Color(0xFF4CAF50),
      );
      Navigator.pop(context); // kembali ke login
    } on FirebaseAuthException catch (e) {
      String pesan;
      if (e.code == 'email-already-in-use')
        pesan = 'Email sudah terdaftar';
      else if (e.code == 'weak-password')
        pesan = 'Password terlalu lemah';
      else if (e.code == 'invalid-email')
        pesan = 'Format email tidak valid';
      else
        pesan = 'Registrasi gagal: ${e.message}';
      _showSnack(pesan, Colors.redAccent);
    } catch (e) {
      _showSnack('Terjadi kesalahan: $e', Colors.redAccent);
    } finally {
      setState(() => _isLoading = false);
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

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.lato(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: kTextDark,
      letterSpacing: 1,
    ),
  );
}
