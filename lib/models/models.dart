export 'log_entry.dart';

// ─── Enum untuk tipe notifikasi ────────────────────────────────────────────
enum NotificationType {
  pengumuman,  // Pengumuman umum dari owner
  jadwal,      // Jadwal shift
  absensi,     // Notif absensi
  lainnya,     // Tipe lainnya
}

// ─── NotificationModel ─────────────────────────────────────────────────────
class NotificationModel {
  final String id;
  final String judul;
  final String deskripsi;
  final NotificationType tipe;
  final String pengirim;
  final String pengirimEmail;
  final DateTime timestamp;
  final bool sudahDibaca;
  final String? idPengumuman; // Referensi ke pengumuman jika dari pengumuman

  NotificationModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.tipe,
    required this.pengirim,
    required this.pengirimEmail,
    required this.timestamp,
    this.sudahDibaca = false,
    this.idPengumuman,
  });

  // Konversi dari Map (Firestore)
  factory NotificationModel.fromMap(Map<String, dynamic> map, String docId) {
    return NotificationModel(
      id: docId,
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      tipe: _stringToNotificationType(map['tipe'] ?? 'pengumuman'),
      pengirim: map['pengirim'] ?? 'Owner',
      pengirimEmail: map['pengirimEmail'] ?? '',
      timestamp: (map['timestamp'] != null) 
        ? _firestoreTimestampToDateTime(map['timestamp'])
        : DateTime.now(),
      sudahDibaca: map['sudahDibaca'] ?? false,
      idPengumuman: map['idPengumuman'],
    );
  }

  // Konversi ke Map (untuk Firestore)
  Map<String, dynamic> toMap() {
    return {
      'judul': judul,
      'deskripsi': deskripsi,
      'tipe': _notificationTypeToString(tipe),
      'pengirim': pengirim,
      'pengirimEmail': pengirimEmail,
      'timestamp': timestamp,
      'sudahDibaca': sudahDibaca,
      'idPengumuman': idPengumuman,
    };
  }

  // Copy with untuk update status dibaca
  NotificationModel copyWith({
    bool? sudahDibaca,
  }) {
    return NotificationModel(
      id: id,
      judul: judul,
      deskripsi: deskripsi,
      tipe: tipe,
      pengirim: pengirim,
      pengirimEmail: pengirimEmail,
      timestamp: timestamp,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      idPengumuman: idPengumuman,
    );
  }
}

// Helper functions untuk konversi enum dan timestamp
NotificationType _stringToNotificationType(String value) {
  switch (value.toLowerCase()) {
    case 'pengumuman':
      return NotificationType.pengumuman;
    case 'jadwal':
      return NotificationType.jadwal;
    case 'absensi':
      return NotificationType.absensi;
    default:
      return NotificationType.lainnya;
  }
}

String _notificationTypeToString(NotificationType type) {
  return type.toString().split('.').last;
}

DateTime _firestoreTimestampToDateTime(dynamic timestamp) {
  if (timestamp == null) return DateTime.now();
  if (timestamp is DateTime) return timestamp;
  // Handle Firestore Timestamp - assume it has toDate() method
  if (timestamp is Map && timestamp.containsKey('_seconds')) {
    final seconds = timestamp['_seconds'] as int;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
  try {
    return (timestamp as dynamic).toDate();
  } catch (_) {
    return DateTime.now();
  }
}

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
