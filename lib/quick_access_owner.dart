import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
const kPurple = Color(0xFF7C4DFF);
const kBgLight = Color(0xFFF0F4FF);

class QuickAccessOwnerScreen extends StatefulWidget {
  const QuickAccessOwnerScreen({super.key});

  @override
  State<QuickAccessOwnerScreen> createState() => _QuickAccessOwnerScreenState();
}

class _QuickAccessOwnerScreenState extends State<QuickAccessOwnerScreen>
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
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo eXotic besar di atas
                  Center(child: _buildLogo()),
                  const SizedBox(height: 24),
                  _sectionLabel('⚡ AKSI CEPAT'),
                  const SizedBox(height: 12),
                  _buildGrid(),
                  const SizedBox(height: 24),
                  _sectionLabel('📊 STATUS HARI INI'),
                  const SizedBox(height: 12),
                  _buildStatusCards(),
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
                Row(
                  children: [
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
                        'QUICK ACCESS',
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
                    'QUICK ACCESS',
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

  // ─── LOGO EXOTIC BESAR ───────────────────────────────────────
  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        // Belah ketupat
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kBlue.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Transform.rotate(
        angle: 0.785, // 45 derajat = belah ketupat
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90D9), kBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Transform.rotate(
            angle: -0.785,
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.playfairDisplay(
                    color: kWhite,
                    height: 1.0,
                  ),
                  children: const [
                    TextSpan(
                      text: 'e',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: 'X',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: 'otic',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── SECTION LABEL ───────────────────────────────────────────
  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.lato(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: kTextDark,
        letterSpacing: 0.5,
      ),
    );
  }

  // ─── QUICK ACCESS GRID ───────────────────────────────────────
  Widget _buildGrid() {
    final items = [
      _QAItem(
        emoji: '🧾',
        label: 'Transaksi\nBaru',
        color: kBlue,
        onTap: () => _snack('Transaksi Baru'),
      ),
      _QAItem(
        emoji: '👥',
        label: 'Absensi\nKaryawan',
        color: kGreen,
        onTap: () => _snack('Absensi Karyawan'),
      ),
      _QAItem(
        emoji: '🎮',
        label: 'Timer\nGaming',
        color: kPurple,
        onTap: () => _snack('Timer Gaming'),
      ),
      _QAItem(
        emoji: '📦',
        label: 'Cek\nStok',
        color: kOrange,
        onTap: () => _snack('Cek Stok'),
      ),
      _QAItem(
        emoji: '🏠',
        label: 'Suite\nRoom',
        color: kGold,
        onTap: () => _snack('Suite Room'),
      ),
      _QAItem(
        emoji: '📊',
        label: 'Laporan\nCepat',
        color: kBlueBg,
        onTap: () => _snack('Laporan Cepat'),
      ),
      _QAItem(
        emoji: '🔔',
        label: 'Kirim\nPengumuman',
        color: kRed,
        onTap: () => _snack('Pengumuman'),
      ),
      _QAItem(
        emoji: '⚙️',
        label: 'Buka/\nTutup Toko',
        color: kTextDark,
        onTap: () => _showTokoToggle(),
      ),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: items.map((item) => _qaCard(item)).toList(),
    );
  }

  Widget _qaCard(_QAItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: kTextDark,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS HARI INI ─────────────────────────────────────────
  Widget _buildStatusCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statusCard('💰', 'Pendapatan', 'Rp 3,4 jt', kBlue, '+5%'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusCard('🧾', 'Transaksi', '40x', kGreen, '+3'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _statusCard(
                '🤖',
                'Karyawan Hadir',
                '11/13',
                kOrange,
                '2 absen',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statusCard(
                '📦',
                'Stok Kritis',
                '5 item',
                kRed,
                '3 habis',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statusCard(
    String emoji,
    String label,
    String value,
    Color color,
    String sub,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 9,
                    color: Colors.black38,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.lato(
                    fontSize: 9,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$label — Coming Soon',
          style: GoogleFonts.lato(fontWeight: FontWeight.w700),
        ),
        backgroundColor: kBlue,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showTokoToggle() {
    bool isOpen = true;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Status Toko',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Toko sekarang:',
                style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => setDlg(() => isOpen = !isOpen),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isOpen ? kGreen : kRed,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOpen
                            ? Icons.store
                            : Icons.store_mall_directory_outlined,
                        color: kWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isOpen ? 'BUKA' : 'TUTUP',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: kWhite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Simpan',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QAItem {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QAItem({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
