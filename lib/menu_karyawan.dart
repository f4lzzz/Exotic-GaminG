import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _mkBlue     = Color(0xFF5B8DEE);
const _mkBlueDark = Color(0xFF2C5FC4);
const _mkTextDark = Color(0xFF1A2A4A);
const _mkTextMid  = Color(0xFF5B7AAA);
const _mkBgLight  = Color(0xFFDDE8F8);
const _mkWhite    = Color(0xFFFFFFFF);

class MenuKaryawanScreen extends StatefulWidget {
  const MenuKaryawanScreen({super.key});

  @override
  State<MenuKaryawanScreen> createState() => _MenuKaryawanScreenState();
}

class _MenuKaryawanScreenState extends State<MenuKaryawanScreen> {
  final List<_MenuItem> _menus = const [
    _MenuItem(emoji: '📋', label: 'Lihat Jadwal Sift', color: Color(0xFF5B8DEE)),
    _MenuItem(emoji: '🕐', label: 'Riwayat Absensi',  color: Color(0xFF27AE60)),
    _MenuItem(emoji: '💬', label: 'Pesan Internal',    color: Color(0xFF9B59B6)),
    _MenuItem(emoji: '📊', label: 'Performa Saya',     color: Color(0xFFF5A623)),
    _MenuItem(emoji: '🏖️', label: 'Ajukan Izin',       color: Color(0xFFE74C3C)),
    _MenuItem(emoji: '💰', label: 'Slip Gaji',         color: Color(0xFF1ABC9C)),
    _MenuItem(emoji: '📦', label: 'Daftar Produk',     color: Color(0xFFE67E22)),
    _MenuItem(emoji: '⚙️', label: 'Pengaturan',        color: Color(0xFF7F8C8D)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mkBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MENU KARYAWAN',
                      style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _mkTextDark,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: _menus.map(_buildMenuCard).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6BAAF5), _mkBlueDark],
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
              style: GoogleFonts.playfairDisplay(color: _mkWhite, height: 1.0),
              children: const [
                TextSpan(
                    text: 'E',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                TextSpan(
                    text: 'X',
                    style:
                        TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
                TextSpan(
                    text: 'OTIC',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('GAMING & CAFE',
              style: GoogleFonts.playfairDisplay(
                  fontSize: 11, color: const Color(0xFFCDD8F0), letterSpacing: 3)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _mkWhite.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('MENU',
                style: GoogleFonts.lato(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: _mkWhite,
                    letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(_MenuItem item) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.label} — Coming Soon',
              style: const TextStyle(fontWeight: FontWeight.w700)),
          backgroundColor: _mkBlue,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 1),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _mkWhite,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: _mkBlue.withOpacity(0.09),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(item.emoji,
                    style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(item.label,
                  style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _mkTextDark,
                      height: 1.3)),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final String emoji;
  final String label;
  final Color color;
  const _MenuItem(
      {required this.emoji, required this.label, required this.color});
}
