import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import 'registrasi_wajah_screen.dart';
import 'login.dart';
import 'service/cloudinary_service.dart';

// ==================== DATA MODEL ====================
class _MenuTileData {
  final String icon, title, subtitle;
  final Color iconBg;
  final Color? titleColor;
  final Color? bgColor;
  final VoidCallback onTap;
  const _MenuTileData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.onTap,
    this.titleColor,
    this.bgColor,
  });
}

// ==================== PROFIL KARYAWAN ====================
class ProfilKaryawanScreen extends StatefulWidget {
  const ProfilKaryawanScreen({super.key});

  @override
  State<ProfilKaryawanScreen> createState() => _ProfilKaryawanScreenState();
}

class _ProfilKaryawanScreenState extends State<ProfilKaryawanScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  Map<String, dynamic>? _userData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      if (mounted) {
        setState(() {
          _userData = doc.data();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E2A3A),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text('Yakin ingin keluar?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal',
                  style: TextStyle(color: Color(0xFF5B8DEE)))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Logout',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1520),
        body:
            Center(child: CircularProgressIndicator(color: Color(0xFF5B8DEE))),
      );
    }

    final nama = _userData?['nama'] ?? currentUser?.displayName ?? 'Karyawan';
    final role = _userData?['role'] ?? 'karyawan';
    final email = currentUser?.email ?? '';
    final photoUrl = _userData?['photoUrl'] as String?;

    final List<_MenuTileData> menuAkun = [
      _MenuTileData(
        icon: '✏️',
        iconBg: const Color(0xFFDBEAFE),
        title: 'Edit Profil',
        subtitle: 'Ubah nama dan foto profil',
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditProfilKaryawanScreen(
                uid: currentUser!.uid,
                namaAwal: nama,
                emailAwal: email,
                photoUrlAwal: photoUrl,
              ),
            ),
          );
          _loadUserData();
        },
      ),
      _MenuTileData(
        icon: '👤',
        iconBg: const Color(0xFFD1FAE5),
        title: 'DAFTARKAN WAJAH',
        subtitle: 'Registrasi wajah untuk absensi',
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RegistrasiWajahScreen(
                      uid: currentUser?.uid,
                      namaKaryawan: nama,
                    ))),
      ),
    ];

    final List<_MenuTileData> menuLainnya = [
      _MenuTileData(
        icon: '🗑️',
        iconBg: const Color(0xFF374151),
        title: 'Logout',
        subtitle: 'Keluar dari akun ini',
        titleColor: const Color(0xFFEF4444),
        onTap: () => _logout(context),
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0D1520),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text('Profil',
                      style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
              const SizedBox(height: 24),
              // Avatar & Info
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: const Color(0xFF2C5FC4),
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                      child: (photoUrl == null || photoUrl.isEmpty)
                          ? Text(
                              nama.isNotEmpty ? nama[0].toUpperCase() : 'K',
                              style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(nama,
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF5B8DEE).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFF5B8DEE).withOpacity(0.5)),
                      ),
                      child: Text(
                        role.toString().toUpperCase(),
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF5B8DEE),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(email,
                        style: GoogleFonts.poppins(
                            fontSize: 13, color: Colors.white54)),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildSectionLabel('👤', 'AKUN'),
              const SizedBox(height: 8),
              _buildMenuGroup(menuAkun),
              const SizedBox(height: 16),
              _buildSectionLabel('⚠️', 'LAINNYA'),
              const SizedBox(height: 8),
              _buildMenuGroup(menuLainnya),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String icon, String label) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white38,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildMenuGroup(List<_MenuTileData> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A2535),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: item.iconBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(item.icon,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: item.titleColor ?? Colors.white)),
                            Text(item.subtitle,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.white38)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: Colors.white24, size: 20),
                    ],
                  ),
                ),
              ),
              if (i < items.length - 1)
                Divider(
                    height: 1,
                    color: Colors.white.withOpacity(0.06),
                    indent: 72),
            ],
          );
        }),
      ),
    );
  }
}

// ==================== EDIT PROFIL ====================
class EditProfilKaryawanScreen extends StatefulWidget {
  final String uid;
  final String namaAwal;
  final String emailAwal;
  final String? photoUrlAwal;

  const EditProfilKaryawanScreen({
    super.key,
    required this.uid,
    required this.namaAwal,
    required this.emailAwal,
    this.photoUrlAwal,
  });

  @override
  State<EditProfilKaryawanScreen> createState() =>
      _EditProfilKaryawanScreenState();
}

class _EditProfilKaryawanScreenState extends State<EditProfilKaryawanScreen> {
  late TextEditingController _namaCtrl;
  final _cloudinary = CloudinaryService();
  File? _imageFile;
  String? _photoUrl;
  bool _loading = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl = TextEditingController(text: widget.namaAwal);
    _photoUrl = widget.photoUrlAwal;
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _uploadingPhoto = true;
    });

    try {
      final url = await _cloudinary.uploadImage(
        imageFile: _imageFile!,
        folder: 'foto_profil',
      );
      if (url != null) {
        setState(() => _photoUrl = url);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Foto berhasil diupload'),
              backgroundColor: Color(0xFF2ECC71),
            ),
          );
        }
      } else {
        throw Exception('Upload gagal');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal upload foto: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    final nama = _namaCtrl.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final updates = <String, dynamic>{
        'nama': nama,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (_photoUrl != null) updates['photoUrl'] = _photoUrl;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .update(updates);

      // Update displayName di FirebaseAuth juga
      await FirebaseAuth.instance.currentUser?.updateDisplayName(nama);
      if (_photoUrl != null) {
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(_photoUrl);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Profil berhasil disimpan'),
            backgroundColor: Color(0xFF2ECC71),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal simpan: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1520),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1520),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profil',
            style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Avatar dengan tombol kamera
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: const Color(0xFF2C5FC4),
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : (_photoUrl != null && _photoUrl!.isNotEmpty
                            ? NetworkImage(_photoUrl!) as ImageProvider
                            : null),
                    child: (_imageFile == null &&
                            (_photoUrl == null || _photoUrl!.isEmpty))
                        ? Text(
                            _namaCtrl.text.isNotEmpty
                                ? _namaCtrl.text[0].toUpperCase()
                                : 'K',
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          )
                        : null,
                  ),
                  if (_uploadingPhoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _uploadingPhoto ? null : _pickAndUploadPhoto,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B8DEE),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0D1520), width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap ikon kamera untuk ganti foto',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
            ),
            const SizedBox(height: 28),
            // Form Nama
            _buildInputField(
              label: 'Nama Lengkap',
              controller: _namaCtrl,
              hint: 'Masukkan nama lengkap',
            ),
            const SizedBox(height: 16),
            // Email (read-only)
            _buildInputField(
              label: 'Email',
              controller: TextEditingController(text: widget.emailAwal),
              hint: widget.emailAwal,
              readOnly: true,
            ),
            const SizedBox(height: 36),
            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: (_loading || _uploadingPhoto) ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B8DEE),
                  disabledBackgroundColor:
                      const Color(0xFF5B8DEE).withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text('Simpan Perubahan',
                        style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.white60,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 15, color: Colors.white24),
            filled: true,
            fillColor: readOnly
                ? const Color(0xFF1A2535).withOpacity(0.5)
                : const Color(0xFF1A2535),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF5B8DEE)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
            ),
          ),
        ),
      ],
    );
  }
}
