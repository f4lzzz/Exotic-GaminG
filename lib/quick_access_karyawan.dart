import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _qkBlue     = Color(0xFF5B8DEE);
const _qkBlueDark = Color(0xFF2C5FC4);
const _qkTextDark = Color(0xFF1A2A4A);
const _qkBgLight  = Color(0xFFDDE8F8);
const _qkWhite    = Color(0xFFFFFFFF);
const _qkGreen    = Color(0xFF27AE60);
const _qkOrange   = Color(0xFFF5A623);
const _qkRed      = Color(0xFFE74C3C);
const _qkPurple   = Color(0xFF9B59B6);

class QuickAccessKaryawanScreen extends StatefulWidget {
  const QuickAccessKaryawanScreen({super.key});

  @override
  State<QuickAccessKaryawanScreen> createState() =>
      _QuickAccessKaryawanScreenState();
}

class _QuickAccessKaryawanScreenState extends State<QuickAccessKaryawanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _qkBgLight,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('⚡ AKSI CEPAT'),
                    const SizedBox(height: 12),
                    _buildGrid(),
                    const SizedBox(height: 24),
                    _sectionLabel('📈 INFO HARI INI'),
                    const SizedBox(height: 12),
                    _buildInfoCards(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6BAAF5), _qkBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 20),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: _qkWhite, height: 1.0),
              children: const [
                TextSpan(text: 'E', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                TextSpan(text: 'X', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
                TextSpan(text: 'OTIC', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('GAMING & CAFE',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 11, color: const Color(0xFFCDD8F0), letterSpacing: 3)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _qkWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('QUICK ACCESS',
                style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w900, color: _qkWhite, letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w800, color: _qkTextDark, letterSpacing: 0.5));

  Widget _buildGrid() {
    final items = [
      _QAItem(emoji: '📋', label: 'Lihat\nJadwal',  color: _qkBlue,    onTap: () => _snack('Lihat Jadwal')),
      _QAItem(emoji: '🕐', label: 'Cek\nAbsensi',   color: _qkGreen,   onTap: () => _snack('Cek Absensi')),
      _QAItem(emoji: '💬', label: 'Pesan\nMasuk',   color: _qkPurple,  onTap: () => _snack('Pesan Masuk')),
      _QAItem(emoji: '📊', label: 'Rekap\nSaya',    color: _qkOrange,  onTap: () => _snack('Rekap Saya')),
      _QAItem(emoji: '🏖️', label: 'Ajukan\nIzin',   color: _qkRed,     onTap: () => _snack('Ajukan Izin')),
      _QAItem(emoji: '💰', label: 'Slip\nGaji',     color: _qkGreen,   onTap: () => _snack('Slip Gaji')),
      _QAItem(emoji: '🔔', label: 'Notifi-\nkasi',  color: _qkBlue,    onTap: () => _snack('Notifikasi')),
      _QAItem(emoji: '⚙️', label: 'Pengaturan',     color: _qkTextDark,onTap: () => _snack('Pengaturan')),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.85,
      children: items.map(_qaCard).toList(),
    );
  }

  Widget _qaCard(_QAItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _qkWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: item.color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: 6),
            Text(item.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w700, color: _qkTextDark, height: 1.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        Row(children: [
          Expanded(child: _infoCard('⏰', 'Jam Masuk', '08:00', _qkBlue)),
          const SizedBox(width: 10),
          Expanded(child: _infoCard('📅', 'Jadwal', 'Shift Pagi', _qkGreen)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _infoCard('🎮', 'Status', 'Aktif Kerja', _qkOrange)),
          const SizedBox(width: 10),
          Expanded(child: _infoCard('💰', 'Gaji', 'Lihat Detail', _qkPurple)),
        ]),
      ],
    );
  }

  Widget _infoCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _qkWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w900, color: _qkTextDark)),
                Text(label, style: GoogleFonts.lato(fontSize: 9, color: Colors.black38, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$label — Coming Soon', style: const TextStyle(fontWeight: FontWeight.w700)),
      backgroundColor: _qkBlue,
      duration: const Duration(seconds: 1),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}

class _QAItem {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QAItem({required this.emoji, required this.label, required this.color, required this.onTap});
}
