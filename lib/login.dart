import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'forgot_password.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);

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

  final _usernameCtrl = TextEditingController();
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

    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
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
                    _sectionLabel('USERNAME / EMAIL'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _usernameCtrl,
                      hint: 'Masukan username...',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
                    _sectionLabel('PASSWORD'),
                    const SizedBox(height: 10),
                    _buildTextField(
                      controller: _passwordCtrl,
                      hint: 'Masukan password...',
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
                              'ingat saya',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Lupa password?',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: kBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _buildLoginButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Text(
                'exotic gaming&caffe - portal manajement',
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lato(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: kTextDark,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: _roleCard(
            role: 'owner',
            imagePath: 'assets/images/owner.jpg',
            label: 'Owner',
            sublabel: 'Pemilik / admin',
            cardColor: const Color(0xFFFFF3C2),
            borderColor: kGold,
            labelColor: kGold,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
              Image.asset(
                imagePath,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
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
    final isOwner = _selectedRole == 'owner';
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: isOwner ? kYellow : kBlue,
            foregroundColor: isOwner ? Colors.black87 : kWhite,
            elevation: 3,
            shadowColor: (isOwner ? kYellow : kBlue).withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Masuk',
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_usernameCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Username dan password wajib diisi',
            style: GoogleFonts.lato(color: kWhite),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }
  }
}
