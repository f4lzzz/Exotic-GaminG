import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'notifikasi_owner.dart';
import 'profil_owner.dart';

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

// ─── MODEL ───────────────────────────────────────────────────────────────────
class Karyawan {
  String id;
  String nama;
  String jabatan;
  String shift;
  StatusKehadiran status;
  String avatar; // inisial untuk placeholder

  Karyawan({
    required this.id,
    required this.nama,
    required this.jabatan,
    required this.shift,
    required this.status,
    required this.avatar,
  });
}

enum StatusKehadiran { hadir, absen, izin, sakit }

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class OwnerKaryawanScreen extends StatefulWidget {
  const OwnerKaryawanScreen({super.key});

  @override
  State<OwnerKaryawanScreen> createState() => _OwnerKaryawanScreenState();
}

class _OwnerKaryawanScreenState extends State<OwnerKaryawanScreen>
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
      _headerExpanded - (_headerExpanded - _headerCollapsed) * _collapseProgress;

  int _tabIndex = 0;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  // Data dummy karyawan
  final List<Karyawan> _karyawanList = [
    Karyawan(id: '1', nama: 'Budi Santoso', jabatan: 'Kasir', shift: 'Pagi', status: StatusKehadiran.hadir, avatar: 'BS'),
    Karyawan(id: '2', nama: 'Sari Dewi', jabatan: 'Barista', shift: 'Pagi', status: StatusKehadiran.hadir, avatar: 'SD'),
    Karyawan(id: '3', nama: 'Riko Pratama', jabatan: 'Operator Gaming', shift: 'Siang', status: StatusKehadiran.absen, avatar: 'RP'),
    Karyawan(id: '4', nama: 'Mega Putri', jabatan: 'Kasir', shift: 'Siang', status: StatusKehadiran.hadir, avatar: 'MP'),
    Karyawan(id: '5', nama: 'Andi Wijaya', jabatan: 'Teknisi', shift: 'Malam', status: StatusKehadiran.izin, avatar: 'AW'),
    Karyawan(id: '6', nama: 'Lina Susanti', jabatan: 'Barista', shift: 'Malam', status: StatusKehadiran.hadir, avatar: 'LS'),
    Karyawan(id: '7', nama: 'Doni Kusuma', jabatan: 'Operator Gaming', shift: 'Pagi', status: StatusKehadiran.hadir, avatar: 'DK'),
    Karyawan(id: '8', nama: 'Fitri Handayani', jabatan: 'Kasir', shift: 'Siang', status: StatusKehadiran.sakit, avatar: 'FH'),
    Karyawan(id: '9', nama: 'Hendra Gunawan', jabatan: 'Barista', shift: 'Pagi', status: StatusKehadiran.hadir, avatar: 'HG'),
    Karyawan(id: '10', nama: 'Yuni Rahayu', jabatan: 'Operator Gaming', shift: 'Malam', status: StatusKehadiran.hadir, avatar: 'YR'),
    Karyawan(id: '11', nama: 'Bagas Aditya', jabatan: 'Teknisi', shift: 'Siang', status: StatusKehadiran.hadir, avatar: 'BA'),
    Karyawan(id: '12', nama: 'Citra Novia', jabatan: 'Barista', shift: 'Malam', status: StatusKehadiran.absen, avatar: 'CN'),
    Karyawan(id: '13', nama: 'Eko Saputra', jabatan: 'Kasir', shift: 'Pagi', status: StatusKehadiran.hadir, avatar: 'ES'),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
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
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Karyawan> get _filtered {
    return _karyawanList.where((k) {
      final matchTab = _tabIndex == 0 ||
          (_tabIndex == 1 && k.status == StatusKehadiran.hadir) ||
          (_tabIndex == 2 && (k.status == StatusKehadiran.absen || k.status == StatusKehadiran.izin || k.status == StatusKehadiran.sakit));
      final matchSearch = _searchQuery.isEmpty ||
          k.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          k.jabatan.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchTab && matchSearch;
    }).toList();
  }

  int get _totalHadir => _karyawanList.where((k) => k.status == StatusKehadiran.hadir).length;
  int get _totalAbsen => _karyawanList.where((k) => k.status != StatusKehadiran.hadir).length;

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(),
                  const SizedBox(height: 16),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildTabBar(),
                  const SizedBox(height: 12),
                  _buildKaryawanList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── HEADER (sama persis owner dashboard dengan collapse animasi) ──────────
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
          TextSpan(text: 'E', style: TextStyle(fontSize: eSize, fontWeight: FontWeight.w400)),
          TextSpan(text: 'X', style: TextStyle(fontSize: xSize, fontWeight: FontWeight.w700)),
          TextSpan(text: 'OTIC', style: TextStyle(fontSize: oticSize, fontWeight: FontWeight.w400)),
        ],
      ),
    );

    final subWidget = Text(
      'GAMING & CAFE',
      style: GoogleFonts.playfairDisplay(
        fontSize: subSize, color: kWhiteDim, letterSpacing: 3, fontWeight: FontWeight.w400,
      ),
    );

    final iconButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _headerIconBtn(Icons.settings_outlined, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilOwnerScreen()))),
        const SizedBox(width: 6),
        _headerIconBtn(Icons.notifications_outlined, badge: 3, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiOwnerScreen()))),
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

  Widget _headerIconBtn(IconData icon, {int badge = 0, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: kWhite.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: kWhite, size: 20),
          ),
          if (badge > 0)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 16, height: 16,
                decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle),
                child: Center(
                  child: Text('$badge', style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w900, color: kWhite)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ─── SUMMARY ROW ─────────────────────────────────────────────────────────
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(child: _summaryCard('TOTAL', '${_karyawanList.length}', Icons.people, kBlue)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('HADIR', '$_totalHadir', Icons.check_circle, kGreen)),
        const SizedBox(width: 10),
        Expanded(child: _summaryCard('TIDAK HADIR', '$_totalAbsen', Icons.cancel, kRed)),
      ],
    );
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w900, color: kTextDark)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black38, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  // ─── SEARCH BAR ──────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: 'Cari nama atau jabatan...',
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() { _searchQuery = ''; _searchCtrl.clear(); }),
                  child: const Icon(Icons.close, color: Colors.black38, size: 18),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── TAB BAR ─────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final tabs = ['Semua', 'Hadir', 'Tidak Hadir'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _tabIndex == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? kBlue : kWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Text(
                tabs[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isActive ? kWhite : Colors.black45,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── LIST KARYAWAN ───────────────────────────────────────────────────────
  Widget _buildKaryawanList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.black26),
              const SizedBox(height: 12),
              Text('Tidak ada karyawan', style: GoogleFonts.lato(fontSize: 14, color: Colors.black38)),
            ],
          ),
        ),
      );
    }
    return Column(
      children: list.map((k) => _karyawanCard(k)).toList(),
    );
  }

  Widget _karyawanCard(Karyawan k) {
    final statusColor = _statusColor(k.status);
    final statusLabel = _statusLabel(k.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kBlue.withOpacity(0.12),
              border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                k.avatar,
                style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w900, color: kBlue),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.nama, style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w800, color: kTextDark)),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(Icons.work_outline, size: 11, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text(k.jabatan, style: GoogleFonts.lato(fontSize: 11, color: Colors.black45)),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 11, color: Colors.black38),
                    const SizedBox(width: 4),
                    Text('Shift ${k.shift}', style: GoogleFonts.lato(fontSize: 11, color: Colors.black45)),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.lato(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                ),
              ),
              const SizedBox(height: 6),
              // Tombol aksi
              Row(
                children: [
                  _actionBtn(Icons.edit_outlined, kBlue, () => _showEditDialog(k)),
                  const SizedBox(width: 6),
                  _actionBtn(Icons.delete_outline, kRed, () => _showDeleteDialog(k)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showTambahDialog(),
      backgroundColor: kBlue,
      icon: const Icon(Icons.person_add, color: kWhite),
      label: Text('Tambah', style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite)),
    );
  }

  // ─── HELPER ──────────────────────────────────────────────────────────────
  Color _statusColor(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir: return kGreen;
      case StatusKehadiran.absen: return kRed;
      case StatusKehadiran.izin: return kOrange;
      case StatusKehadiran.sakit: return Colors.purple;
    }
  }

  String _statusLabel(StatusKehadiran s) {
    switch (s) {
      case StatusKehadiran.hadir: return 'HADIR';
      case StatusKehadiran.absen: return 'ABSEN';
      case StatusKehadiran.izin: return 'IZIN';
      case StatusKehadiran.sakit: return 'SAKIT';
    }
  }

  // ─── DIALOG TAMBAH ───────────────────────────────────────────────────────
  void _showTambahDialog() {
    final namaCtrl = TextEditingController();
    final jabatanCtrl = TextEditingController();
    String shift = 'Pagi';
    StatusKehadiran status = StatusKehadiran.hadir;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Tambah Karyawan', style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kTextDark)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(jabatanCtrl, 'Jabatan', Icons.work_outline),
                const SizedBox(height: 12),
                _dialogDropdown<String>(
                  label: 'Shift',
                  value: shift,
                  items: ['Pagi', 'Siang', 'Malam'],
                  onChanged: (v) => setDlg(() => shift = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<StatusKehadiran>(
                  label: 'Status',
                  value: status,
                  items: StatusKehadiran.values,
                  itemLabel: (v) => _statusLabel(v),
                  onChanged: (v) => setDlg(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.black45)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (namaCtrl.text.isNotEmpty && jabatanCtrl.text.isNotEmpty) {
                  final inisial = namaCtrl.text.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join();
                  setState(() {
                    _karyawanList.add(Karyawan(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      nama: namaCtrl.text.trim(),
                      jabatan: jabatanCtrl.text.trim(),
                      shift: shift,
                      status: status,
                      avatar: inisial,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: Text('Simpan', style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOG EDIT ─────────────────────────────────────────────────────────
  void _showEditDialog(Karyawan k) {
    final namaCtrl = TextEditingController(text: k.nama);
    final jabatanCtrl = TextEditingController(text: k.jabatan);
    String shift = k.shift;
    StatusKehadiran status = k.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Edit Karyawan', style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kTextDark)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
                const SizedBox(height: 12),
                _dialogField(jabatanCtrl, 'Jabatan', Icons.work_outline),
                const SizedBox(height: 12),
                _dialogDropdown<String>(
                  label: 'Shift',
                  value: shift,
                  items: ['Pagi', 'Siang', 'Malam'],
                  onChanged: (v) => setDlg(() => shift = v!),
                ),
                const SizedBox(height: 12),
                _dialogDropdown<StatusKehadiran>(
                  label: 'Status',
                  value: status,
                  items: StatusKehadiran.values,
                  itemLabel: (v) => _statusLabel(v),
                  onChanged: (v) => setDlg(() => status = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.lato(color: Colors.black45)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                setState(() {
                  k.nama = namaCtrl.text.trim();
                  k.jabatan = jabatanCtrl.text.trim();
                  k.shift = shift;
                  k.status = status;
                  k.avatar = namaCtrl.text.trim().split(' ').take(2).map((e) => e[0].toUpperCase()).join();
                });
                Navigator.pop(ctx);
              },
              child: Text('Simpan', style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOG HAPUS ────────────────────────────────────────────────────────
  void _showDeleteDialog(Karyawan k) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Karyawan', style: GoogleFonts.lato(fontWeight: FontWeight.w900, color: kTextDark)),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
            children: [
              const TextSpan(text: 'Yakin hapus '),
              TextSpan(text: k.nama, style: const TextStyle(fontWeight: FontWeight.w800, color: kTextDark)),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: GoogleFonts.lato(color: Colors.black45)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: kRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              setState(() => _karyawanList.removeWhere((e) => e.id == k.id));
              Navigator.pop(ctx);
            },
            child: Text('Hapus', style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite)),
          ),
        ],
      ),
    );
  }

  // ─── DIALOG WIDGETS ──────────────────────────────────────────────────────
  Widget _dialogField(TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: Icon(icon, size: 18, color: Colors.black38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _dialogDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    String Function(T)? itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: kBgLight, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
          hint: Text(label, style: GoogleFonts.lato(fontSize: 13, color: Colors.black38)),
          items: items.map((e) => DropdownMenuItem<T>(
            value: e,
            child: Text(itemLabel != null ? itemLabel(e) : e.toString()),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}