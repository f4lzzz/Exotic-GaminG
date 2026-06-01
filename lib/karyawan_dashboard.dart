import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'absensi_screen.dart';
import 'login.dart';
import 'notifikasi_karyawan.dart';
import 'menu_karyawan.dart';
import 'kasir_data_page.dart';
import 'rekap_screen.dart';
import 'profil_karyawan.dart';
import 'registrasi_wajah_screen.dart';
import 'stok_karyawan_screen.dart';
import 'kirim_pengumuman.dart';
import 'kirim_pengumuman_karyawan.dart';

// ── WARNA ────────────────────────────────────────────────────────────────
const kBlue = Color(0xFF1A5EBF);
const kBlueDark = Color(0xFF0F3B8C);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kGold = Color(0xFFD4A017);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFF5A623);
const kBgLight = Color(0xFFF0F4FF);

// ─── MODEL SHIFT ────────────────────────────────────────────────────────
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

// ─── SCREEN ────────────────────────────────────────────────────────────
class KaryawanDashboardScreen extends StatefulWidget {
  const KaryawanDashboardScreen({super.key});

  @override
  State<KaryawanDashboardScreen> createState() =>
      _KaryawanDashboardScreenState();
}

class _KaryawanDashboardScreenState extends State<KaryawanDashboardScreen>
    with TickerProviderStateMixin {
  int _selectedNav = 0;
  int _unreadCount = 0; // ← ganti dari _notifCount

  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isTokoAktif = true;

  bool _sudahMasuk = false;
  bool _sudahPulang = false;
  String? _jamMasuk;
  String? _jamPulang;

  late Timer _clock;
  DateTime _now = DateTime.now();

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

  final List<ShiftModel> _shifts = const [
    ShiftModel(
      nama: 'SHIFT PAGI',
      jamMulai: '07.00',
      jamSelesai: '12.00',
      hari: 'SELASA',
      tanggal: '25 FEBRUARI 2026',
      status: StatusShift.selesai,
    ),
    ShiftModel(
      nama: 'SHIFT SIANG',
      jamMulai: '12.00',
      jamSelesai: '16.00',
      hari: 'RABU',
      tanggal: '26 FEBRUARI 2026',
      status: StatusShift.berlangsung,
    ),
    ShiftModel(
      nama: 'SHIFT SORE',
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
    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));
    _loadUserData();
    _listenToUnreadPengumuman(); // ← tambahkan ini
  }

  // Fungsi baru: mendengarkan jumlah pengumuman yang belum dibaca
  void _listenToUnreadPengumuman() {
    FirebaseFirestore.instance
        .collection('pengumuman')
        .where('dibaca', isEqualTo: 0)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _unreadCount = snapshot.docs.length;
        });
      }
    });
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
      if (doc.exists && mounted) setState(() => _userData = doc.data());
    } catch (_) {}
  }

  @override
  void dispose() {
    _clock.cancel();
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String get _displayName =>
      _userData?['nama'] ?? _userData?['username'] ?? 'Karyawan';
  String get _greeting {
    final h = _now.hour;
    if (h < 11) return 'selamat pagi';
    if (h < 15) return 'selamat siang';
    if (h < 18) return 'selamat sore';
    return 'selamat malam';
  }

  String get _jabatan => _userData?['jabatan'] ?? 'Staff';
  bool get _isAdmin => _userData?['role'] == 'admin';

  void _bukaAbsensi(AbsensiType type) async {
    if (type == AbsensiType.masuk && _sudahMasuk) {
      _snack('Kamu sudah absen masuk hari ini!');
      return;
    }
    if (type == AbsensiType.pulang && _sudahPulang) {
      _snack('Kamu sudah absen pulang hari ini!');
      return;
    }
    if (type == AbsensiType.pulang && !_sudahMasuk) {
      _snack('Absen masuk dulu sebelum absen pulang!', isErr: true);
      return;
    }
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AbsensiScreen(type: type)),
    );
    if (result == true && mounted) {
      setState(() {
        if (type == AbsensiType.masuk) {
          _sudahMasuk = true;
          _jamMasuk = DateFormat('HH:mm').format(DateTime.now());
        } else {
          _sudahPulang = true;
          _jamPulang = DateFormat('HH:mm').format(DateTime.now());
        }
      });
    }
  }

  void _snack(String msg, {bool isErr = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.lato(fontWeight: FontWeight.w700)),
      backgroundColor: isErr ? kRed : kOrange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgLight,
      body: IndexedStack(
        index: _selectedNav,
        children: [
          Column(
            children: [
              FadeTransition(opacity: _fadeAnim, child: _buildHeader()),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollCtrl,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(),
                      const SizedBox(height: 16),
                      _buildAbsensiCard(),
                      const SizedBox(height: 16),
                      _buildShiftCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const KasirDataPage(kasirName: '', shift: ''),
          const KirimPengumumanKaryawanScreen(),
          const StokKaryawanScreen(),
          const RekapScreen(role: 'karyawan'),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ========================= HEADER =========================
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

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerIconBtn(
          Icons.settings_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilKaryawanScreen()),
          ),
        ),
        const SizedBox(width: 6),
        _headerIconBtn(
          Icons.notifications_outlined,
          badge: _unreadCount, // ← pakai _unreadCount
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiKaryawanScreen()),
          ),
        ),
      ],
    );

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF4A90D9), kBlue]),
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

  Widget _headerIconBtn(IconData icon,
      {int badge = 0, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration:
                    const BoxDecoration(color: kRed, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '$badge',
                    style: GoogleFonts.lato(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: kWhite),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========================= USER INFO CARD =========================
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
              offset: const Offset(0, 3))
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
                'assets/images/karyawan.jpg',
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
                Text(_greeting,
                    style:
                        GoogleFonts.lato(fontSize: 11, color: Colors.black45)),
                Text(_displayName,
                    style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: kTextDark)),
                Row(
                  children: [
                    const Icon(Icons.work_outline,
                        size: 10, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(_jabatan,
                        style: GoogleFonts.lato(
                            fontSize: 10, color: Colors.black38)),
                  ],
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isTokoAktif = !_isTokoAktif),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: (_isTokoAktif ? kGreen : kRed).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: _isTokoAktif ? kGreen : kRed,
                          shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(_isTokoAktif ? 'AKTIF' : 'TUTUP',
                      style: GoogleFonts.lato(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: _isTokoAktif ? kGreen : kRed)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================= ABSENSI CARD =========================
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
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ABSENSI HARIAN',
                  style: GoogleFonts.lato(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: kTextDark)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: kGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text('AKTIF',
                        style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kGreen)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _absenButton(
                  label: 'ABSEN MASUK',
                  icon: Icons.door_front_door,
                  sudah: _sudahMasuk,
                  jam: _jamMasuk,
                  color: kBlue,
                  onTap: () => _bukaAbsensi(AbsensiType.masuk),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _absenButton(
                  label: 'ABSEN KELUAR',
                  icon: Icons.exit_to_app,
                  sudah: _sudahPulang,
                  jam: _jamPulang,
                  color: kBlue,
                  onTap: () => _bukaAbsensi(AbsensiType.pulang),
                ),
              ),
            ],
          ),
          if (_isAdmin) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RegistrasiWajahScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: kBlue.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBlue.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_add_rounded,
                        color: kBlue, size: 16),
                    const SizedBox(width: 8),
                    Text('DAFTARKAN WAJAH KARYAWAN',
                        style: GoogleFonts.lato(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: kBlue)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _absenButton({
    required String label,
    required IconData icon,
    required bool sudah,
    required String? jam,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                  color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(icon, color: kWhite, size: 34),
            ),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                    color: kWhite, fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: sudah ? kGreen : kRed,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: kWhite, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(sudah ? '✓ $jam' : 'belum absen',
                      style: GoogleFonts.lato(
                          color: kWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= SHIFT CARD =========================
  Widget _buildShiftCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: kBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.calendar_today,
                        color: kBlue, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text('JADWAL SHIFT',
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: kTextDark)),
                ],
              ),
              GestureDetector(
                onTap: () => _snack('Kelola Shift — Coming Soon'),
                child: Text('KELOLA SHIFT',
                    style: GoogleFonts.lato(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kBlue)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._shifts.map((s) => _buildShiftTile(s)),
        ],
      ),
    );
  }

  Widget _buildShiftTile(ShiftModel shift) {
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isBerlangsung ? kBlue.withOpacity(0.08) : const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(14),
        border: isBerlangsung
            ? Border.all(color: kBlue.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(shiftIcon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.nama,
                    style: GoogleFonts.lato(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: shift.status == StatusShift.selesai
                            ? Colors.black38
                            : kTextDark)),
                Text('${shift.hari} ${shift.tanggal}',
                    style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black38,
                        fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(statusLabel,
                      style: GoogleFonts.lato(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: color)),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(shift.jamMulai,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isBerlangsung ? kGreen : kTextDark)),
              Text('S/D ${shift.jamSelesai}',
                  style: GoogleFonts.lato(
                      fontSize: 10,
                      color: Colors.black38,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ========================= BOTTOM NAVBAR =========================
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _navItem(0, Icons.home_outlined, Icons.home, 'HOME'),
              _navItem(1, Icons.point_of_sale_outlined, Icons.point_of_sale,
                  'KASIR'),
              _navItem(
                  2, Icons.chat_bubble_outline, Icons.chat_bubble, 'ANNOUNCE'),
              _navItem(3, Icons.menu_outlined, Icons.menu, 'STOK'),
              _navItem(4, Icons.bar_chart_outlined, Icons.bar_chart, 'REKAP'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _selectedNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedNav = index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? filledIcon : outlineIcon,
                  color: isSelected ? kBlue : Colors.black38, size: 22),
              const SizedBox(height: 3),
              Text(label,
                  style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w500,
                      color: isSelected ? kBlue : Colors.black38)),
            ],
          ),
        ),
      ),
    );
  }
}
