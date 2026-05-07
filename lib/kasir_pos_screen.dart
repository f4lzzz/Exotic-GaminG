import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kpBlue     = Color(0xFF5B8DEE);
const _kpBlueDark = Color(0xFF2C5FC4);
const _kpTextDark = Color(0xFF1A2A4A);
const _kpTextMid  = Color(0xFF5B7AAA);
const _kpBgLight  = Color(0xFFDDE8F8);
const _kpWhite    = Color(0xFFFFFFFF);
const _kpGreen    = Color(0xFF27AE60);
const _kpOrange   = Color(0xFFF5A623);
const _kpRed      = Color(0xFFE74C3C);

class KasirPosScreen extends StatefulWidget {
  const KasirPosScreen({super.key});

  @override
  State<KasirPosScreen> createState() => _KasirPosScreenState();
}

class _KasirPosScreenState extends State<KasirPosScreen> {
  final List<_ProdukItem> _produk = const [
    _ProdukItem(nama: 'PS5 — 1 Jam',     harga: 15000, emoji: '🎮'),
    _ProdukItem(nama: 'PC Gaming — 1 Jam',harga: 10000, emoji: '💻'),
    _ProdukItem(nama: 'Mie Goreng',       harga: 12000, emoji: '🍜'),
    _ProdukItem(nama: 'Es Teh Manis',     harga: 5000,  emoji: '🧋'),
    _ProdukItem(nama: 'Indomie Kuah',     harga: 10000, emoji: '🍲'),
    _ProdukItem(nama: 'Air Mineral',      harga: 4000,  emoji: '💧'),
  ];

  final Map<String, int> _keranjang = {};

  int get _total => _keranjang.entries.fold(0, (sum, e) {
        final produk = _produk.firstWhere((p) => p.nama == e.key,
            orElse: () => const _ProdukItem(nama: '', harga: 0, emoji: ''));
        return sum + produk.harga * e.value;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kpBgLight,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('🛍️ PRODUK & LAYANAN'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: _produk.map(_produkCard).toList(),
                  ),
                  if (_keranjang.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionLabel('🧾 PESANAN'),
                    const SizedBox(height: 12),
                    _buildKeranjang(),
                    const SizedBox(height: 16),
                    _buildTotalBar(),
                  ]
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
          colors: [Color(0xFF6BAAF5), _kpBlueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
      child: Row(
        children: [
          RichText(
            text: TextSpan(
              style: GoogleFonts.playfairDisplay(color: _kpWhite, height: 1.0),
              children: const [
                TextSpan(text: 'E',    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
                TextSpan(text: 'X',    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700)),
                TextSpan(text: 'OTIC', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('GAMING & CAFE',
              style: GoogleFonts.playfairDisplay(fontSize: 11, color: const Color(0xFFCDD8F0), letterSpacing: 3)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _kpWhite.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
            child: Text('KASIR / POS',
                style: GoogleFonts.lato(fontSize: 9, fontWeight: FontWeight.w900, color: _kpWhite, letterSpacing: 0.8)),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(label,
      style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w800, color: _kpTextDark, letterSpacing: 0.5));

  Widget _produkCard(_ProdukItem item) {
    final qty = _keranjang[item.nama] ?? 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kpWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _kpBlue.withOpacity(0.09), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 24)),
              const Spacer(),
              if (qty > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _kpBlue, borderRadius: BorderRadius.circular(20)),
                  child: Text('$qty',
                      style: const TextStyle(color: _kpWhite, fontSize: 11, fontWeight: FontWeight.w900)),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.nama,
                  style: GoogleFonts.lato(fontSize: 11, fontWeight: FontWeight.w800, color: _kpTextDark),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('Rp ${_fmt(item.harga)}',
                  style: GoogleFonts.lato(fontSize: 13, fontWeight: FontWeight.w900, color: _kpBlue)),
            ],
          ),
          Row(
            children: [
              _qtyBtn(Icons.remove, () {
                if (qty > 0) setState(() => _keranjang[item.nama] = qty - 1);
                if ((_keranjang[item.nama] ?? 0) == 0) _keranjang.remove(item.nama);
              }),
              const Spacer(),
              _qtyBtn(Icons.add, () => setState(() => _keranjang[item.nama] = qty + 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: _kpBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16, color: _kpBlue),
      ),
    );
  }

  Widget _buildKeranjang() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _kpWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _kpBlue.withOpacity(0.09), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: _keranjang.entries.where((e) => e.value > 0).map((e) {
          final produk = _produk.firstWhere((p) => p.nama == e.key);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Text(produk.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text(produk.nama,
                    style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w700, color: _kpTextDark))),
                Text('${e.value}x',
                    style: GoogleFonts.lato(fontSize: 12, color: _kpTextMid)),
                const SizedBox(width: 10),
                Text('Rp ${_fmt(produk.harga * e.value)}',
                    style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w800, color: _kpBlue)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [_kpBlue, _kpBlueDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL', style: GoogleFonts.lato(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w700)),
              Text('Rp ${_fmt(_total)}',
                  style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.w900, color: _kpWhite)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() => _keranjang.clear());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Transaksi berhasil! 🎉', style: TextStyle(fontWeight: FontWeight.w700)),
                backgroundColor: _kpGreen,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(color: _kpGreen, borderRadius: BorderRadius.circular(14)),
              child: Text('BAYAR', style: GoogleFonts.lato(fontSize: 14, fontWeight: FontWeight.w900, color: _kpWhite)),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int angka) {
    final s = angka.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }
}

class _ProdukItem {
  final String nama;
  final int harga;
  final String emoji;
  const _ProdukItem({required this.nama, required this.harga, required this.emoji});
}
