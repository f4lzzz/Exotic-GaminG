import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const ExoticApp());
}

class ExoticApp extends StatelessWidget {
  const ExoticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exotic Gaming & Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: const SplashScreen(),
    );
  }
}

const kBlue = Color(0xFF1A5EBF);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);

// font helper
TextStyle _serif(
  double size, {
  FontWeight weight = FontWeight.w400,
  double letterSpacing = 0,
}) => GoogleFonts.playfairDisplay(
  fontSize: size,
  color: kWhite,
  fontWeight: weight,
  letterSpacing: letterSpacing,
  height: 1.0,
);

// ─── Splash Screen ────────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _xCtrl;
  late Animation<double> _xSlide;
  late Animation<double> _xOpacity;
  late Animation<double> _xScale;

  late AnimationController _eCtrl;
  late Animation<double> _eSlide;
  late Animation<double> _eOpacity;

  late AnimationController _oticCtrl;
  late Animation<double> _oticSlide;
  late Animation<double> _oticOpacity;

  late AnimationController _subCtrl;
  late Animation<double> _dividerAnim;
  late Animation<double> _subtitleAnim;

  late AnimationController _exitCtrl;
  late Animation<double> _exitAnim;

  @override
  void initState() {
    super.initState();

    _xCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _xSlide = Tween<double>(
      begin: -80,
      end: 0,
    ).animate(CurvedAnimation(parent: _xCtrl, curve: Curves.easeOutBack));
    _xOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _xCtrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
    );
    _xScale = Tween<double>(
      begin: 1.2,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _xCtrl, curve: Curves.easeOutBack));

    _eCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _eSlide = Tween<double>(
      begin: -36,
      end: 0,
    ).animate(CurvedAnimation(parent: _eCtrl, curve: Curves.easeOut));
    _eOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _eCtrl, curve: Curves.easeOut));

    _oticCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _oticSlide = Tween<double>(
      begin: 36,
      end: 0,
    ).animate(CurvedAnimation(parent: _oticCtrl, curve: Curves.easeOut));
    _oticOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _oticCtrl, curve: Curves.easeOut));

    _subCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _dividerAnim = CurvedAnimation(
      parent: _subCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _subtitleAnim = CurvedAnimation(
      parent: _subCtrl,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitAnim = CurvedAnimation(parent: _exitCtrl, curve: Curves.easeInCubic);

    _runSequence();
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 350));
    _xCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 560));
    _eCtrl.forward();
    _oticCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 580));
    _subCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardPlaceholder(),
          transitionDuration: Duration.zero,
        ),
      );
    }
  }

  @override
  void dispose() {
    _xCtrl.dispose();
    _eCtrl.dispose();
    _oticCtrl.dispose();
    _subCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _xCtrl,
          _eCtrl,
          _oticCtrl,
          _subCtrl,
          _exitCtrl,
        ]),
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: kBlue),

              Center(
                child: Opacity(
                  opacity: 1 - _exitAnim.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── eXOTIC wordmark
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          // "e"
                          Opacity(
                            opacity: _eOpacity.value,
                            child: Transform.translate(
                              offset: Offset(_eSlide.value, 0),
                              child: Text('E', style: _serif(36)),
                            ),
                          ),

                          // "X" — hanya X lebih besar
                          Opacity(
                            opacity: _xOpacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _xSlide.value),
                              child: Transform.scale(
                                scale: _xScale.value,
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  'X',
                                  style: _serif(45, weight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ),

                          // "OTIC"
                          Opacity(
                            opacity: _oticOpacity.value,
                            child: Transform.translate(
                              offset: Offset(_oticSlide.value, 0),
                              child: Text(
                                'OTIC',
                                style: _serif(36, letterSpacing: 1),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Divider
                      ClipRect(
                        child: Align(
                          widthFactor: _dividerAnim.value,
                          child: Container(
                            width: 260,
                            height: 1.5,
                            color: kWhite.withOpacity(0.5),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // GAMING & CAFE
                      Opacity(
                        opacity: _subtitleAnim.value,
                        child: Transform.translate(
                          offset: Offset(0, 8 * (1 - _subtitleAnim.value)),
                          child: Text(
                            'GAMING & CAFE',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 15,
                              color: kWhiteDim,
                              letterSpacing: 5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_exitAnim.value > 0)
                Opacity(
                  opacity: _exitAnim.value,
                  child: Container(color: Colors.black),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Dashboard Placeholder ────────────────────────────────────────────────────

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'E', style: _serif(36)),
                  TextSpan(
                    text: 'X',
                    style: _serif(72, weight: FontWeight.w700),
                  ),
                  TextSpan(text: 'OTIC', style: _serif(36, letterSpacing: 1)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 230, height: 1.5, color: kWhite.withOpacity(0.45)),
            const SizedBox(height: 8),
            Text(
              'GAMING & CAFE',
              style: GoogleFonts.playfairDisplay(
                fontSize: 15,
                color: kWhiteDim,
                letterSpacing: 5,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              '— Dashboard —',
              style: GoogleFonts.playfairDisplay(
                fontSize: 12,
                color: kWhite.withOpacity(0.35),
                letterSpacing: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
