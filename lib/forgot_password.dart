import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password

  // Step 1
  final _emailCtrl = TextEditingController();

  // Step 2
  final List<TextEditingController> _otpCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  Timer? _timer;

  // Step 3
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String? _passError;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // Header collapse (sama seperti LoginScreen)
  final _scrollCtrl = ScrollController();
  double _scrollOffset = 0;
  static const double _headerExpanded = 120.0;
  static const double _headerCollapsed = 60.0;
  static const double _collapseAt = 70.0;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _scrollCtrl.addListener(() {
      setState(() => _scrollOffset = _scrollCtrl.offset);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);

  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  void _startResendTimer() {
    _resendCountdown = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown == 0) {
        t.cancel();
      } else {
        setState(() => _resendCountdown--);
      }
    });
  }

  void _goToStep(int step) {
    _fadeCtrl.reset();
    setState(() => _currentStep = step);
    _fadeCtrl.forward();
  }

  void _handleSendOtp() {
    if (_emailCtrl.text.isEmpty) {
      _showSnackbar('Email/username wajib diisi', isError: true);
      return;
    }
    _startResendTimer();
    _goToStep(2);
  }

  void _handleVerifyOtp() {
    final otp = _otpCtrls.map((c) => c.text).join();
    if (otp.length < 6) {
      _showSnackbar('Masukkan 6 digit kode OTP', isError: true);
      return;
    }
    _goToStep(3);
  }

  void _handleSavePassword() {
    if (_newPassCtrl.text.length < 6) {
      setState(() => _passError = 'Password minimal 6 karakter !');
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      setState(() => _passError = 'Password tidak cocok !');
      return;
    }
    setState(() => _passError = null);
    _goToStep(4); // success
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
        backgroundColor: isError ? Colors.redAccent : kBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
                    // Back button
                    GestureDetector(
                      onTap: () {
                        if (_currentStep == 1) {
                          Navigator.pop(context);
                        } else if (_currentStep == 4) {
                          Navigator.pop(context);
                        } else {
                          _goToStep(_currentStep - 1);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            size: 16,
                            color: kTextDark,
                          ),
                          Text(
                            'Kembali Ke Login',
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: kTextDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Step indicator
                    _buildStepIndicator(),
                    const SizedBox(height: 28),

                    // Content per step
                    if (_currentStep == 1) _buildStep1(),
                    if (_currentStep == 2) _buildStep2(),
                    if (_currentStep == 3) _buildStep3(),
                    if (_currentStep == 4) _buildStep4(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Footer — sama persis dengan LoginScreen
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

  // ─── HEADER (sama persis LoginScreen) ───────────────────────────────────
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

  // ─── STEP INDICATOR ─────────────────────────────────────────────────────
  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle(1, 'Email'),
        _stepLine(1),
        _stepCircle(2, 'kode OTP'),
        _stepLine(2),
        _stepCircle(3, 'Paswoord'),
      ],
    );
  }

  Widget _stepCircle(int step, String label) {
    final isDone = (_currentStep == 4) || (_currentStep > step);
    final isActive = _currentStep == step;
    final isSuccess = _currentStep == 4;

    Color bgColor;
    Color borderColor;
    Color textColor;

    if (isDone || isSuccess) {
      bgColor = kGreen;
      borderColor = kGreen;
      textColor = kWhite;
    } else if (isActive) {
      bgColor = kYellow;
      borderColor = kGold;
      textColor = Colors.black87;
    } else {
      bgColor = Colors.white;
      borderColor = Colors.grey.shade300;
      textColor = Colors.black38;
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: (isDone || isActive)
                ? [
                    BoxShadow(
                      color: bgColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: (isDone || isSuccess)
                ? const Icon(Icons.check, color: kWhite, size: 18)
                : Text(
                    '$step',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 11,
            color: (isDone || isSuccess)
                ? kGreen
                : isActive
                ? kGold
                : Colors.black38,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int afterStep) {
    final isPassed = _currentStep > afterStep || _currentStep == 4;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 18),
        color: isPassed ? kGreen : Colors.grey.shade300,
      ),
    );
  }

  // ─── STEP 1: EMAIL ───────────────────────────────────────────────────────
  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lupa Password?',
          style: GoogleFonts.lato(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Masukan email atau username yang terdaftar.kami akan mengirimkan kode verifikasi',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 20),

        // Info box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kYellow.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.email_outlined, color: kGold, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kode OTP akan dikirim ke imail yang terdaftar di sistem',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionLabel('EMAIL/USERNAME'),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _emailCtrl,
          hint: 'Masukan email atau username...',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 28),

        _buildActionButton(
          label: 'Kirim Kode Verifikasi',
          onTap: _handleSendOtp,
        ),
      ],
    );
  }

  // ─── STEP 2: OTP ─────────────────────────────────────────────────────────
  Widget _buildStep2() {
    final maskedEmail = _emailCtrl.text.isNotEmpty
        ? _emailCtrl.text.substring(0, 2) + '***'
        : 'pp***';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verifikasi Kode OTP',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
            children: [
              const TextSpan(text: 'Massukkan 6 digit kode yang dikirim ke '),
              TextSpan(
                text: maskedEmail,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: kTextDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        const SizedBox(height: 16),

        // Resend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Belum menerima Kode? ',
              style: GoogleFonts.lato(fontSize: 12, color: Colors.black45),
            ),
            GestureDetector(
              onTap: _resendCountdown == 0 ? _startResendTimer : null,
              child: Text(
                'Kirim Ulang ',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: _resendCountdown == 0 ? kBlue : Colors.black38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '($_resendCountdown)',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Demo hint
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kBlue.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Demo Gunakan Kode ',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
              ),
              Text(
                '123456',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: kBlue,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                ' untuk melanjutkan',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        _buildActionButton(
          label: 'Kirim Verifikasi',
          icon: Icons.check_circle_outline,
          onTap: _handleVerifyOtp,
        ),
      ],
    );
  }

  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 44,
      height: 50,
      child: TextField(
        controller: _otpCtrls[index],
        focusNode: _otpFocus[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: kTextDark,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: kBlue, width: 2),
          ),
          filled: true,
          fillColor: kWhite,
        ),
        onChanged: (val) {
          if (val.isNotEmpty && index < 5) {
            _otpFocus[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            _otpFocus[index - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }

  // ─── STEP 3: NEW PASSWORD ────────────────────────────────────────────────
  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Buat Password Baru',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pastikan password baru kamu kuat dan mudah diingat',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 24),

        _sectionLabel('PASSWORD BARU'),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _newPassCtrl,
          hint: 'Masukkan password baru....',
          icon: Icons.lock_outline,
          obscure: _obscureNew,
          suffix: IconButton(
            icon: Icon(
              _obscureNew
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureNew = !_obscureNew),
          ),
        ),
        const SizedBox(height: 20),

        _sectionLabel('KONFIRMASI PASSSWORD'),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _confirmPassCtrl,
          hint: 'Ulangi password baru....',
          icon: Icons.lock_outline,
          obscure: _obscureConfirm,
          suffix: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),

        if (_passError != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  _passError!,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 28),

        _buildActionButton(
          label: 'Simpan Password baru',
          icon: Icons.save_outlined,
          onTap: _handleSavePassword,
        ),
      ],
    );
  }

  // ─── STEP 4: SUCCESS ─────────────────────────────────────────────────────
  Widget _buildStep4() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: kGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: kWhite, size: 44),
              ),
              const SizedBox(height: 28),
              Text(
                'Password Berhasi Direset',
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: kTextDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Password kamu sudah diperbarui.silahkan login kembali\ndengan password baru',
                style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kYellow,
                    foregroundColor: Colors.black87,
                    elevation: 3,
                    shadowColor: kYellow.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Kembali Ke Login',
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SHARED WIDGETS ──────────────────────────────────────────────────────
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

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kYellow,
          foregroundColor: Colors.black87,
          elevation: 3,
          shadowColor: kYellow.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
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
}
