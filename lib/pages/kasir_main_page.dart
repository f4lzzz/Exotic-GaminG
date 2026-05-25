import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../state/app_state.dart';
import '../kasir_data_page.dart';
import 'monitor_room_page.dart';

class KasirMainPage extends StatefulWidget {
  final String kasirName;
  final String shift;

  const KasirMainPage({super.key, required this.kasirName, required this.shift});

  @override
  State<KasirMainPage> createState() => _KasirMainPageState();
}

class _KasirMainPageState extends State<KasirMainPage> {
  int _tab = 0;
  String _time = '';
  String _date = '';
  Timer? _clock;
  Timer? _roomFreeTimer;

  // ✅ Dipindah ke level class — aman karena locale sudah diinit di main()
  final _timeFmt = DateFormat('HH:mm:ss', 'id_ID');
  final _dateFmt = DateFormat('EEEE, dd MMM yyyy', 'id_ID');

  @override
  void initState() {
    super.initState();
    _updateTime();

    _clock = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_updateTime);
    });

    _roomFreeTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) context.read<AppState>().checkAndFreeExpiredRooms();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    _time = _timeFmt.format(now);
    _date = _dateFmt.format(now);
  }

  @override
  void dispose() {
    _clock?.cancel();
    _roomFreeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trxCount = context.watch<AppState>().transaksi.length;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 165, 202, 19), // Abu2 sangat soft
      body: Column(
        children: [
          // ── Header dengan jam realtime ───────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2C5AA0), Color(0xFF1E3A6B)], // Biru gelap solid
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.storefront, color: Color.fromARGB(255, 164, 12, 131), size: 28), // Ganti icon
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EXOTIC GAMING & CAFFE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Portal Karyawan',
                        style: TextStyle(color: Color.fromARGB(179, 35, 79, 45), fontSize: 11),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.kasirName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kasir – ${widget.shift}',
                          style: const TextStyle(color: Color.fromARGB(179, 234, 13, 13), fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _time,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 10, 156, 32),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _date,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 27, 40, 157),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Sub header KASIR POS ─────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C5AA0), size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.point_of_sale, color: Color(0xFF2C5AA0), size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'KASIR POS',
                  style: TextStyle(
                    color: Color(0xFF1A2C3E),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2C5AA0), Color(0xFF1E3A6B)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'TRX: $trxCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Tab switcher ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 87, 81, 81),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 192, 48, 48).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _TabBtn(
                    label: 'KASIR DATA',
                    selected: _tab == 0,
                    onTap: () => setState(() => _tab = 0),
                  ),
                  _TabBtn(
                    label: 'MONITOR ROOM',
                    selected: _tab == 1,
                    onTap: () => setState(() => _tab = 1),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Content ──────────────────────────────────────
          Expanded(
            child: _tab == 0
                ? KasirDataPage(kasirName: widget.kasirName, shift: widget.shift)
                : const MonitorRoomPage(),
          ),
        ],
      ),
    );
  }
}

// ── Tab Button ───────────────────────────────────────────

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabBtn({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF2C5AA0) : Colors.transparent,
            borderRadius: BorderRadius.circular(36),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2C5AA0).withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color.fromARGB(255, 21, 255, 0) : const Color.fromARGB(255, 11, 131, 236),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}