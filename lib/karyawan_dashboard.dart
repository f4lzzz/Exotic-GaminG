import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'notifikasi_owner.dart';

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

// ─── MODEL SHIFT ─────────────────────────────────────────────────────────────
class ShiftModel {
  final String nama;
  final String jamMulai;
  final String jamSelesai;
  final String hari;
  final String tanggal;
  final StatusShift status;

  const ShiftModel({
    required this.nama,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.tanggal,
    required this.status,
  });
}

enum StatusShift { selesai, berlangsung, akan }

enum StatusAbsen { belumAbsen, sudahMasuk, sudahKeluar }

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class KaryawanDashboardScreen extends StatefulWidget {
  const KaryawanDashboardScreen({super.key});

  @override
  State<KaryawanDashboardScreen> createState() =>
      _KaryawanDashboardScreenState();
}

class _KaryawanDashboardScreenState extends State<KaryawanDashboardScreen>
    with SingleTickerProviderStateMixin {
  int _selectedNav = 0;
  int _notifCount = 2;

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isTokoAktif = true;

  // Status absensi hari ini
  StatusAbsen _statusAbsen = StatusAbsen.belumAbsen;
  String? _waktuMasuk;
  String? _waktuKeluar;
  bool _isAbsenLoading = false;

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

  // Data dummy shift
  final List<ShiftModel> _shifts = const [
    ShiftModel(
      nama: 'SIFT PAGI',
      jamMulai: '07.00',
      jamSelesai: '12.00',
      hari: 'SELASA',
      tanggal: '25 FEBRUARI 2026',
      status: StatusShift.selesai,
    ),
    ShiftModel(
      nama: 'SIFT SIANG',
      jamMulai: '12.00',
      jamSelesai: '16.00',
      hari: 'RABU',
      tanggal: '26 FEBRUARI 2026',
      status: StatusShift.berlangsung,
    ),
    ShiftModel(
      nama: 'SIFT SORE',
      jamMulai: '16.00',
      jamSelesai: '21.00',
      hari: 'KAMIS',
      tanggal: '27 FEBRUARI 2026',
      status: StatusShift.akan,
    ),
  ];

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() => _userData = doc.data());
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _displayName {
    if (_userData != null)
      return _userData!['nama'] ?? _userData!['username'] ?? 'Karyawan';
    return 'Karyawan';
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'selamat pagi';
    if (hour < 15) return 'selamat siang';
    if (hour < 18) return 'selamat sore';
    return 'selamat malam';
  }

  String get _jabatan => _userData?['jabatan'] ?? 'Staff';

  // ─── ABSENSI LOGIC ───────────────────────────────────────────
  Future<void> _handleAbsenMasuk() async {
    setState(() => _isAbsenLoading = true);
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // simulasi API call

    // TODO: Simpan ke Firestore
    // await FirebaseFirestore.instance.collection('absensi').add({
    //   'uid': _currentUser!.uid,
    //   'nama': _displayName,
    //   'type': 'masuk',
    //   'waktu': Timestamp.now(),
    //   'tanggal': DateFormat('yyyy-MM-dd').format(DateTime.now()),
    // });

    final now = DateTime.now();
    final waktu =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _statusAbsen = StatusAbsen.sudahMasuk;
      _waktuMasuk = waktu;
      _isAbsenLoading = false;
    });
    _showSnack('✅ Absen masuk berhasil pukul $waktu', kGreen);
  }

  Future<void> _handleAbsenKeluar() async {
    setState(() => _isAbsenLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Update ke Firestore
    // await FirebaseFirestore.instance.collection('absensi')
    //   .where('uid', isEqualTo: _currentUser!.uid)
    //   .where('tanggal', isEqualTo: ...)
    //   .get().then((snap) => snap.docs.first.reference.update({
    //     'waktuKeluar': Timestamp.now(),
    //     'type': 'keluar',
    //   }));

    final now = DateTime.now();
    final waktu =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    setState(() {
      _statusAbsen = StatusAbsen.sudahKeluar;
      _waktuKeluar = waktu;
      _isAbsenLoading = false;
    });
    _showSnack('✅ Absen keluar berhasil pukul $waktu', kBlue);
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: GoogleFonts.lato(color: kWhite, fontWeight: FontWeight.w600),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          // Tab 0 — HOME
          Column(
            children: [
              FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(),
                      const SizedBox(height: 16),
                      _buildAbsensiCard(),
                      const SizedBox(height: 16),
                      _buildStatusBadges(),
                      const SizedBox(height: 20),
                      _buildJadwalShift(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Tab 1 — KASIR (placeholder)
          _buildPlaceholder('💳', 'KASIR', 'Fitur kasir coming soon'),
          // Tab 2 — QUICK ACCESS (center button)
          _buildPlaceholder('⚡', 'QUICK ACCESS', 'Coming soon'),
          // Tab 3 — MENU
          _buildPlaceholder('🍔', 'MENU', 'Lihat daftar menu'),
          // Tab 4 — REKAP
          _buildPlaceholder('📊', 'REKAP', 'Rekap absensi & performa'),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildPlaceholder(String emoji, String title, String sub) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 52)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
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

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerIconBtn(Icons.settings_outlined, onTap: () {}),
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

  // ─── USER INFO CARD ──────────────────────────────────────────
  Widget _buildUserInfoCard() {
    return Container(
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
              color: kBlue.withOpacity(0.1),
              border: Border.all(color: kBlue.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/karyawan.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, color: kBlue, size: 26),
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
                  _displayName,
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
                      Icons.work_outline,
                      size: 10,
                      color: Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _jabatan,
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
          // Status toko
          GestureDetector(
            onTap: () => setState(() => _isTokoAktif = !_isTokoAktif),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _isTokoAktif
                    ? kGreen.withOpacity(0.1)
                    : kRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isTokoAktif ? kGreen : kRed,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isTokoAktif ? kGreen : kRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isTokoAktif ? 'AKTIF' : 'TUTUP',
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: _isTokoAktif ? kGreen : kRed,
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

  // ─── ABSENSI CARD ────────────────────────────────────────────
  Widget _buildAbsensiCard() {
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
          // Header absensi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.how_to_reg_rounded,
                      color: kBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'ABSENSI HARIAN',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: kTextDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              // Toggle toko
              Row(
                children: [
                  Text(
                    _isTokoAktif ? 'AKTIF' : 'TUTUP',
                    style: GoogleFonts.lato(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _isTokoAktif ? kGreen : kRed,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _isTokoAktif = !_isTokoAktif),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _isTokoAktif ? kGreen : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: _isTokoAktif
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: const BoxDecoration(
                            color: kWhite,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dua tombol absen
          Row(
            children: [
              Expanded(
                child: _absenBtn(
                  label: 'ABSEN MASUK',
                  emoji: '🤖',
                  sublabel: _waktuMasuk != null
                      ? 'masuk pukul $_waktuMasuk'
                      : 'belum absen',
                  isActive: _statusAbsen == StatusAbsen.sudahMasuk,
                  isDisabled:
                      _statusAbsen != StatusAbsen.belumAbsen || _isAbsenLoading,
                  color: kGreen,
                  onTap: _statusAbsen == StatusAbsen.belumAbsen
                      ? _handleAbsenMasuk
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _absenBtn(
                  label: 'ABSEN KELUAR',
                  emoji: '🚀',
                  sublabel: _waktuKeluar != null
                      ? 'keluar pukul $_waktuKeluar'
                      : 'belum absen',
                  isActive: _statusAbsen == StatusAbsen.sudahKeluar,
                  isDisabled:
                      _statusAbsen != StatusAbsen.sudahMasuk || _isAbsenLoading,
                  color: kBlue,
                  onTap: _statusAbsen == StatusAbsen.sudahMasuk
                      ? _handleAbsenKeluar
                      : null,
                ),
              ),
            ],
          ),

          if (_isAbsenLoading) ...[
            const SizedBox(height: 12),
            const Center(
              child: CircularProgressIndicator(strokeWidth: 2, color: kBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _absenBtn({
    required String label,
    required String emoji,
    required String sublabel,
    required bool isActive,
    required bool isDisabled,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : kBgLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? color : Colors.black12,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDisabled
                    ? Colors.black26
                    : (isActive ? color : kTextDark),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isActive
                        ? color
                        : (isDisabled ? Colors.black12 : kOrange),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    sublabel,
                    style: GoogleFonts.lato(fontSize: 9, color: Colors.black38),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS BADGES ───────────────────────────────────────────
  Widget _buildStatusBadges() {
    final badges = [
      _BadgeItem(
        icon: Icons.check_circle_rounded,
        label: 'TEPAT',
        color: kGreen,
        isActive:
            _statusAbsen == StatusAbsen.sudahMasuk ||
            _statusAbsen == StatusAbsen.sudahKeluar,
      ),
      _BadgeItem(
        icon: Icons.timelapse_rounded,
        label: 'TERLAMBAT',
        color: kOrange,
        isActive: false,
      ),
      _BadgeItem(
        icon: Icons.event_note_rounded,
        label: 'Izin',
        color: kBlueBg,
        isActive: false,
      ),
      _BadgeItem(
        icon: Icons.bar_chart_rounded,
        label: 'REKAP',
        color: kTextDark,
        isActive: false,
      ),
    ];

    return Row(
      children: badges
          .map(
            (b) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _showSnack('${b.label} — Coming Soon', kBlue),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: b.isActive ? b.color.withOpacity(0.1) : kWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: b.isActive
                            ? b.color.withOpacity(0.4)
                            : Colors.black12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: b.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(b.icon, color: b.color, size: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.label,
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: b.isActive ? b.color : Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  // ─── JADWAL SHIFT ────────────────────────────────────────────
  Widget _buildJadwalShift() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  color: kBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'JADWAL SIFT',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: kTextDark,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _showSnack('Kelola Shift — Coming Soon', kBlue),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'KELOLA SIFT',
                  style: GoogleFonts.lato(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: kBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._shifts.map((s) => _shiftCard(s)),
      ],
    );
  }

  Widget _shiftCard(ShiftModel shift) {
    Color color;
    String statusLabel;
    IconData shiftIcon;

    switch (shift.status) {
      case StatusShift.selesai:
        color = Colors.black26;
        statusLabel = 'SELESAI';
        shiftIcon = Icons.wb_sunny_outlined;
        break;
      case StatusShift.berlangsung:
        color = kGreen;
        statusLabel = 'BERLANGSUNG';
        shiftIcon = Icons.wb_cloudy_outlined;
        break;
      case StatusShift.akan:
        color = kOrange;
        statusLabel = 'AKAN DATANG';
        shiftIcon = Icons.nights_stay_outlined;
        break;
    }

    final isBerlangsung = shift.status == StatusShift.berlangsung;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: isBerlangsung ? Border.all(color: kGreen, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon shift
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(shiftIcon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          // Info shift
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shift.nama,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: shift.status == StatusShift.selesai
                        ? Colors.black38
                        : kTextDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${shift.hari} ${shift.tanggal}',
                  style: GoogleFonts.lato(fontSize: 10, color: Colors.black45),
                ),
                const SizedBox(height: 4),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Jam shift
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                shift.jamMulai,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isBerlangsung ? kGreen : kTextDark,
                ),
              ),
              Text(
                'S/D ${shift.jamSelesai}',
                style: GoogleFonts.lato(fontSize: 11, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ──────────────────────────────────────────────
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
              _navItem(
                1,
                Icons.point_of_sale_outlined,
                Icons.point_of_sale,
                'KASIR',
              ),
              // Center belah ketupat
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedNav = 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4A90D9), kBlue],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: kBlueBg.withOpacity(0.6),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
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
                                      text: 'E',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'X',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'OTIC',
                                      style: TextStyle(
                                        fontSize: 9,
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

class _BadgeItem {
  final IconData icon;
  final String label;
  final Color color;
  final bool isActive;
  const _BadgeItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.isActive,
  });
}
