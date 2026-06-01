import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ─── Simpan embedding wajah ───────────────────────────────────────────────
  Future<bool> saveEmbedding({
    required String uid,
    required List<double> embedding,
    String? nama, // ← TAMBAHAN: simpan nama pemilik wajah
  }) async {
    try {
      final Map<String, dynamic> data = {
        'faceEmbedding': embedding,
        'faceRegisteredAt': FieldValue.serverTimestamp(),
      };

      // Simpan nama ke karyawan/{uid} jika ada
      if (nama != null && nama.isNotEmpty) {
        data['namaKaryawan'] = nama;
      }

      await _db.collection('karyawan').doc(uid).set(
            data,
            SetOptions(merge: true),
          );

      // Sinkron nama ke users/{uid} juga supaya konsisten
      if (nama != null && nama.isNotEmpty) {
        await _db.collection('users').doc(uid).set(
          {'nama': nama},
          SetOptions(merge: true),
        );
      }

      print('✅ saveEmbedding sukses — uid: $uid, nama: $nama');
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
    required String type,
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

  // ───────────────────────────────────────────────────────────────────────────
  // ─── NOTIFICATION METHODS ──────────────────────────────────────────────────
  // ───────────────────────────────────────────────────────────────────────────

  Future<bool> createNotificationForAllEmployees({
    required String judul,
    required String deskripsi,
    required NotificationType tipe,
    required String pengirim,
    required String pengirimEmail,
    required String idPengumuman,
  }) async {
    try {
      final karyawanSnapshot = await _db.collection('karyawan').get();
      final batch = _db.batch();

      for (var doc in karyawanSnapshot.docs) {
        final karyawanId = doc.id;
        final notifRef = _db
            .collection('karyawan')
            .doc(karyawanId)
            .collection('notifikasi')
            .doc();

        batch.set(notifRef, {
          'judul': judul,
          'deskripsi': deskripsi,
          'tipe': _notificationTypeToString(tipe),
          'pengirim': pengirim,
          'pengirimEmail': pengirimEmail,
          'timestamp': FieldValue.serverTimestamp(),
          'sudahDibaca': false,
          'idPengumuman': idPengumuman,
        });
      }

      await batch.commit();
      print('✅ Notifikasi berhasil dibuat untuk semua karyawan');
      return true;
    } catch (e) {
      print('❌ Gagal buat notifikasi: $e');
      return false;
    }
  }

  Stream<List<NotificationModel>> getNotificationsStream(String uid) {
    try {
      return _db
          .collection('karyawan')
          .doc(uid)
          .collection('notifikasi')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList();
      });
    } catch (e) {
      print('❌ Error listening notifikasi: $e');
      return Stream.value([]);
    }
  }

  Future<List<NotificationModel>> getNotifications(String uid) async {
    try {
      final snapshot = await _db
          .collection('karyawan')
          .doc(uid)
          .collection('notifikasi')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ Gagal ambil notifikasi: $e');
      return [];
    }
  }

  Future<bool> markNotificationAsRead(String uid, String notifId) async {
    try {
      await _db
          .collection('karyawan')
          .doc(uid)
          .collection('notifikasi')
          .doc(notifId)
          .update({'sudahDibaca': true});
      return true;
    } catch (e) {
      print('❌ Gagal update notifikasi: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String uid, String notifId) async {
    try {
      await _db
          .collection('karyawan')
          .doc(uid)
          .collection('notifikasi')
          .doc(notifId)
          .delete();
      return true;
    } catch (e) {
      print('❌ Gagal hapus notifikasi: $e');
      return false;
    }
  }

  Future<bool> deleteAllNotifications(String uid) async {
    try {
      final snapshot = await _db
          .collection('karyawan')
          .doc(uid)
          .collection('notifikasi')
          .get();
      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      return true;
    } catch (e) {
      print('❌ Gagal hapus semua notifikasi: $e');
      return false;
    }
  }

  String _notificationTypeToString(NotificationType type) {
    return type.toString().split('.').last;
  }
}
