import 'dart:async'; // jam dan timer
import 'package:flutter/material.dart'; // untuk  tampilan ui
import 'package:google_fonts/google_fonts.dart'; // untuk font
import 'package:intl/intl.dart'; // untuk format tanggal dan waktu
import 'package:firebase_auth/firebase_auth.dart'; // untuk autentikasi user
import 'package:cloud_firestore/cloud_firestore.dart'; // untuk ambil data user dari firestore atau calud
import 'absensi_screen.dart'; // panggil sccren absen
import 'login.dart'; // panggil screen login
import 'notifikasi_karyawan.dart'; // panggil notiv
import 'menu_karyawan.dart'; // panggil menu
import 'quick_access_karyawan.dart'; // panggil menu cepat
import 'kasir_pos_screen.dart'; // pangggil kasir
import 'profil_karyawan.dart'; // panggil profil karyawan
import 'registrasi_wajah_screen.dart'; // pamggol regristasi wajah

// ── WARNA ─────────────────────────────────────────────────────────────────────
const kBlue = Color(0xFF5B8DEE);
const kBlueDark = Color(0xFF2C5FC4);
const kBlueBg = Color(0xFFDDE8F8);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFCDD8F0);
const kTextDark = Color(0xFF1A2A4A);
const kTextMid = Color(0xFF5B7AAA);
const kGreen = Color(0xFF27AE60);
const kRed = Color(0xFFE74C3C);
const kOrange = Color(0xFFF5A623);
const kBgLight = Color(0xFFDDE8F8);

// ─── MODEL SHIFT ──────────────────────────────────────────────────────────────
class ShiftModel {
  // membuat cetakan agar lebih rapi
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

// ─── SCREEN ───────────────────────────────────────────────────────────────────
class KaryawanDashboardScreen extends StatefulWidget {
  // deklarasi halaman dapat berubah
  const KaryawanDashboardScreen({super.key});

  @override
  State<KaryawanDashboardScreen>
      createState() => //  menghubungkan statefulwidget dengan statenya "ini tampilan dan ini daya yag bisa berubah"
          _KaryawanDashboardScreenState();
}

class _KaryawanDashboardScreenState extends State<KaryawanDashboardScreen>
    with TickerProviderStateMixin {
  // class private dan  membuat animasi dengan triker provider
  int _selectedNav =
      0; //  menentukan buutom navigasi mana yang aktif 0-> home,halam yang pertama kali di buka
  int _notifCount = 2; // jumlah notivikasi yang belum dibaca

  User?
      _currentUser; // user  yang sedang login dari firebase auth ,jika tidak ada bernilai nul
  Map<String, dynamic>?
      _userData; // data  tambahan dari firestore (nama,jabatan,foto)
  bool _isTokoAktif = true; // status toko bisa di ubah

  // ── state absensi ──────────────────────────────────────────────
  bool _sudahMasuk = false; // apakah karyawan sudah absen masuk hari ini
  bool _sudahPulang = false; // apakah karyawan sudah apsen pulang hari ini
  String? _jamMasuk; // jam masuk absen yang ditampilkan
  String? _jamPulang; // jam pulang absen

  // ── clock ──────────────────────────────────────────────────────
  late Timer _clock; // timer update jam tiap detik
  DateTime _now = DateTime.now();

<<<<<<< HEAD
  late AnimationController _pulseCtrl; // untuk  animasi pulse pada tombol absen
  late Animation<double> _pulse; // nilai anamasi yang membesar mengecil
  late AnimationController
      _fadeCtrl; // mengontrol animasi yang muncul perlahan saat halaman dibuka
  late Animation<double> _fadeAnim; // nilai animasi (0->1) untuk transisi halus
=======
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;
  late AnimationController _fadeCtrl;
  late Animation<double>   _fadeAnim;
>>>>>>> 6c6d98b221ca52fe263c914cfa76aa13c6b21e5a

  final _scrollCtrl = ScrollController(); //deteksi posisi scroll
  double _scrollOffset =
      0; // menyimpan posisis seberapa jauh user scroll dalam pixel

  static const double _headerExpanded =
      120.0; // tinggi herder saat  belum di scroll
  static const double _headerCollapsed =
      60.0; // tinggi herder saat sudah di scroll penuh
  static const double _collapseAt =
      70.0; // scroll sejauh 70PX untuk mengecilkan herder

  double get _collapseProgress => (_scrollOffset / _collapseAt)
      .clamp(0.0, 1.0); //menghitung seberapa jauh proses pengecilan herder
  double get _headerHeight =>
      _headerExpanded -
      (_headerExpanded - _headerCollapsed) * _collapseProgress;

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

    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween(begin: 0.95, end: 1.05)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();

    _scrollCtrl
        .addListener(() => setState(() => _scrollOffset = _scrollCtrl.offset));

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
      if (doc.exists && mounted) setState(() => _userData = doc.data());
    } catch (_) {}
  }

  @override
  void dispose() {
    _clock.cancel();
    _pulseCtrl.dispose();
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

  // ── LOGIKA ABSENSI ─────────────────────────────────────────────
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
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: isErr ? kRed : kOrange,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ─── BUILD ────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('HH:mm').format(_now);
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(_now);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB8D4F8), kBgLight, Color(0xFFCDD8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(
          index: _selectedNav,
          children: [
            // Tab 0 — HOME
            Column(
              children: [
                FadeTransition(
                    opacity: _fadeAnim, child: _buildHeader(timeStr, dateStr)),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
                    child: Column(
                      children: [
                        _buildUserInfoCard(),
                        const SizedBox(height: 14),
                        _buildAbsensiCard(),
                        const SizedBox(height: 14),
                        _buildStatusRow(),
                        const SizedBox(height: 14),
                        _buildShiftCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const KasirPosScreen(),
            const QuickAccessKaryawanScreen(),
            const MenuKaryawanScreen(),
            _buildPlaceholder('📊', 'REKAP', 'Rekap absensi & performa'),
          ],
        ),
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
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w900, color: kTextDark)),
          const SizedBox(height: 4),
          Text(sub, style: const TextStyle(fontSize: 13, color: kTextMid)),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────
  Widget _buildHeader(String timeStr, String dateStr) {
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

    final subWidget = Text('GAMING & CAFE',
        style: GoogleFonts.playfairDisplay(
            fontSize: subSize,
            color: kWhiteDim,
            letterSpacing: 3,
            fontWeight: FontWeight.w400));

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ← PERBAIKAN: ProfilKaryawanScreen tanpa parameter
        _headerIconBtn(Icons.settings_outlined,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ProfilKaryawanScreen()))),
        const SizedBox(width: 6),
        _headerIconBtn(Icons.notifications_outlined,
            badge: _notifCount,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotifikasiKaryawanScreen()))),
      ],
    );

    return AnimatedContainer(
      duration: Duration.zero,
      height: _headerHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6BAAF5), Color(0xFF3A72D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, padTop, 20, padBot),
      child: p < 0.5
          ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(children: [
                logoWidget,
                const SizedBox(width: 6),
                Opacity(opacity: subOpacity, child: subWidget),
                const Spacer(),
                iconButtons,
              ])
            ])
          : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              logoWidget,
              const SizedBox(width: 8),
              subWidget,
              const Spacer(),
              iconButtons,
            ]),
    );
  }

  Widget _headerIconBtn(IconData icon,
      {int badge = 0, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
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
                  const BoxDecoration(color: kOrange, shape: BoxShape.circle),
              child: Center(
                child: Text('$badge',
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: kWhite)),
              ),
            ),
          ),
      ]),
    );
  }

  // ─── USER INFO CARD ───────────────────────────────────────────
  Widget _buildUserInfoCard() {
    final photoUrl = _userData?['photoUrl'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kBlue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
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
              child: (photoUrl != null && photoUrl.isNotEmpty)
                  ? Image.network(photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, color: kBlue, size: 26))
                  : Image.asset('assets/images/karyawan.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.person, color: kBlue, size: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_greeting,
                    style: const TextStyle(fontSize: 11, color: kTextMid)),
                Text(_displayName,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: kTextDark),
                    overflow: TextOverflow.ellipsis),
                Row(children: [
                  const Icon(Icons.work_outline, size: 10, color: kTextMid),
                  const SizedBox(width: 4),
                  Text(_jabatan,
                      style: const TextStyle(fontSize: 10, color: kTextMid)),
                ]),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _isTokoAktif = !_isTokoAktif),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (_isTokoAktif ? kGreen : kRed).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: _isTokoAktif ? kGreen : kRed,
                      shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(_isTokoAktif ? 'AKTIF' : 'TUTUP',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _isTokoAktif ? kGreen : kRed)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ABSENSI CARD ─────────────────────────────────────────────
  Widget _buildAbsensiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kBlue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ABSENSI HARIAN',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: kTextDark)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: kGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                          color: kGreen, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  const Text('AKTIF',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kGreen)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _absenButton(
                  label: 'ABSEN MASUK',
                  sudah: _sudahMasuk,
                  jam: _jamMasuk,
                  color: kBlue,
                  imagePath: 'assets/images/go_orion.png',
                  onTap: () => _bukaAbsensi(AbsensiType.masuk),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _absenButton(
                  label: 'ABSEN KELUAR',
                  sudah: _sudahPulang,
                  jam: _jamPulang,
                  color: kBlueDark,
                  imagePath: 'assets/images/go_orion.png',
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
                  builder: (_) => const RegistrasiWajahScreen(),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: kBlueDark.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBlueDark.withOpacity(0.25)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded, color: kBlueDark, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'DAFTARKAN WAJAH KARYAWAN',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: kBlueDark),
                    ),
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
    required bool sudah,
    required String? jam,
    required Color color,
    required String imagePath,
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
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Text('🚀', style: TextStyle(fontSize: 34))),
              ),
            ),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: kWhite, fontWeight: FontWeight.w900, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: sudah ? kGreen : kRed,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: kWhite, shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(sudah ? '✓ $jam' : 'belum absen',
                    style: const TextStyle(
                        color: kWhite,
                        fontSize: 10,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  // ─── STATUS ROW ───────────────────────────────────────────────
  Widget _buildStatusRow() {
    final items = [
      {'icon': Icons.check_circle_rounded, 'label': 'TEPAT', 'color': kGreen},
      {'icon': Icons.timer_rounded, 'label': 'TERLAMBAT', 'color': kOrange},
      {'icon': Icons.assignment_rounded, 'label': 'izin', 'color': kTextMid},
      {'icon': Icons.bar_chart_rounded, 'label': 'REKAP', 'color': kRed},
    ];

    return Row(
      children: items
          .map((item) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: (item['color'] as Color).withOpacity(0.25)),
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: item['color'] as Color, size: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(item['label'] as String,
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: kTextMid)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ─── SHIFT CARD ───────────────────────────────────────────────
  Widget _buildShiftCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: kBlue.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: kBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Image.asset('assets/images/calendar_icon.png',
                      width: 18,
                      height: 18,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.calendar_today,
                          color: kBlue,
                          size: 18)),
                ),
                const SizedBox(width: 8),
                const Text('JADWAL SIFT',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        color: kTextDark)),
              ]),
              GestureDetector(
                onTap: () => _snack('Kelola Shift — Coming Soon'),
                child: const Text('KELOLA SIFT',
                    style: TextStyle(
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
            isBerlangsung ? kBlue.withOpacity(0.08) : const Color(0xFFE8F0FB),
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
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        color: shift.status == StatusShift.selesai
                            ? Colors.black38
                            : kTextDark)),
                Text('${shift.hari} ${shift.tanggal}',
                    style: const TextStyle(
                        fontSize: 10,
                        color: kTextMid,
                        fontWeight: FontWeight.w600)),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(statusLabel,
                      style: TextStyle(
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
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: isBerlangsung ? kGreen : kTextDark)),
              Text('S/D ${shift.jamSelesai}',
                  style: const TextStyle(
                      fontSize: 10,
                      color: kTextMid,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────────────
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
                              colors: [Color(0xFF6BAAF5), kBlueDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                  color: kBlue.withOpacity(0.6),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3))
                            ],
                          ),
                          child: Transform.rotate(
                            angle: -0.785,
                            child: Center(
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.playfairDisplay(
                                      color: kWhite, height: 1.0),
                                  children: const [
                                    TextSpan(
                                        text: 'E',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400)),
                                    TextSpan(
                                        text: 'X',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    TextSpan(
                                        text: 'OTIC',
                                        style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w400)),
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
      int index, IconData outlineIcon, IconData filledIcon, String label) {
    final isSelected = _selectedNav == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedNav = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? filledIcon : outlineIcon,
                color: isSelected ? kBlue : Colors.black38, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected ? kBlue : Colors.black38)),
          ],
        ),
      ),
    );
  }
}
