import 'package:flutter/material.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {

  // ───────────────── TRANSAKSI ─────────────────

  final List<TransaksiModel> _transaksi = [];

  List<TransaksiModel> get transaksi =>
      List.unmodifiable(_transaksi);

  void tambahTransaksi({
    required String namaMenu,
    required double harga,
    required String kasir,
    required String shift,
  }) {
    _transaksi.add(
      TransaksiModel(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .toString(),
        namaMenu: namaMenu,
        harga: harga,
        kasir: kasir,
        shift: shift,
        waktu: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  // ===============================
  // HAPUS SATU TRANSAKSI
  // ===============================

  void hapusTransaksi(String id) {
    _transaksi.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  double get totalTransaksi =>
      _transaksi.fold(0, (sum, t) => sum + t.harga);

  void closingShift() {
    _transaksi.clear();
    notifyListeners();
  }

  // ───────────────── ROOM ─────────────────

  final List<RoomModel> _rooms = List.generate(
    11,
    (i) => RoomModel(
      id: 'room_${i + 1}',
      namaRoom: 'Room ${i + 1}',
    ),
  );

  List<RoomModel> get rooms =>
      List.unmodifiable(_rooms);

  // ───────────────── BOOKING ─────────────────

  final List<BookingModel> _bookings = [];

  List<BookingModel> get bookings =>
      List.unmodifiable(_bookings);

  // ===============================
  // CEK ROOM TERSEDIA
  // ===============================

  bool isRoomAvailable({
    required String roomId,
    required DateTime jamMulai,
    required DateTime jamSelesai,
  }) {
    for (final booking in _bookings) {
      if (booking.roomId != roomId) continue;

      // Cek apakah waktu bentrok
      final bentrok =
          jamMulai.isBefore(booking.jamSelesai) &&
          jamSelesai.isAfter(booking.jamMulai);

      if (bentrok) return false;
    }
    return true;
  }

  // ===============================
  // BOOK ROOM
  // ===============================

  bool bookRoom({
    required String roomId,
    required String namaPemesan,
    required DateTime jamMulai,
    required DateTime jamSelesai,
  }) {
    final tersedia = isRoomAvailable(
      roomId: roomId,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
    );

    if (!tersedia) return false;

    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex == -1) return false;

    // ✅ LANGSUNG TAMBAH BOOKING BARU TANPA MENGHAPUS YANG LAMA
    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomId: roomId,
      namaRoom: _rooms[roomIndex].namaRoom,
      namaPemesan: namaPemesan,
      jamMulai: jamMulai,
      jamSelesai: jamSelesai,
    );

    _bookings.add(newBooking);

    notifyListeners();
    return true;
  }

  // ===============================
  // FREE ROOM
  // ===============================

  void freeRoom(String roomId) {
    _bookings.removeWhere((b) => b.roomId == roomId);
    notifyListeners();
  }

  // ===============================
  // AUTO FREE ROOM EXPIRED
  // ===============================

  void checkAndFreeExpiredRooms() {
    final now = DateTime.now();
    final beforeCount = _bookings.length;

    // ✅ HANYA HAPUS BOOKING YANG SUDAH EXPIRED
    _bookings.removeWhere((booking) {
      return now.isAfter(booking.jamSelesai);
    });

    if (beforeCount != _bookings.length) {
      notifyListeners();
    }
  }

  // ===============================
  // HAPUS SEMUA BOOKING
  // ===============================

  void clearAllBookings() {
    _bookings.clear();
    notifyListeners();
  }

  // ===============================
  // HAPUS SATU BOOKING
  // ===============================

  void cancelBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }
}