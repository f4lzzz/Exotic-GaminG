import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'owner_karyawan.dart';
import 'owner_menu.dart';
import 'notifikasi_owner.dart';
import 'profil_owner.dart';
import 'rekap_owner.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);

class OwnerDashboardScreen extends StatefulWidget {
  final String username;

  const OwnerDashboardScreen({super.key, required this.username});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  int _notifCount = 3;

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

  double get _collapseProgress => (_scrollOffset / _collapseAt).clamp(0.0, 1.0);
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'selamat pagi';
    if (hour < 15) return 'selamat siang';
    if (hour < 18) return 'selamat sore';
    return 'selamat malam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: IndexedStack(
        index: _selectedNav,
        children: [
          // Tab 0 — HOME (dashboard konten)
          Column(
            children: [
              FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(),
                      const SizedBox(height: 16),
                      _buildStatCards(),
                      const SizedBox(height: 20),
                      _buildChartSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Tab 1 — KARYAWAN
          const OwnerKaryawanScreen(),
          // Tab 2 — center button (kosong)
          const SizedBox(),
          // Tab 3 — MENU
          const OwnerMenuScreen(),
          // Tab 4 — REKAP
          const RekapOwnerScreen(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── HEADER (sama persis login) ──────────────────────────────────────────
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

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerIconBtn(
          Icons.settings_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilOwnerScreen()),
          ),
        ),
        const SizedBox(width: 6),
        _headerIconBtn(
          Icons.notifications_outlined,
          badge: _notifCount,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiOwnerScreen()),
          ),
        ),
      ],
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
                    iconButtons,
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
                iconButtons,
              ],
            ),
    );
  }

  Widget _headerIconBtn(
    IconData icon, {
    int badge = 0,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: kRed,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badge',
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: kWhite,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── USER INFO CARD ───────────────────────────────────────────────────────
  Widget _buildUserInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kYellow.withOpacity(0.2),
              border: Border.all(color: kYellow, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/owner.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: kGold, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: GoogleFonts.lato(fontSize: 11, color: Colors.black45),
                ),
                Text(
                  widget.username.toUpperCase(),
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 10,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(),
                      style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
              'OWNER',
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const days = [
      'senin',
      'selasa',
      'rabu',
      'kamis',
      'jumat',
      'sabtu',
      'minggu',
    ];
    const months = [
      'januari',
      'februari',
      'maret',
      'april',
      'mei',
      'juni',
      'juli',
      'agustus',
      'september',
      'oktober',
      'november',
      'desember',
    ];
    return '${days[now.weekday - 1]} ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ─── STAT CARDS ──────────────────────────────────────────────────────────
  Widget _buildStatCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                emoji: '💰',
                value: 'Rp 3,4 jt',
                label: 'PENDAPATAN HARI INI',
                badge: '+5',
                badgeColor: kGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                icon: Icons.add,
                value: '40',
                label: 'TOTAL TRANSAKSI',
                badge: '+5',
                badgeColor: kGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                emoji: '🤖',
                value: '11/13',
                label: 'KARYAWAN HADIR',
                badge: '2 ABSEN',
                badgeColor: kRed,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                emoji: '📦',
                value: '5 item',
                label: 'STOK KRITIS',
                badge: '3 HABIS',
                badgeColor: kRed,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    String? emoji,
    IconData? icon,
    required String value,
    required String label,
    required String badge,
    required Color badgeColor,
  }) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              emoji != null
                  ? Text(emoji, style: const TextStyle(fontSize: 28))
                  : Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: kBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: kBlue, size: 22),
                    ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ─── CHART SECTION ───────────────────────────────────────────────────────
  Widget _buildChartSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: kBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'PENDAPATAN MINGGU INI',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: kTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    'DETAIL',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: kBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, color: kBlue, size: 14),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4A90D9), kBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: kBlue.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOTAL MINGGU INI',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: kWhiteDim,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp 18,7 jt',
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: kWhite,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.trending_up, color: kGreen, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '+8.4% vs minggu lalu',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: kGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildBarChart(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _chartLegend('☕', 'cafe', '9,2 jt'),
                  _chartLegend('🎮', 'gaming', '9,2 jt'),
                  _chartLegend('👤', 'lainnya', '9,2 jt'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final values = [0.4, 0.6, 0.75, 0.5, 0.9, 0.65, 0.8];
    final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 400 + i * 60),
                    curve: Curves.easeOut,
                    height: values[i] * 75,
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(i == 4 ? 1.0 : 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    days[i],
                    style: GoogleFonts.lato(fontSize: 9, color: kWhiteDim),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _chartLegend(String emoji, String label, String value) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.lato(fontSize: 11, color: kWhiteDim),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: kWhite,
          ),
        ),
      ],
    );
  }

  // ─── BOTTOM NAV ──────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home, 'HOME'),
              _navItem(1, Icons.people_outline, Icons.people, 'KARYAWAN'),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4A90D9), kBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: kBlueBg,
                              blurRadius: 10,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
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
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                TextSpan(
                                  text: 'X',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                TextSpan(
                                  text: 'otic',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _navItem(3, Icons.menu_outlined, Icons.menu, 'MENU'),
              _navItem(4, Icons.bar_chart_outlined, Icons.bar_chart, 'REKAP'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    int index,
    IconData outlineIcon,
    IconData filledIcon,
    String label,
  ) {
    final isSelected = _selectedNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedNav = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? filledIcon : outlineIcon,
              color: isSelected ? kBlue : Colors.black38,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? kBlue : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
