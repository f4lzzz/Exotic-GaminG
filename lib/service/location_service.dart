import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const double storeLat = -7.603615;
  static const double storeLng = 111.900544;
  static const double radiusMeter = 50; // radius 50 meter dari toko
  static const String storeName = 'Exotic Gaming & Cafe Nganjuk';
  static const String storeAddress = 'Jl. Ahmad Yani No.16, Kauman, Nganjuk';

  static Future<Position?> getPosition() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return null;
    }
    if (perm == LocationPermission.deniedForever) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } on TimeoutException {
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

  static bool isInside(double lat, double lng) =>
      distanceTo(lat, lng) <= radiusMeter;

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
