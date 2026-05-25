// lib/models/log_entry.dart

import 'package:intl/intl.dart';

enum LogType {
  tambah,
  kurang,
  hapus,
  baru,
}

class LogEntry {
  final String message;
  final LogType type;
  final DateTime time;

  LogEntry({
    required this.message,
    required this.type,
    required this.time,
  });

  String get timeStr {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';

    return DateFormat('dd/MM/yy HH:mm', 'id_ID').format(time);
  }

  String get timeHour {
    return DateFormat('HH:mm', 'id_ID').format(time);
  }
}
