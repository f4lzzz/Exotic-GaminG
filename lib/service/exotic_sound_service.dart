// lib/services/exotic_sound_service.dart
//
// Service untuk memainkan suara "EXOTIC" saat ada notifikasi.
// Pakai package: audioplayers
//
// Tambahkan di pubspec.yaml:
//   audioplayers: ^6.0.0
//
// Taruh file exotic_notif.mp3 di:
//   assets/sounds/exotic_notif.mp3
//
// Tambahkan di pubspec.yaml bagian flutter:
//   flutter:
//     assets:
//       - assets/sounds/exotic_notif.mp3

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class ExoticSoundService {
  static final ExoticSoundService _instance = ExoticSoundService._internal();
  factory ExoticSoundService() => _instance;
  ExoticSoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  /// Mainkan suara EXOTIC
  /// Dipanggil setiap kali ada notifikasi masuk
  Future<void> playNotif() async {
    if (_isPlaying) return; // Hindari overlap
    try {
      _isPlaying = true;
      await _player.setVolume(1.0);
      await _player.play(AssetSource('sounds/exotic_notif.mp3'));
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
      debugPrint('❌ Error play suara EXOTIC: $e');
    }
  }

  /// Stop suara
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  /// Dispose
  void dispose() {
    _player.dispose();
  }
}