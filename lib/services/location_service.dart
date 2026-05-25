import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // ✅ Koordinat asli Exotic Gaming & Cafe Nganjuk
  static const double storeLat = -7.6036163;
  static const double storeLng = 111.900546;
  static const double radiusMeter = 20; // radius 100 meter dari toko
  static const String storeName = 'Exotic Gaming & Cafe Nganjuk';
  static const String storeAddress = 'Nganjuk, Jawa Timur';

  static Future<Position?> getPosition() async {
    // Cek GPS aktif
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    // Cek & minta permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    try {
      // Coba akurasi tinggi dulu, timeout 10 detik
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
      // GPS lambat? fallback ke akurasi rendah
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.lowest,
          timeLimit: const Duration(seconds: 5),
        );
      } catch (_) {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  // Cek apakah user dalam radius toko
  static bool isInside(double lat, double lng) =>
      distanceTo(lat, lng) <= radiusMeter;

  // Hitung jarak dari user ke toko (meter)
  static double distanceTo(double lat, double lng) {
    const R = 6371000.0;
    final dLat = _r(storeLat - lat);
    final dLng = _r(storeLng - lng);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_r(lat)) * cos(_r(storeLat)) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static double _r(double d) => d * pi / 180;
}
