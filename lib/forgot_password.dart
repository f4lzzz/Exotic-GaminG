import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);

const _emailjsServiceId = 'service_s5exapm';
const _emailjsTemplateId = 'template_j5jdo9w';
const _emailjsPublicKey = 'bTVRlfkOstj6icTA1';
const _otpExpirySeconds = 60;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 1;

  // Step 1
  final _emailCtrl = TextEditingController();
  bool _isSendingOtp = false;

  // Step 2
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());
  int _resendCountdown = 60;
  Timer? _resendTimer;

  String _generatedOtp = '';
  DateTime? _otpExpiredAt;
  bool _isVerifying = false;

  // Step 3 (field yang tidak digunakan dihapus)
  bool _isSavingPass = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

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
    _scrollCtrl.addListener(
      () => setState(() => _scrollOffset = _scrollCtrl.offset),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  String _generateOtp() {
    final rng = Random.secure();
    return List.generate(6, (_) => rng.nextInt(10)).join();
  }

  Future<bool> _sendOtpEmail(String email, String otp) async {
    try {
      final body = jsonEncode({
        'service_id': _emailjsServiceId,
        'template_id': _emailjsTemplateId,
        'user_id': _emailjsPublicKey,
        'template_params': {
          'to_email': email,
          'otp_code': otp,
        },
      });

      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
          'origin': 'http://localhost',
        },
        body: body,
      );

      debugPrint('=== EmailJS Status: ${response.statusCode} ===');
      debugPrint('=== EmailJS Body: ${response.body} ===');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('=== EmailJS Error: $e ===');
      return false;
    }
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
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

  Future<void> _handleSendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showSnackbar('Email wajib diisi', isError: true);
      return;
    }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      _showSnackbar('Format email tidak valid', isError: true);
      return;
    }

    setState(() => _isSendingOtp = true);

    _generatedOtp = _generateOtp();
    _otpExpiredAt = DateTime.now().add(
      const Duration(seconds: _otpExpirySeconds),
    );

    final success = await _sendOtpEmail(email, _generatedOtp);

    if (!success) {
      _showSnackbar('Gagal mengirim OTP, coba lagi', isError: true);
      setState(() => _isSendingOtp = false);
      return;
    }

    setState(() => _isSendingOtp = false);
    _startResendTimer();
    _showSnackbar('Kode OTP berhasil dikirim ke $email');
    _goToStep(2);
  }

  Future<void> _handleResend() async {
    if (_resendCountdown > 0) return;
    final email = _emailCtrl.text.trim();

    _generatedOtp = _generateOtp();
    _otpExpiredAt = DateTime.now().add(
      const Duration(seconds: _otpExpirySeconds),
    );

    final success = await _sendOtpEmail(email, _generatedOtp);
    if (success) {
      _showSnackbar('Kode OTP baru berhasil dikirim');
      _startResendTimer();
      for (final c in _otpCtrls) c.clear();
      _otpFocus[0].requestFocus();
    } else {
      _showSnackbar('Gagal kirim ulang OTP', isError: true);
    }
  }

  void _handleVerifyOtp() {
    final otp = _otpCtrls.map((c) => c.text).join();

    if (otp.length < 6) {
      _showSnackbar('Masukkan 6 digit kode OTP', isError: true);
      return;
    }

    if (_otpExpiredAt == null || DateTime.now().isAfter(_otpExpiredAt!)) {
      _showSnackbar('Kode OTP sudah kadaluarsa, minta kode baru',
          isError: true);
      for (final c in _otpCtrls) c.clear();
      _otpFocus[0].requestFocus();
      return;
    }

    if (otp != _generatedOtp) {
      _showSnackbar('Kode OTP salah, coba lagi', isError: true);
      for (final c in _otpCtrls) c.clear();
      _otpFocus[0].requestFocus();
      return;
    }

    _generatedOtp = '';
    _otpExpiredAt = null;
    _goToStep(3);
  }

  Future<void> _handleSavePassword() async {
    setState(() => _isSavingPass = true);

    try {
      final email = _emailCtrl.text.trim();
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      setState(() => _isSavingPass = false);
      _goToStep(4);
    } on FirebaseAuthException catch (e) {
      setState(() => _isSavingPass = false);
      debugPrint('=== Firebase reset error: ${e.code} ===');
      if (e.code == 'user-not-found') {
        _showSnackbar('Email tidak terdaftar di sistem', isError: true);
        Future.delayed(const Duration(seconds: 2), () => _goToStep(1));
      } else if (e.code == 'too-many-requests') {
        _showSnackbar('Terlalu banyak percobaan, coba beberapa menit lagi',
            isError: true);
      } else {
        _showSnackbar('Gagal kirim link reset, coba lagi', isError: true);
      }
    } catch (e) {
      setState(() => _isSavingPass = false);
      _showSnackbar('Terjadi kesalahan, coba lagi', isError: true);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.lato(color: kWhite)),
        backgroundColor: isError ? Colors.redAccent : kGreen,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_currentStep == 1 || _currentStep == 4) {
                          Navigator.pop(context);
                        } else {
                          _goToStep(_currentStep - 1);
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_back_ios,
                              size: 16, color: kTextDark),
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
                    _buildStepIndicator(),
                    const SizedBox(height: 28),
                    if (_currentStep == 1) _buildStep1(),
                    if (_currentStep == 2) _buildStep2(),
                    if (_currentStep == 3) _buildStep3(),
                    if (_currentStep == 4) _buildStep4(),
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
              children: [
                logoWidget,
                const SizedBox(width: 8),
                subWidget,
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _stepCircle(1, 'Email'),
        _stepLine(1),
        _stepCircle(2, 'Kode OTP'),
        _stepLine(2),
        _stepCircle(3, 'Password'),
      ],
    );
  }

  Widget _stepCircle(int step, String label) {
    final isDone = _currentStep == 4 || _currentStep > step;
    final isActive = _currentStep == step;
    final isSuccess = _currentStep == 4;

    Color bgColor, borderColor, textColor;
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
                        offset: const Offset(0, 3))
                  ]
                : [],
          ),
          child: Center(
            child: (isDone || isSuccess)
                ? const Icon(Icons.check, color: kWhite, size: 18)
                : Text('$step',
                    style: GoogleFonts.lato(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: textColor)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: (isDone || isSuccess)
                  ? kGreen
                  : isActive
                      ? kGold
                      : Colors.black38,
              fontWeight: FontWeight.w600,
            )),
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lupa Password?',
            style: GoogleFonts.lato(
                fontSize: 22, fontWeight: FontWeight.w900, color: kTextDark)),
        const SizedBox(height: 8),
        Text(
          'Masukkan email yang terdaftar. Kami akan mengirimkan kode OTP verifikasi.',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 20),
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
                  'Kode OTP 6 digit akan dikirim ke email kamu dan berlaku selama 1 menit',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _sectionLabel('EMAIL'),
        const SizedBox(height: 10),
        _buildTextField(
          controller: _emailCtrl,
          hint: 'Masukkan email yang terdaftar...',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 28),
        _buildActionButton(
          label: 'Kirim Kode OTP',
          icon: Icons.send_rounded,
          isLoading: _isSendingOtp,
          onTap: _handleSendOtp,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final email = _emailCtrl.text.trim();
    final masked = email.length > 4
        ? '${email.substring(0, 3)}***${email.substring(email.indexOf('@'))}'
        : '***';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verifikasi Kode OTP',
            style: GoogleFonts.lato(
                fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
            children: [
              const TextSpan(text: 'Masukkan 6 digit kode yang dikirim ke '),
              TextSpan(
                  text: masked,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: kTextDark)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.timer_outlined,
                  color: Colors.orange.shade700, size: 16),
              const SizedBox(width: 8),
              Text(
                'Kode OTP berlaku selama 1 menit',
                style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Belum menerima kode? ',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black45)),
            GestureDetector(
              onTap: _resendCountdown == 0 ? _handleResend : null,
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
              child: Text('($_resendCountdown)',
                  style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Colors.red,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _buildActionButton(
          label: 'Verifikasi Kode',
          icon: Icons.check_circle_outline,
          isLoading: _isVerifying,
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
            fontSize: 20, fontWeight: FontWeight.w800, color: kTextDark),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kBlue, width: 2)),
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

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verifikasi Berhasil!',
            style: GoogleFonts.lato(
                fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
        const SizedBox(height: 8),
        Text(
          'OTP kamu sudah terverifikasi. Kami akan mengirimkan link reset password ke email kamu.',
          style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF4FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBlue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.email_outlined, color: kBlue, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Link reset password akan dikirim ke:',
                      style:
                          GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _emailCtrl.text.trim(),
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buka email → klik link → buat password baru',
                style: GoogleFonts.lato(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _buildActionButton(
          label: 'Kirim Link Reset Password',
          icon: Icons.send_rounded,
          isLoading: _isSavingPass,
          onTap: _handleSavePassword,
        ),
      ],
    );
  }

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
                decoration:
                    const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: kWhite, size: 44),
              ),
              const SizedBox(height: 28),
              Text('Link Berhasil Dikirim!',
                  style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: kTextDark),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Cek email kamu dan klik link reset password.\nSetelah itu kamu bisa login dengan password baru.',
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
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Kembali Ke Login',
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kTextDark,
            letterSpacing: 1),
      );

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
              offset: const Offset(0, 2)),
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

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kYellow,
          foregroundColor: Colors.black87,
          elevation: 3,
          shadowColor: kYellow.withOpacity(0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.black54, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                  ],
                  Text(label,
                      style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5)),
                ],
              ),
      ),
    );
  }
}
