import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';
import '../models/models.dart';

// ==================== WARNA (sama dengan owner dashboard) ====================
const kBlue = Color(0xFF1A5EBF);
const kWhite = Color(0xFFFFFFFF);
const kTextDark = Color(0xFF1A237E);
const kGreen = Color(0xFF4CAF50);
const kRed = Color(0xFFE53935);
const kBgLight = Color(0xFFF0F4FF);

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
    final room = rooms.firstWhere((r) => r.id == roomId);

    final now = DateTime.now();
    DateTime startTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedStart.hour,
      _selectedStart.minute,
    );
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
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final rooms = context.watch<AppState>().rooms;
    final bookings = context.watch<AppState>().bookings;

    if (_selectedRoomId == null && rooms.isNotEmpty) {
      _selectedRoomId = rooms.first.id;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookingFormCard(rooms),
          const SizedBox(height: 16),
          if (_result.isNotEmpty) _buildResultMessage(),
          const SizedBox(height: 24),
          _buildBookingHeader(bookings.length),
          const SizedBox(height: 12),
          _buildBookingList(bookings),
        ],
      ),
    );
  }

  Widget _buildBookingFormCard(List<RoomModel> rooms) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedRoomId,
            dropdownColor: kWhite,
            style: GoogleFonts.lato(color: kTextDark, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Pilih Ruangan',
              labelStyle: GoogleFonts.lato(
                  fontWeight: FontWeight.w600, color: kBlue, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.meeting_room, color: kBlue, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue)),
            ),
            items: rooms.map((room) {
              return DropdownMenuItem(
                  value: room.id, child: Text(room.namaRoom));
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: kBlue, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'Jam Mulai: ${_selectedStart.hour.toString().padLeft(2, '0')}:${_selectedStart.minute.toString().padLeft(2, '0')}',
                    style: GoogleFonts.lato(color: kTextDark, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _durationHours,
            dropdownColor: kWhite,
            style: GoogleFonts.lato(color: kTextDark, fontSize: 14),
            decoration: InputDecoration(
              labelText: 'Durasi Booking',
              labelStyle: GoogleFonts.lato(
                  fontWeight: FontWeight.w600, color: kBlue, fontSize: 13),
              prefixIcon: const Icon(Icons.timer, color: kBlue, size: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBlue)),
            ),
            items: List.generate(8, (index) {
              final jam = index + 1;
              return DropdownMenuItem(value: jam, child: Text('$jam Jam'));
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
                backgroundColor: kBlue,
                foregroundColor: kWhite,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('BOOKING SEKARANG',
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.w800, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultMessage() {
    final color = _resultType == 'success' ? kGreen : kRed;
    final icon = _resultType == 'success' ? Icons.check_circle : Icons.error;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
              child: Text(_result,
                  style: GoogleFonts.lato(color: kTextDark, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildBookingHeader(int count) {
    return Row(
      children: [
        Text('Daftar Booking',
            style: GoogleFonts.lato(
                fontSize: 15, fontWeight: FontWeight.w800, color: kTextDark)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: kBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          child: Text('$count',
              style:
                  GoogleFonts.lato(fontWeight: FontWeight.w800, color: kBlue)),
        ),
      ],
    );
  }

  Widget _buildBookingList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.event_busy, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('Belum ada booking',
                style: GoogleFonts.lato(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2))
            ],
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kBlue.withOpacity(0.1),
              child: Icon(Icons.meeting_room, color: kBlue),
            ),
            title: Text(booking.namaRoom,
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w800, color: kTextDark)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '${_formatTime(booking.jamMulai)} - ${_formatTime(booking.jamSelesai)}',
                  style: GoogleFonts.lato(fontSize: 12, color: Colors.black54),
                ),
                Text(
                  'Tersedia: ${_formatTime(booking.availableAgain)}',
                  style: GoogleFonts.lato(fontSize: 11, color: kGreen),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.close, color: kRed),
              onPressed: () =>
                  context.read<AppState>().cancelBooking(booking.id),
            ),
          ),
        );
      },
    );
  }
}
