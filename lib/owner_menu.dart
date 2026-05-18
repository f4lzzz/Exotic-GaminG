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
const kPurple = Color(0xFF7C4DFF);
const kBgLight = Color(0xFFF0F4FF);

// ─── MODEL ───────────────────────────────────────────────────────────────────
enum KategoriMenu { makanan, minuman, reguler, suiteroom }

class MenuItem {
  String id;
  String nama;
  String inisial;
  KategoriMenu kategori;
  int harga;
  String deskripsi;
  bool tersedia;
  String? info;
  String? image;

  MenuItem({
    required this.id,
    required this.nama,
    required this.inisial,
    required this.kategori,
    required this.harga,
    required this.deskripsi,
    this.image,
    this.tersedia = true,
    this.info,
  });
}

// ─── SCREEN ──────────────────────────────────────────────────────────────────
class OwnerMenuScreen extends StatefulWidget {
  const OwnerMenuScreen({super.key});

  @override
  State<OwnerMenuScreen> createState() => _OwnerMenuScreenState();
}

class _OwnerMenuScreenState extends State<OwnerMenuScreen>
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

  KategoriMenu _selectedKategori = KategoriMenu.makanan;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  final List<MenuItem> _menuList = [
    // ── MAKANAN ──
    MenuItem(
      id: 'm1',
      nama: 'Nasi Ayam Bakar Kecap Exotic',
      inisial: 'NGS',
      kategori: KategoriMenu.makanan,
      harga: 22000,
      deskripsi: 'Nasi dengan ayam bakar kecap, dan sayuran',
      image: 'images/Nasi_ayam_bakar.jpg',
    ),
    MenuItem(
      id: 'm2',
      nama: 'Nasi Bakar Ayam Bumbu Kemangi',
      inisial: 'MG',
      kategori: KategoriMenu.makanan,
      harga: 15000,
      deskripsi: 'Nasi bakar dengan ayam suwir bumbu kemangi',
      image: 'images/nasi_bakar_ayam_bumbu_kemangi.jpg',
    ),
    MenuItem(
      id: 'm3',
      nama: 'Nasi Bakar Ikan Bumbu Kemangi',
      inisial: 'KG',
      kategori: KategoriMenu.makanan,
      harga: 18000,
      deskripsi: 'Nasi dengan Ikan bakar bumbu kemangi',
      image: 'images/nasi_bakar_ikan_bumbu_kemangi.jpg',
    ),
    MenuItem(
      id: 'm4',
      nama: 'Gurame Bakar Special Exotic',
      inisial: 'AG',
      kategori: KategoriMenu.makanan,
      harga: 34000,
      deskripsi: 'Gurame bakar special',
      image: 'images/gurame_bakar_spesial.jpg',
    ),
    MenuItem(
      id: 'm5',
      nama: 'Nasi Ayam Tulang Lunak Kremes',
      inisial: 'IR',
      kategori: KategoriMenu.makanan,
      harga: 24000,
      deskripsi: 'Nasi putih dengan tulang ayam lunak kremes',
      image: 'images/nasi_ayam_tulang_lunak_kremes.jpeg',
    ),
    MenuItem(
      id: 'm6',
      nama: 'Nasi Ayam Tulang Lunak Remuk',
      inisial: 'BC',
      kategori: KategoriMenu.makanan,
      harga: 24000,
      deskripsi: 'Burger dengan ayam crispy dan saus spesial',
      image: 'images/nasi_ayam_tulang_lunak_remuk.jpeg',
    ),
    MenuItem(
      id: 'm7',
      nama: 'Paket Nasi Sambal Bakar Ayam Geprek',
      inisial: 'RB',
      kategori: KategoriMenu.makanan,
      harga: 17000,
      deskripsi: 'Nasi dengan sambal bakar ayam geprek',
      image: 'images/paket_nasi_sambal_bakar_ayam_geprek.jpeg',
    ),
    MenuItem(
      id: 'm8',
      nama: 'Paket Nasi Sambal Bakar Lele Goreng',
      inisial: 'SLG',
      kategori: KategoriMenu.makanan,
      harga: 15000,
      deskripsi: 'Nasi dengan sambal bakar lele goreng',
      image: 'images/paket_nasi_sambal_bakar_lele_goreng.jpeg',
    ),
    MenuItem(
      id: 'm9',
      nama: 'Paket Nasi Sambal Bakar Tempe Penyet',
      inisial: 'STP',
      kategori: KategoriMenu.makanan,
      harga: 14000,
      deskripsi: 'Nasi dengan sambal bakar tempe penyet',
      image: 'images/paket_nasi_sambal_bakar_tempe_penyet.jpg',
    ),
    MenuItem(
      id: 'm10',
      nama: 'Paket Nasi Sambal Bakar Bakwan Goreng',
      inisial: 'SBG',
      kategori: KategoriMenu.makanan,
      harga: 14000,
      deskripsi: 'Nasi dengan sambal bakar bakwan goreng',
      image: 'images/nasi_sambal_bakwan_goreng.jpg',
    ),
    MenuItem(
      id: 'm11',
      nama: 'Pizza All Over Meat (premium/reguler)',
      inisial: 'SBG',
      kategori: KategoriMenu.makanan,
      harga: 35000,
      deskripsi: 'Premium 35K reguler 26k',
      image: 'images/pizza_over_meat.jpeg',
    ),
    MenuItem(
      id: 'm12',
      nama: 'Pizza Chessy Meat (premium/reguler)',
      inisial: 'SBG',
      kategori: KategoriMenu.makanan,
      harga: 35000,
      deskripsi: 'Premium 35K reguler 26k',
      image: 'images/chessy_meat.jpg',
    ),
    MenuItem(
      id: 'm13',
      nama: 'Spaghetti Bolognese',
      inisial: 'SB',
      kategori: KategoriMenu.makanan,
      harga: 22000,
      deskripsi: 'spagetti',
      image: 'images/spageti_bolognase.jpg',
    ),
    MenuItem(
      id: 'm14',
      nama: 'Spaghetti Carbonara',
      inisial: 'SB',
      kategori: KategoriMenu.makanan,
      harga: 22000,
      deskripsi: 'spagetti carbonara',
      image: 'images/spageti_carbonara.jpg',
    ),
    MenuItem(
      id: 'm15',
      nama: 'Indomie Goreng Original',
      inisial: 'IGO',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'Indomie goreng original',
      image: 'images/indomie_goreng_original.jpg',
    ),
    MenuItem(
      id: 'm16',
      nama: 'Mix Platter',
      inisial: 'MP',
      kategori: KategoriMenu.makanan,
      harga: 18000,
      deskripsi: 'Nugget, kentang dengan saos sambal tomat dan cabai',
      image: 'images/mix_platter.jpg',
    ),
    MenuItem(
      id: 'm17',
      nama: 'french fries',
      inisial: 'MP',
      kategori: KategoriMenu.makanan,
      harga: 14000,
      deskripsi: 'kentang goreng di lengkapi dengan caos tomat dan cabai',
      image: 'images/french_fries.jpg',
    ),
    MenuItem(
      id: 'm18',
      nama: 'cireng',
      inisial: 'c',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'cireng goreng dengan caos',
      image: 'images/cireng.jpg',
    ),
    MenuItem(
      id: 'm19',
      nama: 'Nugget',
      inisial: 'C',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'nuget goreng dengan caos',
      image: 'images/nugget.jpg',
    ),
    MenuItem(
      id: 'm20',
      nama: 'Tahu Susu',
      inisial: 'TS',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'tahu susu degan caos pedas',
      image: 'images/tahu_susu.jpg',
    ),
    MenuItem(
      id: 'm21',
      nama: 'Toppoki + Odeng',
      inisial: 'TO',
      kategori: KategoriMenu.makanan,
      harga: 18000,
      deskripsi: 'Toppoki dengan odeng',
      image: 'images/topoki_odeng.jpg',
    ),
    MenuItem(
      id: 'm22',
      nama: 'Tahu Bumbu Special',
      inisial: 'TBS',
      kategori: KategoriMenu.makanan,
      harga: 15000,
      deskripsi: 'Tahu bumbu special',
      image: 'images/tahu_bumbu_spesial.jpeg',
    ),
    MenuItem(
      id: 'm23',
      nama: 'Tempe Mendoan',
      inisial: 'TBS',
      kategori: KategoriMenu.makanan,
      harga: 10000,
      deskripsi: 'Tempe mendoan dengan ',
      image: 'images/tempe_mendoan.jpg',
    ),
    MenuItem(
      id: 'm24',
      nama: 'Bakso Goreng',
      inisial: 'TBS',
      kategori: KategoriMenu.makanan,
      harga: 10000,
      deskripsi: 'bakso goreng dengan ',
      image: 'images/Bakso_Goreng.jpg',
    ),
    MenuItem(
      id: 'm25',
      nama: 'Pisang Coklat',
      inisial: 'PC',
      kategori: KategoriMenu.makanan,
      harga: 10000,
      deskripsi: 'bakso goreng dengan ',
      image: 'images/pisang_coklat.jpg',
    ),
    MenuItem(
      id: 'm26',
      nama: 'Roti Bakar Coklat',
      inisial: 'RBC',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'roti bakar dengan rasa coklat ',
      image: 'images/roti_bakar_coklat.jpg',
    ),
    MenuItem(
      id: 'm27',
      nama: 'Roti Bakar Taro',
      inisial: 'RBT',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'roti bakar dengan rasa taro ',
      image: 'images/roti_bakar_taro.jpg',
    ),
    MenuItem(
      id: 'm28',
      nama: 'Roti Bakar Strawberry',
      inisial: 'RBT',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'roti bakar dengan rasa taro ',
      image: 'images/roti_bakar_strawberry.jpg',
    ),
    MenuItem(
      id: 'm29',
      nama: 'Popcorn Manis/Asin',
      inisial: 'P',
      kategori: KategoriMenu.makanan,
      harga: 12000,
      deskripsi: 'popcorn dengan rasa manis dan asin ',
      image: 'images/pop_corn.jpg',
    ),
    // ── MINUMAN ──
    MenuItem(
      id: 'mn1',
      nama: 'Americano',
      inisial: 'A',
      kategori: KategoriMenu.minuman,
      harga: 13000,
      deskripsi: 'kopi americano',
      image: 'images/americano.jpg',
    ),
    MenuItem(
        id: 'mn2',
        nama: 'chocolate',
        inisial: 'KH',
        kategori: KategoriMenu.minuman,
        harga: 17000,
        deskripsi: 'Kopi hitam panas/dingin',
        image: 'images/chocolate.jpg'),
    MenuItem(
      id: 'mn3',
      nama: 'Pandan',
      inisial: 'ML',
      kategori: KategoriMenu.minuman,
      harga: 17000,
      deskripsi: 'Minuman matcha dengan susu',
      image: 'images/pandan.jpg',
    ),
    MenuItem(
      id: 'mn4',
      nama: 'Gula aren',
      inisial: 'EC',
      kategori: KategoriMenu.minuman,
      harga: 17000,
      deskripsi: 'gula aren',
      image: 'images/gula_aren.jpeg',
    ),
    MenuItem(
      id: 'mn5',
      nama: 'Coconut Gula Aren',
      inisial: 'CGA',
      kategori: KategoriMenu.minuman,
      harga: 18000,
      deskripsi: 'coconut gula aren',
      image: 'images/coconut_gula_aren.jpg',
    ),
    MenuItem(
      id: 'mn6',
      nama: 'tiramisu',
      inisial: 'T',
      kategori: KategoriMenu.minuman,
      harga: 18000,
      deskripsi: 'tiramisu',
      image: 'images/ice_tiramisu.jpg',
    ),
    MenuItem(
      id: 'mn7',
      nama: 'Ice Choco Cookies',
      inisial: 'BBS',
      kategori: KategoriMenu.minuman,
      harga: 20000,
      deskripsi: 'Es Choco Cookies',
      image: 'images/ice_choco_cookies.jpeg',
    ),
    MenuItem(
      id: 'mn8',
      nama: 'Ice Green Tea',
      inisial: 'RVL',
      kategori: KategoriMenu.minuman,
      harga: 18000,
      deskripsi: 'es grean tea',
      image: 'images/ice_green_tea.jpg',
    ),
    MenuItem(
      id: 'mn9',
      nama: 'Ice Milky Taro',
      inisial: 'RVL',
      kategori: KategoriMenu.minuman,
      harga: 18000,
      deskripsi: 'es susu rasa taro',
      image: 'images/ice_milky_taro.jpeg',
    ),
    MenuItem(
      id: 'mn10',
      nama: 'Ice Thai Milk Tea',
      inisial: 'RVL',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es susu rasa taro',
      image: 'images/ice_thai_milk_tea.webp',
    ),
    MenuItem(
      id: 'mn11',
      nama: 'Ice Caramello',
      inisial: 'ic',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es susu rasa taro',
      image: 'images/ice_caramelo.webp',
    ),
    MenuItem(
      id: 'mn12',
      nama: 'Ice milk tea',
      inisial: 'MT',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa milk tea',
      image: 'images/ice_milk_tea.jpg',
    ),
    MenuItem(
      id: 'mn13',
      nama: 'Ice bubble gum',
      inisial: 'BG',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa bubble gum',
      image: 'images/ice_bubble_gum.jpeg',
    ),
    MenuItem(
      id: 'mn14',
      nama: 'Ice blueberry',
      inisial: 'BG',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa blueberry',
      image: 'images/ice_blueberry.jpeg',
    ),
    MenuItem(
      id: 'mn15',
      nama: 'Ice Durian',
      inisial: 'D',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa buah durian',
      image: 'images/ice_durian.jpeg',
    ),
    MenuItem(
      id: 'mn16',
      nama: 'Ice Manggo',
      inisial: 'G',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa buah mangga',
      image: 'images/ice_manggo.jpeg',
    ),
    MenuItem(
      id: 'mn17',
      nama: 'Ice Orange',
      inisial: 'O',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es rasa buah jeruk',
      image: 'images/ice_orange.jpg',
    ),
    MenuItem(
      id: 'mn18',
      nama: 'Ice Teler',
      inisial: 'IT',
      kategori: KategoriMenu.minuman,
      harga: 15000,
      deskripsi: 'es teler',
      image: 'images/ice_teler.jpeg',
    ),
    MenuItem(
      id: 'mn19',
      nama: 'Ice Lecy Tea',
      inisial: 'IC',
      kategori: KategoriMenu.minuman,
      harga: 12000,
      deskripsi: 'es lecy tea',
      image: 'images/ice_lecy_tea.jpeg',
    ),
    MenuItem(
      id: 'mn20',
      nama: 'Ice Lemon Tea',
      inisial: 'LT',
      kategori: KategoriMenu.minuman,
      harga: 12000,
      deskripsi: 'es lemon tea',
      image: 'images/ice_lemon_tea.jpeg',
    ),
    MenuItem(
      id: 'mn21',
      nama: 'Ice Peach Tea',
      inisial: 'PT',
      kategori: KategoriMenu.minuman,
      harga: 12000,
      deskripsi: 'es Peach tea',
      image: 'images/ice_peach_tea.jpg',
    ),
    // ── REGULER ──
    MenuItem(
      id: 'r1',
      nama: 'Meja 1 — PS4',
      inisial: 'R1',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps1.jpg',
    ),
    MenuItem(
      id: 'r2',
      nama: 'Meja 2 — PS4',
      inisial: 'R2',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps02.jpg',
    ),
    MenuItem(
      id: 'r3',
      nama: 'Meja 3_05 — PS4',
      inisial: 'R3',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps3_05.jpg',
    ),
    MenuItem(
      id: 'r4',
      nama: 'Meja 3 — PS4',
      inisial: 'R4',
      kategori: KategoriMenu.reguler,
      harga: 12000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps03.jpg',
    ),
    MenuItem(
      id: 'r5',
      nama: 'Meja 4 — PS4 Pro',
      inisial: 'R4',
      kategori: KategoriMenu.reguler,
      harga: 12000,
      deskripsi: 'PlayStation 4 Pro',
      info: 'Harga per jam',
      image: 'images/ps04.jpg',
    ),
    MenuItem(
      id: 'r6',
      nama: 'Meja Simulator Racing',
      inisial: 'SR',
      kategori: KategoriMenu.reguler,
      harga: 27000,
      deskripsi: 'Racing Simulator',
      info: 'Harga per jam',
      image: 'images/simulator.jpg',
    ),
    MenuItem(
      id: 'r7',
      nama: 'Meja 5 — PS3',
      inisial: 'R5',
      kategori: KategoriMenu.reguler,
      harga: 8000,
      deskripsi: 'PlayStation 3',
      info: 'Harga per jam',
      image: 'images/ps05.jpg',
    ),
    MenuItem(
      id: 'r8',
      nama: 'Meja 6 — PS4',
      inisial: 'R6',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps06.jpg',
    ),
    MenuItem(
      id: 'r9',
      nama: 'Meja 7 — PS4',
      inisial: 'R7',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps07.jpg',
    ),
    MenuItem(
      id: 'r10',
      nama: 'Meja 8 — PS4',
      inisial: 'R8',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps08.jpg',
    ),
    MenuItem(
      id: 'r11',
      nama: 'Meja 9 — PS4',
      inisial: 'R9',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps09.jpg',
    ),
    MenuItem(
      id: 'r12',
      nama: 'Meja 10 — PS4',
      inisial: 'R10',
      kategori: KategoriMenu.reguler,
      harga: 10000,
      deskripsi: 'PlayStation 4',
      info: 'Harga per jam',
      image: 'images/ps10.jpg',
    ),
    // ── SUITE ROOM ──
    MenuItem(
      id: 's1',
      nama: 'Suite 1',
      inisial: 'S1',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS4 Pro + Nyanyi',
      info: 'Include Netflix',
      image: 'images/suite1.jpg',
    ),
    MenuItem(
      id: 's2',
      nama: 'Suite 2',
      inisial: 'S2',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'Nintendo Switch + Nyanyi',
      info: 'Include Netflix',
      image: 'images/suite2.jpg',
    ),
    MenuItem(
      id: 's3',
      nama: 'Suite 3',
      inisial: 'S3',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS4 Pro + Nyanyi',
      info: 'Include Netflix',
      image: 'images/suite3.jpg',
    ),
    MenuItem(
      id: 's4',
      nama: 'Suite 4',
      inisial: 'S4',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS5 + Soundsystem',
      info: 'Include Netflix',
      image: 'images/suite4.jpg',
    ),
    MenuItem(
      id: 's5',
      nama: 'Suite 5',
      inisial: 'S5',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS5 + Soundsystem',
      info: 'Include Netflix',
      image: 'images/suite5.jpg',
    ),
    MenuItem(
      id: 's6',
      nama: 'Suite 6',
      inisial: 'S6',
      kategori: KategoriMenu.suiteroom,
      harga: 30000,
      deskripsi: 'PS5 + Nyanyi',
      info: 'Include Netflix • NO SMOKING',
      image: 'images/suite6.jpg',
    ),
    MenuItem(
      id: 's7',
      nama: 'Suite 7',
      inisial: 'S7',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS4 Pro + Nyanyi',
      info: 'Include Netflix • NO SMOKING',
      image: 'images/suite7.jpg',
    ),
    MenuItem(
      id: 's8',
      nama: 'Suite 8',
      inisial: 'S8',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'Nintendo Switch + Nyanyi',
      info: 'Include Netflix • NO SMOKING',
      image: 'images/suite8.jpg',
    ),
    MenuItem(
      id: 's9',
      nama: 'Suite 9',
      inisial: 'S9',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'PS4 Pro + Nyanyi',
      info: 'Include Netflix',
      image: 'images/suite9.jpg',
    ),
    MenuItem(
      id: 's10',
      nama: 'Suite 10',
      inisial: 'S10',
      kategori: KategoriMenu.suiteroom,
      harga: 25000,
      deskripsi: 'Nintendo Switch + Nyanyi',
      info: 'Include Netflix',
      image: 'images/suite10.jpg',
    ),
    MenuItem(
      id: 's11',
      nama: 'VIP Suite 11',
      inisial: 'VIP',
      kategori: KategoriMenu.suiteroom,
      harga: 40000,
      deskripsi: 'PS5 + Netflix + Nyanyi',
      info: 'Include Netflix • Kapasitas 10 orang',
      image: 'images/suite11.jpg',
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
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<MenuItem> get _filtered => _menuList.where((m) {
        final matchKat = m.kategori == _selectedKategori;
        final matchSearch = _searchQuery.isEmpty ||
            m.nama.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchKat && matchSearch;
      }).toList();

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKategoriTab(),
                  const SizedBox(height: 12),
                  _buildSearchBar(),
                  const SizedBox(height: 12),
                  _buildSummaryChip(),
                  const SizedBox(height: 12),
                  _buildMenuList(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  // ─── HEADER (sama persis owner dashboard) ────────────────────────────────
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
        _headerIconBtn(
          Icons.settings_outlined,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilOwnerScreen()),
          ),
        ),
        const SizedBox(width: 6),
        _headerIconBtn(
          Icons.notifications_outlined,
          badge: 3,
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

  // ─── KATEGORI TAB ────────────────────────────────────────────────────────
  Widget _buildKategoriTab() {
    final tabs = [
      (KategoriMenu.makanan, '🍔', 'Makanan'),
      (KategoriMenu.minuman, '🥤', 'Minuman'),
      (KategoriMenu.reguler, '🎮', 'Reguler'),
      (KategoriMenu.suiteroom, '🏠', 'Suite'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isActive = _selectedKategori == t.$1;
          final color = _kategoriColor(t.$1);
          return GestureDetector(
            onTap: () => setState(() {
              _selectedKategori = t.$1;
              _searchQuery = '';
              _searchCtrl.clear();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? color : kWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(t.$2, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    t.$3,
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isActive ? kWhite : Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: 'Cari menu...',
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.black38, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () => setState(() {
                    _searchQuery = '';
                    _searchCtrl.clear();
                  }),
                  child: const Icon(
                    Icons.close,
                    color: Colors.black38,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // ─── SUMMARY CHIP ────────────────────────────────────────────────────────
  Widget _buildSummaryChip() {
    final total = _filtered.length;
    final tersedia = _filtered.where((m) => m.tersedia).length;
    final color = _kategoriColor(_selectedKategori);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$total item • $tersedia tersedia',
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  // ─── MENU LIST ───────────────────────────────────────────────────────────
  Widget _buildMenuList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: Colors.black26),
              const SizedBox(height: 12),
              Text(
                'Tidak ada menu',
                style: GoogleFonts.lato(fontSize: 14, color: Colors.black38),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: list.map((m) => _menuCard(m)).toList());
  }

  Widget _menuCard(MenuItem m) {
    final color = _kategoriColor(m.kategori);
    final isJam = m.kategori == KategoriMenu.reguler ||
        m.kategori == KategoriMenu.suiteroom;
    final isVIP = m.nama.contains('VIP');
    final isNoSmoke = m.info != null && m.info!.contains('NO SMOKING');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
        border: isVIP ? Border.all(color: kGold, width: 1.5) : null,
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
          // Gambar menu
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(
                  m.image ?? 'images/default.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.nama,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isVIP ? kGold : kTextDark,
                        ),
                      ),
                    ),
                    if (isVIP)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'VIP',
                          style: GoogleFonts.lato(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: kWhite,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  m.deskripsi,
                  style: GoogleFonts.lato(fontSize: 11, color: Colors.black45),
                ),
                if (m.info != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (isNoSmoke) ...[
                        const Icon(Icons.smoke_free, size: 11, color: kGreen),
                        const SizedBox(width: 3),
                      ],
                      Expanded(
                        child: Text(
                          m.info!,
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: isNoSmoke ? kGreen : Colors.black38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Harga + aksi
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${_formatHarga(m.harga)}',
                style: GoogleFonts.lato(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              if (isJam)
                Text(
                  '/jam',
                  style: GoogleFonts.lato(fontSize: 10, color: Colors.black38),
                ),
              const SizedBox(height: 6),
              // Toggle tersedia
              GestureDetector(
                onTap: () => setState(() => m.tersedia = !m.tersedia),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: m.tersedia
                        ? kGreen.withOpacity(0.1)
                        : kRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    m.tersedia ? 'TERSEDIA' : 'HABIS',
                    style: GoogleFonts.lato(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: m.tersedia ? kGreen : kRed,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  _actionBtn(
                    Icons.edit_outlined,
                    kBlue,
                    () => _showEditDialog(m),
                  ),
                  const SizedBox(width: 6),
                  _actionBtn(
                    Icons.delete_outline,
                    kRed,
                    () => _showDeleteDialog(m),
                  ),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: color),
      ),
    );
  }

  // ─── FAB ─────────────────────────────────────────────────────────────────
  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showTambahDialog(),
      backgroundColor: _kategoriColor(_selectedKategori),
      icon: const Icon(Icons.add, color: kWhite),
      label: Text(
        'Tambah Menu',
        style: GoogleFonts.lato(fontWeight: FontWeight.w800, color: kWhite),
      ),
    );
  }

  // ─── HELPER ──────────────────────────────────────────────────────────────
  Color _kategoriColor(KategoriMenu k) {
    switch (k) {
      case KategoriMenu.makanan:
        return kBlue;
      case KategoriMenu.minuman:
        return kBlueBg;
      case KategoriMenu.reguler:
        return kBlue;
      case KategoriMenu.suiteroom:
        return kBlueBg;
    }
  }

  String _getInisial(String inisial) {
    return inisial
        .trim()
        .substring(0, inisial.trim().length.clamp(1, 3))
        .toUpperCase();
  }

  String _formatHarga(int h) {
    if (h >= 1000) return '${(h / 1000).toStringAsFixed(0)}.000';
    return '$h';
  }

  // ─── DIALOG TAMBAH ───────────────────────────────────────────────────────
  void _showTambahDialog() {
    final namaCtrl = TextEditingController();
    final inisialCtrl = TextEditingController();
    final hargaCtrl = TextEditingController();
    final deskCtrl = TextEditingController();
    final infoCtrl = TextEditingController();
    KategoriMenu kat = _selectedKategori;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Tambah Menu',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(namaCtrl, 'Nama Menu', Icons.restaurant_menu),
                const SizedBox(height: 10),
                _dialogField(
                  inisialCtrl,
                  'Inisial (maks 3 huruf)',
                  Icons.text_fields,
                  maxLength: 3,
                ),
                const SizedBox(height: 10),
                _dialogField(
                  hargaCtrl,
                  'Harga (Rp)',
                  Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 10),
                _dialogField(deskCtrl, 'Deskripsi', Icons.info_outline),
                const SizedBox(height: 10),
                _dialogField(
                  infoCtrl,
                  'Info Tambahan (opsional)',
                  Icons.label_outline,
                ),
                const SizedBox(height: 10),
                _dialogDropdown<KategoriMenu>(
                  label: 'Kategori',
                  value: kat,
                  items: KategoriMenu.values,
                  itemLabel: (v) => _kategoriLabel(v),
                  onChanged: (v) => setDlg(() => kat = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.lato(color: Colors.black45),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (namaCtrl.text.isNotEmpty && hargaCtrl.text.isNotEmpty) {
                  final nama = namaCtrl.text.trim();
                  final inisial = inisialCtrl.text.trim().isNotEmpty
                      ? inisialCtrl.text.trim().toUpperCase()
                      : _getInisial(
                          nama
                              .split(' ')
                              .take(3)
                              .map((e) => e.isNotEmpty ? e[0] : '')
                              .join(),
                        );
                  setState(() {
                    _menuList.add(
                      MenuItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        nama: nama,
                        inisial: inisial,
                        kategori: kat,
                        harga: int.tryParse(hargaCtrl.text) ?? 0,
                        deskripsi: deskCtrl.text.trim(),
                        info: infoCtrl.text.trim().isEmpty
                            ? null
                            : infoCtrl.text.trim(),
                      ),
                    );
                  });
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                'Simpan',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOG EDIT ─────────────────────────────────────────────────────────
  void _showEditDialog(MenuItem m) {
    final namaCtrl = TextEditingController(text: m.nama);
    final inisialCtrl = TextEditingController(text: m.inisial);
    final hargaCtrl = TextEditingController(text: m.harga.toString());
    final deskCtrl = TextEditingController(text: m.deskripsi);
    final infoCtrl = TextEditingController(text: m.info ?? '');
    KategoriMenu kat = m.kategori;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Edit Menu',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w900,
              color: kTextDark,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(namaCtrl, 'Nama Menu', Icons.restaurant_menu),
                const SizedBox(height: 10),
                _dialogField(
                  inisialCtrl,
                  'Inisial (maks 3 huruf)',
                  Icons.text_fields,
                  maxLength: 3,
                ),
                const SizedBox(height: 10),
                _dialogField(
                  hargaCtrl,
                  'Harga (Rp)',
                  Icons.attach_money,
                  isNumber: true,
                ),
                const SizedBox(height: 10),
                _dialogField(deskCtrl, 'Deskripsi', Icons.info_outline),
                const SizedBox(height: 10),
                _dialogField(
                  infoCtrl,
                  'Info Tambahan (opsional)',
                  Icons.label_outline,
                ),
                const SizedBox(height: 10),
                _dialogDropdown<KategoriMenu>(
                  label: 'Kategori',
                  value: kat,
                  items: KategoriMenu.values,
                  itemLabel: (v) => _kategoriLabel(v),
                  onChanged: (v) => setDlg(() => kat = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Batal',
                style: GoogleFonts.lato(color: Colors.black45),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                setState(() {
                  m.nama = namaCtrl.text.trim();
                  m.inisial = inisialCtrl.text.trim().isNotEmpty
                      ? inisialCtrl.text.trim().toUpperCase()
                      : m.inisial;
                  m.harga = int.tryParse(hargaCtrl.text) ?? m.harga;
                  m.deskripsi = deskCtrl.text.trim();
                  m.kategori = kat;
                  m.info = infoCtrl.text.trim().isEmpty
                      ? null
                      : infoCtrl.text.trim();
                });
                Navigator.pop(ctx);
              },
              child: Text(
                'Simpan',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w800,
                  color: kWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── DIALOG HAPUS ────────────────────────────────────────────────────────
  void _showDeleteDialog(MenuItem m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Menu',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w900,
            color: kTextDark,
          ),
        ),
        content: RichText(
          text: TextSpan(
            style: GoogleFonts.lato(fontSize: 13, color: Colors.black54),
            children: [
              const TextSpan(text: 'Yakin hapus '),
              TextSpan(
                text: m.nama,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: kTextDark,
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.lato(color: Colors.black45),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              setState(() => _menuList.removeWhere((e) => e.id == m.id));
              Navigator.pop(ctx);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w800,
                color: kWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DIALOG WIDGETS ──────────────────────────────────────────────────────
  Widget _dialogField(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    bool isNumber = false,
    int? maxLength,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.lato(fontSize: 13, color: Colors.black38),
          prefixIcon: Icon(icon, size: 18, color: Colors.black38),
          border: InputBorder.none,
          counterText: '',
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
      decoration: BoxDecoration(
        color: kBgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: GoogleFonts.lato(fontSize: 13, color: kTextDark),
          items: items
              .map(
                (e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(itemLabel != null ? itemLabel(e) : e.toString()),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  String _kategoriLabel(KategoriMenu k) {
    switch (k) {
      case KategoriMenu.makanan:
        return 'Makanan';
      case KategoriMenu.minuman:
        return 'Minuman';
      case KategoriMenu.reguler:
        return 'Reguler';
      case KategoriMenu.suiteroom:
        return 'Suite Room';
    }
  }
}
