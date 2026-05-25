import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../models/models.dart';

class MonitorRoomPage extends StatefulWidget {
  const MonitorRoomPage({super.key});

  @override
  State<MonitorRoomPage> createState() => _MonitorRoomPageState();
}

class _MonitorRoomPageState extends State<MonitorRoomPage> {
  Timer? _autoFreeTimer;

  String? _selectedRoomId;
  TimeOfDay _selectedStart = const TimeOfDay(hour: 9, minute: 0);

  int _durationHours = 1;

  String _result = '';
  String _resultType = '';

  @override
  void initState() {
    super.initState();

    _autoFreeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (mounted) {
          context.read<AppState>().checkAndFreeExpiredRooms();
        }
      },
    );
  }

  @override
  void dispose() {
    _autoFreeTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStart,
    );

    if (picked != null) {
      setState(() {
        _selectedStart = picked;
        _result = '';
      });
    }
  }

  void _createBooking() {
    final appState = context.read<AppState>();
    final rooms = appState.rooms;

    if (rooms.isEmpty) {
      setState(() {
        _result = '❌ Tidak ada ruangan tersedia';
        _resultType = 'error';
      });
      return;
    }

    final roomId = _selectedRoomId ?? rooms.first.id;

    final room = rooms.firstWhere(
      (r) => r.id == roomId,
    );

    final now = DateTime.now();

    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedStart.hour,
      _selectedStart.minute,
    );

    // kalau jam sudah lewat hari ini → otomatis besok
    if (startTime.isBefore(now)) {
      startTime = startTime.add(const Duration(days: 1));
    }

    final endTime = startTime.add(Duration(hours: _durationHours));

    final available = appState.isRoomAvailable(
      roomId: roomId,
      jamMulai: startTime,
      jamSelesai: endTime,
    );

    if (!available) {
      setState(() {
        _result = '❌ Ruangan sudah dibooking di jam tersebut!';
        _resultType = 'error';
      });
      return;
    }

    appState.bookRoom(
      roomId: roomId,
      namaPemesan: 'User',
      jamMulai: startTime,
      jamSelesai: endTime,
    );

    setState(() {
      _result = '✅ Booking berhasil untuk ${room.namaRoom}';
      _resultType = 'success';
    });
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<AppState>().rooms;
    final bookings = context.watch<AppState>().bookings;

    if (_selectedRoomId == null && rooms.isNotEmpty) {
      _selectedRoomId = rooms.first.id;
    }

    // ✅ Tidak pakai Scaffold/AppBar — langsung LayoutBuilder
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildBookingFormCard(rooms),
                    const SizedBox(height: 12),
                    if (_result.isNotEmpty) _buildResultMessage(),
                    const SizedBox(height: 16),
                    _buildBookingHeader(bookings.length),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: _buildBookingList(bookings),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF3F3D9E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.meeting_room,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Ruangan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Isi form di bawah untuk booking',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // ✅ Tombol refresh dipindah ke sini (ganti AppBar actions)
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<AppState>().checkAndFreeExpiredRooms();
              setState(() {
                _result = '';
              });
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildBookingFormCard(List<RoomModel> rooms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F35),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRoomId,
            dropdownColor: const Color(0xFF252A45),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Pilih Ruangan',
              labelStyle: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.meeting_room,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3A3F5E),
                ),
              ),
            ),
            items: rooms.map((room) {
              return DropdownMenuItem(
                value: room.id,
                child: Text(room.namaRoom),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedRoomId = value!;
                _result = '';
              });
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFF3A3F5E),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Jam Mulai: '
                    '${_selectedStart.hour.toString().padLeft(2, '0')}:'
                    '${_selectedStart.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _durationHours,
            dropdownColor: const Color(0xFF252A45),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              labelText: 'Durasi Booking',
              labelStyle: const TextStyle(
                color: Color(0xFF6C63FF),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.timer,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: List.generate(8, (index) {
              final jam = index + 1;
              return DropdownMenuItem(
                value: jam,
                child: Text('$jam Jam'),
              );
            }),
            onChanged: (value) {
              setState(() {
                _durationHours = value!;
                _result = '';
              });
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _createBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'BOOKING SEKARANG',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _resultType == 'success'
            ? const Color(0xFF00B886).withOpacity(0.1)
            : const Color(0xFFFF3B3B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            _resultType == 'success' ? Icons.check_circle : Icons.error,
            color: _resultType == 'success'
                ? const Color(0xFF00B886)
                : const Color(0xFFFF3B3B),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _result,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(int count) {
    return Row(
      children: [
        const Text(
          'Daftar Booking',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF252A45),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: Color(0xFF6C63FF),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada booking',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.meeting_room,
                color: Color(0xFF6C63FF),
              ),
              title: Text(
                booking.namaRoom,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(booking.jamMulai)} - ${_formatTime(booking.jamSelesai)}',
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Tersedia: ${_formatTime(booking.availableAgain)}',
                    style: const TextStyle(
                      color: Color(0xFF00B886),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                ),
                onPressed: () {
                  context.read<AppState>().cancelBooking(booking.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}