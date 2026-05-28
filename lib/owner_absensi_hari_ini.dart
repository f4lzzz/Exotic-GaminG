import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const kBlue = Color(0xFF1A5EBF);
const kBlueBg = Color(0xFF4A90D9);
const kYellow = Color(0xFFF5C842);
const kWhite = Color(0xFFFFFFFF);
const kWhiteDim = Color(0xFFDDE8FF);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kOrange = Color(0xFFFF9800);
const kBgLight = Color(0xFFF0F4FF);

/// Widget card yang bisa dipakai di dashboard owner
/// untuk toggle "absen dimana saja" dan lihat absensi hari ini
class OwnerAbsensiSettingsCard extends StatefulWidget {
  const OwnerAbsensiSettingsCard({super.key});

  @override
  State<OwnerAbsensiSettingsCard> createState() =>
      _OwnerAbsensiSettingsCardState();
}

class _OwnerAbsensiSettingsCardState extends State<OwnerAbsensiSettingsCard> {
  bool _bebasLokasi = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('absensi')
        .get();
    if (mounted) {
      setState(() => _bebasLokasi = doc.data()?['bebasLokasi'] ?? false);
    }
  }

  Future<void> _toggleBebasLokasi(bool val) async {
    setState(() {
      _bebasLokasi = val;
      _loading = true;
    });
    await FirebaseFirestore.instance
        .collection('settings')
        .doc('absensi')
        .set({'bebasLokasi': val}, SetOptions(merge: true));
    setState(() => _loading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          val
              ? '✅ Mode bebas lokasi diaktifkan'
              : '📍 Absen wajib di lokasi toko',
          style: GoogleFonts.lato(color: kWhite, fontWeight: FontWeight.w700),
        ),
        backgroundColor: val ? kOrange : kBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Toggle bebas lokasi ──────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(18),
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
              Row(children: [
                const Icon(Icons.settings_rounded, color: kBlue, size: 18),
                const SizedBox(width: 8),
                Text('PENGATURAN ABSENSI',
                    style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: kTextDark,
                        letterSpacing: 0.5)),
              ]),
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _bebasLokasi
                      ? kOrange.withOpacity(0.08)
                      : kBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _bebasLokasi
                        ? kOrange.withOpacity(0.3)
                        : kBlue.withOpacity(0.2),
                  ),
                ),
                child: Row(children: [
                  Icon(
                    _bebasLokasi ? Icons.public_rounded : Icons.store_rounded,
                    color: _bebasLokasi ? kOrange : kBlue,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _bebasLokasi
                                ? 'BEBAS LOKASI AKTIF'
                                : 'WAJIB DI LOKASI TOKO',
                            style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: _bebasLokasi ? kOrange : kBlue),
                          ),
                          Text(
                            _bebasLokasi
                                ? 'Karyawan bisa absen dari mana saja'
                                : 'Karyawan wajib absen di lokasi toko',
                            style: GoogleFonts.lato(
                                fontSize: 10, color: Colors.black45),
                          ),
                        ]),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kOrange),
                    )
                  else
                    Switch(
                      value: _bebasLokasi,
                      activeColor: kOrange,
                      onChanged: _toggleBebasLokasi,
                    ),
                ]),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Absensi hari ini ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(18),
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
                  Row(children: [
                    const Icon(Icons.people_alt_rounded,
                        color: kBlue, size: 18),
                    const SizedBox(width: 8),
                    Text('ABSENSI HARI INI',
                        style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: kTextDark,
                            letterSpacing: 0.5)),
                  ]),
                  Text(
                    DateFormat('d MMM yyyy').format(DateTime.now()),
                    style: GoogleFonts.lato(
                        fontSize: 10,
                        color: Colors.black38,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notif_owner')
                    .where('tanggal',
                        isEqualTo:
                            DateFormat('yyyy-MM-dd').format(DateTime.now()))
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (_, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: kBlue),
                    ));
                  }
                  final docs = snap.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Column(children: [
                          const Icon(Icons.hourglass_empty_rounded,
                              size: 36, color: Colors.black26),
                          const SizedBox(height: 8),
                          Text('Belum ada yang absen hari ini',
                              style: GoogleFonts.lato(
                                  fontSize: 12, color: Colors.black38)),
                        ]),
                      ),
                    );
                  }

                  // Group by uid: tampilkan masuk & pulang per orang
                  final Map<String, Map<String, dynamic>> grouped = {};
                  for (final doc in docs) {
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = data['uid'] ?? '';
                    if (!grouped.containsKey(uid)) {
                      grouped[uid] = {
                        'nama': data['nama'] ?? '-',
                        'masuk': null,
                        'pulang': null,
                      };
                    }
                    if (data['type'] == 'masuk') {
                      grouped[uid]!['masuk'] = data['jam'];
                    } else {
                      grouped[uid]!['pulang'] = data['jam'];
                    }
                  }

                  return Column(
                    children: grouped.values.map((k) {
                      final nama = k['nama'] as String;
                      final masuk = k['masuk'] as String?;
                      final pulang = k['pulang'] as String?;
                      final initials = nama
                          .trim()
                          .split(' ')
                          .take(2)
                          .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                          .join();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kBgLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: kBlue.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(initials,
                                  style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: kBlue)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nama,
                                      style: GoogleFonts.lato(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: kTextDark)),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    _shiftChip('▶ ${masuk ?? '--:--'}', kGreen,
                                        masuk != null),
                                    const SizedBox(width: 6),
                                    _shiftChip('⏹ ${pulang ?? '--:--'}',
                                        kOrange, pulang != null),
                                  ]),
                                ]),
                          ),
                          Icon(
                            pulang != null
                                ? Icons.check_circle_rounded
                                : masuk != null
                                    ? Icons.pending_rounded
                                    : Icons.circle_outlined,
                            color: pulang != null
                                ? kGreen
                                : masuk != null
                                    ? kOrange
                                    : Colors.black26,
                            size: 20,
                          ),
                        ]),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shiftChip(String text, Color color, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color:
            active ? color.withOpacity(0.12) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: GoogleFonts.lato(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: active ? color : Colors.black38)),
    );
  }
}
