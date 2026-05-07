import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';

// ==================== DATA MODEL ====================
class _MenuTileData {
  final String icon, title, subtitle;
  final Color iconBg;
  final Color? titleColor;
  final Color? bgColor;
  final VoidCallback onTap;
  const _MenuTileData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.titleColor,
    this.bgColor,
  });
}

// ==================== PROFIL KARYAWAN SCREEN ====================
class ProfilKaryawanScreen extends StatelessWidget {
  final Map<String, dynamic>? userData;
  final User? currentUser;

  const ProfilKaryawanScreen({super.key, this.userData, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 16),
                  _buildSectionLabel('👤', 'AKUN'),
                  const SizedBox(height: 8),
                  _buildMenuGroup([
                    _MenuTileData(
                      icon: '🤖',
                      iconBg: const Color(0xFFDBEAFE),
                      title: 'EDIT PROFIL',
                      subtitle: 'Ubah nama, foto dan info akun',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfilKaryawanScreen())),
                    ),
                    _MenuTileData(
                      icon: '🔑',
                      iconBg: const Color(0xFFFEF9C3),
                      title: 'UBAH PASSWORD',
                      subtitle: 'Ganti password akun karyawan',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) => const UbahPasswordKaryawanScreen())),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionLabel('⚠️', 'LAINNYA'),
                  const SizedBox(height: 8),
                  _buildMenuGroup([
                    _MenuTileData(
                      icon: '🔄',
                      iconBg: const Color(0xFFFEE2E2),
                      title: 'Reset Data aplikasi',
                      subtitle: 'Hapus semua data mulai dari ulang',
                      titleColor: const Color(0xFFEF4444),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ResetDataScreen())),  
                    ),
                    _MenuTileData(
                      icon: '🗑️',
                      iconBg: const Color(0xFF374151),
                      title: 'Hapus akun',
                      subtitle: 'Hapus semua data mulai dari ulang',
                      titleColor: Colors.white,
                      bgColor: const Color(0xFF374151),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const HapusAkunScreen())), 
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _buildSectionLabel('📞', 'BANTUAN'),
                  const SizedBox(height: 8),
                  _buildMenuGroup([
                    _MenuTileData(
                      icon: '❓',
                      iconBg: const Color(0xFFDBEAFE),
                      title: 'SUPPORT',
                      subtitle: 'Hubungi tim support',
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const SupportScreen())),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildLogoutBtn(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(40),
        bottomRight: Radius.circular(40),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35, 
                right: -25,
                child: Container(
                  width: 100, 
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34, 
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.settings_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('PENGATURAN',
                              style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15)),
                        ]),
                        Text('Exotic gaming & cafe',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    final displayName = userData?['nama'] ?? userData?['username'] ?? 'Karyawan';
    final jabatan = userData?['jabatan'] ?? 'Staff';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 60, 
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                  colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
            ),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 32))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFD700)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🏷️', style: TextStyle(fontSize: 10)),
                      const SizedBox(width: 4),
                      Text(jabatan.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44, 
            height: 44,
            decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12)),
            child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 22))),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppTheme.textMuted,
                letterSpacing: 1)),
      ],
    );
  }

  Widget _buildMenuGroup(List<_MenuTileData> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.blue.withOpacity(0.07),
              blurRadius: 16,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              GestureDetector(
                onTap: item.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    color: item.bgColor ?? Colors.transparent,
                    borderRadius: isLast
                        ? const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20))
                        : null,
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42, 
                        height: 42,
                        decoration: BoxDecoration(
                            color: item.iconBg,
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Text(item.icon,
                                style: const TextStyle(fontSize: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: item.titleColor ??
                                        AppTheme.textPrimary)),
                            Text(item.subtitle,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: item.bgColor != null
                                        ? Colors.white70
                                        : AppTheme.textMuted)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          color: item.bgColor != null
                              ? Colors.white54
                              : AppTheme.textMuted,
                          size: 20),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 68, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutBtn(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('KELUAR DARI AKUN',
                style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final displayName = userData?['nama'] ?? userData?['username'] ?? 'Karyawan';

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56, 
                height: 56,
                decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(16)),
                child: const Center(
                    child: Icon(Icons.logout_rounded,
                        color: Color(0xFFEF4444), size: 28)),
              ),
              const SizedBox(height: 16),
              const Text('KELUAR DARI AKUN',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🤖', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 6),
              const Text('Anda yakin keluar dari akun?',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE0EAFF),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                            child: Text('BATAL',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                    fontSize: 13))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [
                            Color(0xFFEF4444),
                            Color(0xFFDC2626)
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text('KELUAR',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== RESET DATA SCREEN ====================
class ResetDataScreen extends StatefulWidget {
  const ResetDataScreen({super.key});
  @override
  State<ResetDataScreen> createState() => _ResetDataScreenState();
}

class _ResetDataScreenState extends State<ResetDataScreen> {
  bool _resetTransaksi = false;
  bool _resetProduk = false;
  bool _resetKaryawan = false;
  bool _resetPengaturan = false;
  bool _isLoading = false;

  int get _selectedCount =>
      [_resetTransaksi, _resetProduk, _resetKaryawan, _resetPengaturan]
          .where((e) => e)
          .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44, 
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 22))),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('PERHATIAN!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFFDC2626))),
                              SizedBox(height: 2),
                              Text('Data yang direset tidak dapat dikembalikan. Pastikan sudah backup data sebelum melanjutkan.', style: TextStyle(fontSize: 11, color: Color(0xFF991B1B))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PILIH DATA YANG DIRESET', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        _resetTile(emoji: '🧾', title: 'Data Transaksi', subtitle: 'Semua riwayat penjualan & pembayaran', color: const Color(0xFFFEE2E2), value: _resetTransaksi, onChanged: (v) => setState(() => _resetTransaksi = v ?? false)),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _resetTile(emoji: '📦', title: 'Data Produk', subtitle: 'Semua menu & stok produk', color: const Color(0xFFDBEAFE), value: _resetProduk, onChanged: (v) => setState(() => _resetProduk = v ?? false)),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _resetTile(emoji: '👥', title: 'Data Karyawan', subtitle: 'Semua akun & data karyawan', color: const Color(0xFFD1FAE5), value: _resetKaryawan, onChanged: (v) => setState(() => _resetKaryawan = v ?? false)),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _resetTile(emoji: '⚙️', title: 'Pengaturan Aplikasi', subtitle: 'Reset ke pengaturan awal', color: const Color(0xFFFEF9C3), value: _resetPengaturan, onChanged: (v) => setState(() => _resetPengaturan = v ?? false)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedCount > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFFFFF3CD), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFFD700))),
                      child: Row(children: [const Text('⚠️', style: TextStyle(fontSize: 18)), const SizedBox(width: 10), Expanded(child: Text('$_selectedCount data terpilih akan direset secara permanen.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFB45309))))]),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Center(
                              child: Text(
                                'BATAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _selectedCount > 0 ? () => _showConfirmDialog(context) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _selectedCount > 0
                                    ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                    : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _selectedCount > 0
                                  ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                                  : [],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🔄', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 6),
                                Text('RESET SEKARANG', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resetTile({required String emoji, required String title, required String subtitle, required Color color, required bool value, required ValueChanged<bool?> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('🔄', style: TextStyle(fontSize: 32))),
              ),
              const SizedBox(height: 14),
              const Text(
                'KONFIRMASI RESET',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                '$_selectedCount data yang dipilih akan dihapus permanen dan tidak bisa dikembalikan!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(color: const Color(0xFFE0EAFF), borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text(
                            'BATAL',
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        setState(() => _isLoading = true);
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() => _isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Data berhasil direset ✅'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF10B981),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFEF4444), Color(0xFFDC2626)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'YA, RESET',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)])),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('RESET DATA', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                        Text('Exotic gaming & cafe', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== HAPUS AKUN SCREEN ====================
class HapusAkunScreen extends StatefulWidget {
  const HapusAkunScreen({super.key});
  @override
  State<HapusAkunScreen> createState() => _HapusAkunScreenState();
}

class _HapusAkunScreenState extends State<HapusAkunScreen> {
  final _passCtrl = TextEditingController();
  final _konfirmasiCtrl = TextEditingController();
  bool _showPass = false;
  bool _setuju = false;

  bool get _canDelete => _passCtrl.text.isNotEmpty && _konfirmasiCtrl.text == 'HAPUS AKUN' && _setuju;

  @override
  void dispose() {
    _passCtrl.dispose();
    _konfirmasiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: const Color(0xFFEF4444), borderRadius: BorderRadius.circular(18)),
                          child: const Center(child: Text('🗑️', style: TextStyle(fontSize: 30))),
                        ),
                        const SizedBox(height: 12),
                        Text('HAPUS AKUN', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('M.Sifaul qulub', style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.5)),
                          ),
                          child: const Text('⚠️ TINDAKAN INI TIDAK BISA DIBATALKAN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFFFCA5A5))),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('YANG AKAN TERJADI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5)),
                        const SizedBox(height: 12),
                        _konsekuensiItem('❌', 'Akun kamu akan dihapus permanen'),
                        _konsekuensiItem('❌', 'Semua data pribadi akan dihapus'),
                        _konsekuensiItem('❌', 'Riwayat transaksi akan hilang'),
                        _konsekuensiItem('❌', 'Tidak bisa login kembali dengan akun ini'),
                        _konsekuensiItem('❌', 'Data tidak dapat dipulihkan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KONFIRMASI IDENTITAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 0.5)),
                        const SizedBox(height: 14),
                        const Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _passCtrl,
                          obscureText: !_showPass,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Masukkan password kamu',
                            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            suffixIcon: GestureDetector(
                              onTap: () => setState(() => _showPass = !_showPass),
                              child: Icon(_showPass ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppTheme.textMuted),
                            ),
                            border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF4444), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 14),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5),
                            children: [
                              const TextSpan(text: 'KETIK '),
                              const TextSpan(text: '"HAPUS AKUN"', style: TextStyle(color: Color(0xFFEF4444))),
                              const TextSpan(text: ' UNTUK KONFIRMASI'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: _konfirmasiCtrl,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFEF4444)),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Ketik: HAPUS AKUN',
                            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            suffixIcon: _konfirmasiCtrl.text == 'HAPUS AKUN'
                                ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18)
                                : null,
                            border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
                            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
                            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFEF4444), width: 2)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => setState(() => _setuju = !_setuju),
                          child: Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: _setuju ? const Color(0xFFEF4444) : Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: _setuju ? const Color(0xFFEF4444) : const Color(0xFF93C5FD), width: 2),
                                ),
                                child: _setuju ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null,
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Saya memahami bahwa tindakan ini tidak dapat dibatalkan',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Center(
                              child: Text(
                                'BATAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _canDelete ? () => _showFinalDialog(context) : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _canDelete
                                    ? [const Color(0xFF1F2937), const Color(0xFF374151)]
                                    : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('🗑️', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 6),
                                Text('HAPUS AKUN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _konsekuensiItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _showFinalDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(20)),
                child: const Center(child: Text('🗑️', style: TextStyle(fontSize: 30))),
              ),
              const SizedBox(height: 14),
              const Text('HAPUS AKUN?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              const Text(
                'Akun M.Sifaul qulub akan dihapus permanen. Tindakan ini tidak bisa dibatalkan!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(color: const Color(0xFFE0EAFF), borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text('TIDAK', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primary, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        decoration: BoxDecoration(color: const Color(0xFF1F2937), borderRadius: BorderRadius.circular(12)),
                        child: const Center(
                          child: Text('YA, HAPUS', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1F2937), Color(0xFF374151), Color(0xFF6B7280)])),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.08)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('HAPUS AKUN', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                        Text('Exotic gaming & cafe', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SUPPORT SCREEN ====================
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Center(child: Text('🎮', style: TextStyle(fontSize: 36))),
                        ),
                        const SizedBox(height: 10),
                        Text('Exotic Gaming & Caffe', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Versi 1.3.1', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text('✅ Versi Terbaru', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel('📞', 'HUBUNGI KAMI'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
                    ),
                    child: Column(
                      children: [
                        _contactTile('💬', const Color(0xFFD1FAE5), 'WhatsApp', '087356642644', isFirst: true),
                        const Divider(height: 1, indent: 68, color: Color(0xFFF1F5F9)),
                        _contactTile('📧', const Color(0xFFDBEAFE), 'Email', 'support@exoticgaming.id'),
                        const Divider(height: 1, indent: 68, color: Color(0xFFF1F5F9)),
                        _contactTile('📍', const Color(0xFFFEE2E2), 'Alamat', 'Jl. Ahmad Yani, Nganjuk', isLast: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel('❓', 'FAQ'),
                  const SizedBox(height: 8),
                  const _FaqSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String emoji, String label) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted, letterSpacing: 1)),
      ],
    );
  }

  Widget _contactTile(String emoji, Color bg, String title, String value, {bool isFirst = false, bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                Text(value, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)])),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.support_agent_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('SUPPORT', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                        Text('Exotic gaming & cafe', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== FAQ SECTION WIDGET ====================
class _FaqSection extends StatefulWidget {
  const _FaqSection();

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  final List<Map<String, String>> _faqs = [
    {'q': 'Bagaimana cara mengubah password?', 'a': 'Pergi ke Pengaturan → Ubah Password, masukkan password lama dan password baru kamu.'},
    {'q': 'Apa yang terjadi jika akun dihapus?', 'a': 'Semua data akun, riwayat transaksi, dan informasi pribadi akan dihapus permanen dan tidak dapat dipulihkan.'},
    {'q': 'Bagaimana cara menghubungi admin?', 'a': 'Kamu bisa menghubungi admin melalui WhatsApp di 087356642644 atau email ke support@exoticgaming.id.'},
    {'q': 'Apakah data transaksi bisa diekspor?', 'a': 'Ya, kamu bisa ekspor data transaksi melalui menu Laporan di halaman utama.'},
  ];

  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: _faqs.asMap().entries.map((e) {
          final i = e.key;
          final faq = e.value;
          final isOpen = _openIndex == i;
          final isLast = i == _faqs.length - 1;
          return Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _openIndex = isOpen ? null : i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isOpen ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(child: Text(isOpen ? '🔽' : '▶️', style: const TextStyle(fontSize: 12))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          faq['q']!,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isOpen ? AppTheme.primary : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isOpen)
                Padding(
                  padding: const EdgeInsets.fromLTRB(56, 0, 16, 14),
                  child: Text(faq['a']!, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.5)),
                ),
              if (!isLast) const Divider(height: 1, indent: 16, color: Color(0xFFF1F5F9)),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ==================== EDIT PROFIL KARYAWAN ====================
class EditProfilKaryawanScreen extends StatefulWidget {
  const EditProfilKaryawanScreen({super.key});
  @override
  State<EditProfilKaryawanScreen> createState() => _EditProfilKaryawanScreenState();
}

class _EditProfilKaryawanScreenState extends State<EditProfilKaryawanScreen> {
  String _gender = 'Laki-Laki';
  final _nama = TextEditingController(text: 'M.SIFAUL QULUB');
  final _username = TextEditingController(text: 'SIFAULQULUB5356');
  final _tglLahir = TextEditingController(text: '08/17/1995');
  final _telepon = TextEditingController(text: '087356642644');
  final _email = TextEditingController(text: 'M.SIFAUL624@gmail.com');
  final _alamat = TextEditingController(text: 'Nganjuk');
  final _namaUsaha = TextEditingController(text: 'Exotic Gaming and Caffe');
  final _jabatan = TextEditingController(text: 'karyawan');

  @override
  void dispose() {
    _nama.dispose();
    _username.dispose();
    _tglLahir.dispose();
    _telepon.dispose();
    _email.dispose();
    _alamat.dispose();
    _namaUsaha.dispose();
    _jabatan.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  _buildCard('INFORMASI DASAR', const Color(0xFF2563EB), null, [
                    _field('NAMA LENGKAP', _nama),
                    _field('USERNAME', _username),
                    _field('TANGGAL LAHIR', _tglLahir),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _genderBtn('Laki-Laki', '♂'),
                        const SizedBox(width: 10),
                        _genderBtn('Perempuan', '♀'),
                      ],
                    ),
                  ]),
                  const SizedBox(height: 12),
                  _buildCard('KONTAK', const Color(0xFF2563EB), '👤', [
                    _field('NO. TELEPON', _telepon, type: TextInputType.phone),
                    _field('EMAIL', _email, type: TextInputType.emailAddress),
                    _field('ALAMAT', _alamat, isLast: true),
                  ]),
                  const SizedBox(height: 12),
                  _buildCard('TOKO', AppTheme.textPrimary, '💼', [
                    _field('NAMA USAHA', _namaUsaha),
                    _field('JABATAN', _jabatan, isLast: true),
                  ]),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Center(
                              child: Text(
                                'BATAL',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profil berhasil disimpan ✅'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppTheme.textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(12)),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8)]),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('💾', style: TextStyle(fontSize: 14)),
                                SizedBox(width: 6),
                                Text('SIMPAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)])),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('EDIT PROFIL', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                        Text('Exotic gaming & cafe', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Center(child: Text('🤖', style: TextStyle(fontSize: 44))),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text('M.SIFAUL QULUB', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 18, color: AppTheme.textPrimary)),
          ],
        ),
      ],
    );
  }

  Widget _buildCard(String title, Color titleColor, String? emoji, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFDBEAFE), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (emoji != null) ...[
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: titleColor, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {TextInputType type = TextInputType.text, bool isLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
        TextField(
          controller: ctrl,
          keyboardType: type,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 6),
            border: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 2)),
          ),
        ),
        if (!isLast) const SizedBox(height: 10),
      ],
    );
  }

  Widget _genderBtn(String label, String symbol) {
    final sel = _gender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? AppTheme.primary : const Color(0xFF93C5FD)),
          ),
          child: Center(
            child: Text(
              '$symbol $label',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: sel ? Colors.white : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== UBAH PASSWORD KARYAWAN ====================
class UbahPasswordKaryawanScreen extends StatefulWidget {
  const UbahPasswordKaryawanScreen({super.key});
  @override
  State<UbahPasswordKaryawanScreen> createState() => _UbahPasswordKaryawanScreenState();
}

class _UbahPasswordKaryawanScreenState extends State<UbahPasswordKaryawanScreen> {
  final _passLama = TextEditingController();
  final _passBaru = TextEditingController();
  final _passKonfirmasi = TextEditingController();

  bool _showLama = false;
  bool _showBaru = false;
  bool _showKonfirmasi = false;

  bool get _minLength => _passBaru.text.length >= 8;
  bool get _hasUpper => _passBaru.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _passBaru.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passBaru.text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
  bool get _match => _passBaru.text == _passKonfirmasi.text && _passKonfirmasi.text.isNotEmpty;

  double get _strength {
    int s = 0;
    if (_minLength) s++;
    if (_hasUpper) s++;
    if (_hasNumber) s++;
    if (_hasSpecial) s++;
    return s / 4;
  }

  Color get _strengthColor {
    if (_strength <= 0.25) return const Color(0xFFEF4444);
    if (_strength <= 0.5) return const Color(0xFFF59E0B);
    if (_strength <= 0.75) return const Color(0xFF3B82F6);
    return const Color(0xFF10B981);
  }

  bool get _canSave => _passLama.text.isNotEmpty && _passBaru.text.isNotEmpty && _match && _strength >= 0.5;

  @override
  void dispose() {
    _passLama.dispose();
    _passBaru.dispose();
    _passKonfirmasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0FE),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildUserCard(),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Password Saat ini',
                    emoji: '🔑',
                    headerColor: const Color(0xFFFEF9C3),
                    headerTextColor: AppTheme.textPrimary,
                    child: _passField(
                      label: 'PASSWORD LAMA',
                      hint: 'Masukkan password lama',
                      ctrl: _passLama,
                      show: _showLama,
                      onToggle: () => setState(() => _showLama = !_showLama),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Password Baru',
                    emoji: '🔑',
                    headerColor: const Color(0xFFDBEAFE),
                    headerTextColor: AppTheme.textPrimary,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _passField(
                          label: 'PASSWORD BARU',
                          hint: 'Masukkan password baru',
                          ctrl: _passBaru,
                          show: _showBaru,
                          onToggle: () => setState(() => _showBaru = !_showBaru),
                        ),
                        if (_passBaru.text.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _strength,
                              minHeight: 5,
                              backgroundColor: const Color(0xFFE2E8F0),
                              valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Kekuatan password',
                            style: TextStyle(fontSize: 9, color: AppTheme.textMuted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          _checkItem('Minimal 8 karakter', _minLength),
                          _checkItem('Mengandung huruf kapital', _hasUpper),
                          _checkItem('Mengandung angka', _hasNumber),
                          _checkItem('Mengandung karakter khusus', _hasSpecial),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionCard(
                    title: 'Konfirmasi PASSWORD',
                    emoji: '🔒',
                    headerColor: const Color(0xFF374151),
                    headerTextColor: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _passField(
                          label: 'ULANGI PASSWORD BARU',
                          hint: 'Ulangi password baru',
                          ctrl: _passKonfirmasi,
                          show: _showKonfirmasi,
                          onToggle: () => setState(() => _showKonfirmasi = !_showKonfirmasi),
                        ),
                        if (_passKonfirmasi.text.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _match ? '✅ PASSWORD COCOK' : '🔴 PASSWORD TIDAK COCOK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _match ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF93C5FD)),
                            ),
                            child: const Center(
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _canSave
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Password berhasil diubah ✅'),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: Color(0xFF10B981),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _canSave
                                    ? [const Color(0xFF2563EB), const Color(0xFF38BDF8)]
                                    : [const Color(0xFF94A3B8), const Color(0xFFCBD5E1)],
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Center(
                              child: Text(
                                'Simpan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      child: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF2563EB), Color(0xFF60A5FA)])),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                top: -35,
                right: -25,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.15)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 48),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: Colors.white, size: 14),
                            const SizedBox(width: 4),
                            Text('Ubah Password', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                          ],
                        ),
                        Text('Exotic gaming & cafe', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF2563EB)]),
            ),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('M.Sifaul qulub', style: GoogleFonts.nunito(fontWeight: FontWeight.w900, fontSize: 14, color: AppTheme.textPrimary)),
              const Text('karyawan exotic_gaming&caffe', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String emoji,
    required Color headerColor,
    required Color headerTextColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.07), blurRadius: 16, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: headerTextColor)),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _passField({
    required String label,
    required String hint,
    required TextEditingController ctrl,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.textMuted, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          obscureText: !show,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(show ? Icons.visibility_off_rounded : Icons.visibility_rounded, size: 18, color: AppTheme.textMuted),
            ),
            border: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF93C5FD))),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primary, width: 2)),
          ),
        ),
      ],
    );
  }

  Widget _checkItem(String label, bool passed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 12,
            color: passed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: passed ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}