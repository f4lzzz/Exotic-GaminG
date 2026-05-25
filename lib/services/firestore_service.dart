import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── Simpan embedding wajah ───────────────────────────────────────────────
  Future<bool> saveEmbedding({
    required String uid,
    required List<double> embedding,
  }) async {
    try {
      await _db.collection('karyawan').doc(uid).set(
        {
          'faceEmbedding': embedding,
          'faceRegisteredAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true), // ✅ merge supaya tidak overwrite data lain
      );
      return true;
    } catch (e) {
      print('❌ Gagal simpan embedding: $e');
      return false;
    }
  }

  // ─── Ambil embedding wajah ────────────────────────────────────────────────
  Future<List<double>?> getEmbedding(String uid) async {
    try {
      final doc = await _db.collection('karyawan').doc(uid).get();
      if (!doc.exists) return null;
      final raw = doc.data()?['faceEmbedding'];
      if (raw == null) return null;
      return List<double>.from((raw as List).map((e) => (e as num).toDouble()));
    } catch (e) {
      print('❌ Gagal ambil embedding: $e');
      return null;
    }
  }

  // ─── Cek wajah sudah terdaftar ────────────────────────────────────────────
  Future<bool> isFaceRegistered(String uid) async {
    try {
      final doc = await _db.collection('karyawan').doc(uid).get();
      if (!doc.exists) return false;
      return doc.data()?['faceEmbedding'] != null;
    } catch (_) {
      return false;
    }
  }

  // ─── Ambil semua karyawan ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllKaryawan() async {
    try {
      final snapshot = await _db
          .collection('karyawan')
          .where('faceEmbedding', isNull: false)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['uid'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Gagal ambil karyawan: $e');
      return [];
    }
  }

  // ─── Simpan absensi ───────────────────────────────────────────────────────
  Future<bool> saveAbsensi({
    required String uid,
    required String type, // 'masuk' atau 'pulang'
    required String jam,
    double? lat,
    double? lng,
  }) async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _db
          .collection('karyawan')
          .doc(uid)
          .collection('absensi')
          .doc(dateStr)
          .set({
        type: {
          'jam': jam,
          'lat': lat,
          'lng': lng,
          'timestamp': FieldValue.serverTimestamp(),
        }
      }, SetOptions(merge: true));
      return true;
    } catch (e) {
      print('❌ Gagal simpan absensi: $e');
      return false;
    }
  }

  // ─── Ambil data karyawan by UID ───────────────────────────────────────────
  Future<Map<String, dynamic>?> getKaryawan(String uid) async {
    try {
      final doc = await _db.collection('karyawan').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['uid'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Gagal ambil karyawan: $e');
      return null;
    }
  }

  // ─── Ambil riwayat absensi ────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAbsensi(String uid) async {
    try {
      final snapshot = await _db
          .collection('karyawan')
          .doc(uid)
          .collection('absensi')
          .orderBy(FieldPath.documentId, descending: true)
          .limit(30)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['tanggal'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('❌ Gagal ambil absensi: $e');
      return [];
    }
  }

  // ─── Ambil absensi hari ini ───────────────────────────────────────────────
  Future<Map<String, dynamic>?> getAbsensiHariIni(String uid) async {
    try {
      final today = DateTime.now();
      final dateStr =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final doc = await _db
          .collection('karyawan')
          .doc(uid)
          .collection('absensi')
          .doc(dateStr)
          .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('❌ Gagal ambil absensi hari ini: $e');
      return null;
    }
  }
}
