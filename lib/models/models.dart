export 'log_entry.dart';

// TransaksiModel
class TransaksiModel {
  final String id;
  final String namaMenu;
  final double harga;
  final String kasir;
  final String shift;
  final DateTime waktu;

  TransaksiModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.kasir,
    required this.shift,
    required this.waktu,
  });
}

// RoomModel
class RoomModel {
  final String id;
  final String namaRoom;
  final String status;
  final String namaPemesan;
  final DateTime? jamMulai;
  final DateTime? jamSelesai;

  RoomModel({
    required this.id,
    required this.namaRoom,
    this.status = 'free',
    this.namaPemesan = '',
    this.jamMulai,
    this.jamSelesai,
  });

  RoomModel copyWith({
    String? status,
    String? namaPemesan,
    DateTime? jamMulai,
    DateTime? jamSelesai,
  }) {
    return RoomModel(
      id: id,
      namaRoom: namaRoom,
      status: status ?? this.status,
      namaPemesan: namaPemesan ?? this.namaPemesan,
      jamMulai: jamMulai ?? this.jamMulai,
      jamSelesai: jamSelesai ?? this.jamSelesai,
    );
  }

  RoomModel clearJam() {
    return RoomModel(
      id: id,
      namaRoom: namaRoom,
      status: status,
      namaPemesan: namaPemesan,
      jamMulai: null,
      jamSelesai: null,
    );
  }
}

// BookingModel
class BookingModel {
  final String id;
  final String roomId;
  final String namaRoom;
  final String namaPemesan;
  final DateTime jamMulai;
  final DateTime jamSelesai;

  BookingModel({
    required this.id,
    required this.roomId,
    required this.namaRoom,
    required this.namaPemesan,
    required this.jamMulai,
    required this.jamSelesai,
  });

  DateTime get availableAgain => jamSelesai.add(const Duration(minutes: 10));

  int get durationInMinutes => jamSelesai.difference(jamMulai).inMinutes;

  bool get isActive => DateTime.now().isBefore(jamSelesai);
}
