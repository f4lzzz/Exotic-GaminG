import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class BookingPage extends StatefulWidget {
  final String? preselectedRoomId;

  const BookingPage({super.key, this.preselectedRoomId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late String _selectedRoomId;
  final TextEditingController _namaPemesanCtrl = TextEditingController();
  TimeOfDay _selectedStart = TimeOfDay(
    hour: TimeOfDay.now().hour,
    minute: 0,
  );
  int _durationHours = 1;
  String _result = '';
  bool _success = false;

  @override
  void initState() {
    super.initState();
    final rooms = context.read<AppState>().rooms;
    _selectedRoomId = widget.preselectedRoomId ?? rooms.first.id;
  }

  @override
  void dispose() {
    _namaPemesanCtrl.dispose();
    super.dispose();
  }

  void _createBooking() {
    if (_namaPemesanCtrl.text.trim().isEmpty) {
      setState(() {
        _result = '⚠️ Nama pemesan tidak boleh kosong';
        _success = false;
      });
      return;
    }

    final now = DateTime.now();
    final jamMulai = DateTime(
      now.year, now.month, now.day,
      _selectedStart.hour, _selectedStart.minute,
    );
    final jamSelesai = jamMulai.add(Duration(hours: _durationHours));

    final berhasil = context.read<AppState>().bookRoom(
      roomId: _selectedRoomId,
      namaPemesan: _namaPemesanCtrl.text.trim(),
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
    );

    final rooms = context.read<AppState>().rooms;
    final namaRoom = rooms.firstWhere((r) => r.id == _selectedRoomId).namaRoom;
    final availableAgain = jamSelesai.add(const Duration(minutes: 10));

    setState(() {
      _success = berhasil;
      _result = berhasil
          ? '''✅ Booking berhasil!

Room     : $namaRoom
Pemesan  : ${_namaPemesanCtrl.text.trim()}
Mulai    : ${jamMulai.hour}:${jamMulai.minute.toString().padLeft(2, '0')}
Selesai  : ${jamSelesai.hour}:${jamSelesai.minute.toString().padLeft(2, '0')}
Siap lagi: ${availableAgain.hour}:${availableAgain.minute.toString().padLeft(2, '0')}'''
          : '❌ Room masih dipakai / belum tersedia';
    });

    if (berhasil) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStart,
    );
    if (picked != null) setState(() => _selectedStart = picked);
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<AppState>().rooms;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text('Booking Room'),
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Pilih Room ───────────────────────────────
            DropdownButtonFormField<String>(
              value: _selectedRoomId,
              items: rooms.map((room) {
                final isBooked = room.status == 'booked';
                return DropdownMenuItem(
                  value: room.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 10,
                        color: isBooked ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(room.namaRoom),
                      if (isBooked)
                        const Text(
                          ' (Dipakai)',
                          style: TextStyle(fontSize: 12, color: Colors.red),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedRoomId = value!),
              decoration: const InputDecoration(
                labelText: 'Pilih Room',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // ── Nama Pemesan ─────────────────────────────
            TextField(
              controller: _namaPemesanCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Pemesan',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 14),

            // ── Jam Mulai ────────────────────────────────
            InkWell(
              onTap: _pickTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF1a237e)),
                    const SizedBox(width: 10),
                    Text(
                      'Jam Mulai : '
                      '${_selectedStart.hour}:${_selectedStart.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Durasi ───────────────────────────────────
            DropdownButtonFormField<int>(
              value: _durationHours,
              items: List.generate(12, (i) {
                final jam = i + 1;
                return DropdownMenuItem(
                  value: jam,
                  child: Text('$jam Jam'),
                );
              }),
              onChanged: (value) => setState(() => _durationHours = value!),
              decoration: const InputDecoration(
                labelText: 'Durasi Booking',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // ── Tombol Booking ───────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1a237e),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'BOOKING SEKARANG',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                onPressed: _createBooking,
              ),
            ),

            const SizedBox(height: 20),

            // ── Result ───────────────────────────────────
            if (_result.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _success ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  _result,
                  style: TextStyle(
                    fontSize: 14,
                    color: _success
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}