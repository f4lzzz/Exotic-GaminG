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
const kBgLight = Color(0xFFF0F4FF);

// ═══════════════════════════════════════════════════════════════
// PROFIL OWNER SCREEN
// ═══════════════════════════════════════════════════════════════
class ProfilOwnerScreen extends StatefulWidget {
  const ProfilOwnerScreen({super.key});

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
                        builder: (_) => const EditProfilScreen(),
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

  // ─── OWNER CARD ──────────────────────────────────────────────
  Widget _buildOwnerCard() {
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
                  'WILLY WIJAYA',
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Owner Exotic Gaming & Cafe',
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
                    'OWNER UTAMA',
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
                  'WILLY WIJAYA — OWNER',
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
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
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
// EDIT PROFIL SCREEN
// ═══════════════════════════════════════════════════════════════
class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});
  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _namaCtrl = TextEditingController(text: 'WILLY WIJAYA');
  final _usernameCtrl = TextEditingController(text: 'WILLYWIJAYA123');
  final _tglLahirCtrl = TextEditingController(text: '08/17/1995');
  final _teleponCtrl = TextEditingController(text: '087356642644');
  final _emailCtrl = TextEditingController(text: 'willywijaya76@gmail.com');
  final _alamatCtrl = TextEditingController(text: 'Jalan Ahmad Yani');
  final _namaUsahaCtrl = TextEditingController(text: 'Exotic Gaming and Cafe');
  final _jabatanCtrl = TextEditingController(text: 'Owner');
  String _gender = 'Laki-Laki';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 20),
                  _buildSection(
                    title: 'INFORMASI DASAR',
                    icon: Icons.person_outline,
                    color: kBlue,
                    children: [
                      _field('NAMA LENGKAP', _namaCtrl),
                      _field('USERNAME', _usernameCtrl),
                      _field('TANGGAL LAHIR', _tglLahirCtrl),
                      _genderField(),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'KONTAK',
                    icon: Icons.contact_phone_outlined,
                    color: kGreen,
                    children: [
                      _field(
                        'NO. TELEPON',
                        _teleponCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        'EMAIL',
                        _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _field('ALAMAT', _alamatCtrl),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'TOKO',
                    icon: Icons.storefront_outlined,
                    color: kGold,
                    children: [
                      _field('NAMA USAHA', _namaUsahaCtrl),
                      _field('JABATAN', _jabatanCtrl),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'BATAL',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Profil berhasil disimpan!',
                                  style: GoogleFonts.lato(),
                                ),
                                backgroundColor: kGreen,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.save_rounded,
                                color: kWhite,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SIMPAN',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w800,
                                  color: kWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
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
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
              children: const [
                TextSpan(
                  text: 'E',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: 'OTIC',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
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

  Widget _buildAvatar() {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kYellow.withOpacity(0.2),
                  border: Border.all(color: kYellow, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: kBlue.withOpacity(0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/owner.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, color: kGold, size: 44),
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.edit_rounded, color: kBlue, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'WILLY WIJAYA',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              fontSize: 15,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'OWNER UTAMA',
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
          ),
        ],
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: kTextDark,
                  letterSpacing: 0.3,
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

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
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
          const SizedBox(height: 4),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12, width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kBlue, width: 2),
              ),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genderField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JENIS KELAMIN',
            style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.black38,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _genderOption('Laki-Laki', Icons.male_rounded),
              const SizedBox(width: 12),
              _genderOption('Perempuan', Icons.female_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _genderOption(String val, IconData icon) {
    final isSelected = _gender == val;
    return GestureDetector(
      onTap: () => setState(() => _gender = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? kBlue.withOpacity(0.1)
              : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? kBlue : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? kBlue : Colors.black38),
            const SizedBox(width: 6),
            Text(
              val,
              style: GoogleFonts.lato(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? kBlue : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// UBAH PASSWORD SCREEN
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: kWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: kOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: kOrange,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'UBAH PASSWORD',
                              style: GoogleFonts.lato(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: kTextDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _passField(
                          'PASSWORD LAMA',
                          _oldPassCtrl,
                          _showOld,
                          () => setState(() => _showOld = !_showOld),
                        ),
                        const SizedBox(height: 14),
                        _passField(
                          'PASSWORD BARU',
                          _newPassCtrl,
                          _showNew,
                          () => setState(() => _showNew = !_showNew),
                        ),
                        const SizedBox(height: 14),
                        _passField(
                          'KONFIRMASI PASSWORD',
                          _confirmPassCtrl,
                          _showConfirm,
                          () => setState(() => _showConfirm = !_showConfirm),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'BATAL',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w700,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password berhasil diubah!',
                                  style: GoogleFonts.lato(),
                                ),
                                backgroundColor: kGreen,
                              ),
                            );
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kOrange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.save_rounded,
                                color: kWhite,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'SIMPAN',
                                style: GoogleFonts.lato(
                                  fontWeight: FontWeight.w800,
                                  color: kWhite,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
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
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
              children: const [
                TextSpan(
                  text: 'E',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: 'OTIC',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
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

  Widget _passField(
    String label,
    TextEditingController ctrl,
    bool show,
    VoidCallback toggle,
  ) {
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
        const SizedBox(height: 4),
        TextFormField(
          controller: ctrl,
          obscureText: !show,
          style: GoogleFonts.lato(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black12, width: 1.5),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: kBlue, width: 2),
            ),
            suffixIcon: GestureDetector(
              onTap: toggle,
              child: Icon(
                show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18,
                color: Colors.black38,
              ),
            ),
            filled: false,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// INFO TOKO SCREEN
// ═══════════════════════════════════════════════════════════════
class InfoTokoScreen extends StatefulWidget {
  const InfoTokoScreen({super.key});
  @override
  State<InfoTokoScreen> createState() => _InfoTokoScreenState();
}

class _InfoTokoScreenState extends State<InfoTokoScreen> {
  final _alamatCtrl = TextEditingController(
    text: 'Jalan Ahmad Yani No. 12, Sidoarjo',
  );
  final _kotaCtrl = TextEditingController(text: 'Sidoarjo, Jawa Timur');
  final _teleponTokoCtrl = TextEditingController(text: '031-8876543');
  final _jamBukaCtrl = TextEditingController(text: '08:00');
  final _jamTutupCtrl = TextEditingController(text: '23:00');
  final _namaPemilikCtrl = TextEditingController(text: 'Willy Wijaya');
  final _emailPemilikCtrl = TextEditingController(
    text: 'willywijaya76@gmail.com',
  );
  final _teleponPemilikCtrl = TextEditingController(text: '087356642644');
  final _nikCtrl = TextEditingController(text: '3515xxxxxxxx0001');

  bool _senin = true,
      _selasa = true,
      _rabu = true,
      _kamis = true,
      _jumat = true,
      _sabtu = true,
      _minggu = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'LOKASI TOKO',
                    icon: Icons.location_on_rounded,
                    color: kGreen,
                    children: [
                      _field('ALAMAT LENGKAP', _alamatCtrl),
                      _field('KOTA / PROVINSI', _kotaCtrl),
                      _field(
                        'NO. TELEPON TOKO',
                        _teleponTokoCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'JAM OPERASIONAL',
                    icon: Icons.access_time_rounded,
                    color: kOrange,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _timeField(
                              'JAM BUKA',
                              _jamBukaCtrl,
                              Icons.wb_sunny_rounded,
                              kOrange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _timeField(
                              'JAM TUTUP',
                              _jamTutupCtrl,
                              Icons.nights_stay_rounded,
                              kBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'HARI OPERASIONAL',
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black38,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _dayChip(
                            'Sen',
                            _senin,
                            (v) => setState(() => _senin = v),
                          ),
                          _dayChip(
                            'Sel',
                            _selasa,
                            (v) => setState(() => _selasa = v),
                          ),
                          _dayChip(
                            'Rab',
                            _rabu,
                            (v) => setState(() => _rabu = v),
                          ),
                          _dayChip(
                            'Kam',
                            _kamis,
                            (v) => setState(() => _kamis = v),
                          ),
                          _dayChip(
                            'Jum',
                            _jumat,
                            (v) => setState(() => _jumat = v),
                          ),
                          _dayChip(
                            'Sab',
                            _sabtu,
                            (v) => setState(() => _sabtu = v),
                          ),
                          _dayChip(
                            'Min',
                            _minggu,
                            (v) => setState(() => _minggu = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: kOrange.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: kOrange,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _buildJamRingkasan(),
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: kOrange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'DATA PEMILIK',
                    icon: Icons.emoji_events_rounded,
                    color: kGold,
                    children: [
                      _field('NAMA PEMILIK', _namaPemilikCtrl),
                      _field(
                        'EMAIL',
                        _emailPemilikCtrl,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _field(
                        'NO. TELEPON',
                        _teleponPemilikCtrl,
                        keyboardType: TextInputType.phone,
                      ),
                      _field(
                        'NIK / KTP',
                        _nikCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Info toko berhasil disimpan!',
                              style: GoogleFonts.lato(),
                            ),
                            backgroundColor: kGreen,
                          ),
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.save_rounded,
                            color: kWhite,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'SIMPAN SEMUA PERUBAHAN',
                            style: GoogleFonts.lato(
                              fontWeight: FontWeight.w800,
                              color: kWhite,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90D9), kBlue],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
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
          const SizedBox(width: 12),
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: kWhite, height: 1.0),
              children: const [
                TextSpan(
                  text: 'E',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: 'X',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: 'OTIC',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: kWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'INFO TOKO',
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
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: kTextDark,
                  letterSpacing: 0.3,
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

  Widget _field(
    String label,
    TextEditingController ctrl, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
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
          const SizedBox(height: 4),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextDark,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black12, width: 1.5),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: kBlue, width: 2),
              ),
              filled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timeField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    Color color,
  ) {
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
            color: kBgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12, width: 1.5),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: TextInputType.datetime,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: color, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dayChip(String label, bool isActive, ValueChanged<bool> onChanged) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: isActive ? kBlue : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? kBlue : Colors.black12,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: kBlue.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isActive ? kWhite : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }

  String _buildJamRingkasan() {
    final days = <String>[];
    if (_senin) days.add('Sen');
    if (_selasa) days.add('Sel');
    if (_rabu) days.add('Rab');
    if (_kamis) days.add('Kam');
    if (_jumat) days.add('Jum');
    if (_sabtu) days.add('Sab');
    if (_minggu) days.add('Min');
    if (days.isEmpty) return 'Tutup semua hari';
    return '${days.join(', ')}  •  ${_jamBukaCtrl.text} – ${_jamTutupCtrl.text}';
  }
}
