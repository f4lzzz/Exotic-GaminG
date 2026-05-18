import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exotic_gaming_and_cafe/notifikasi_owner.dart'; // sesuaikan import

class NotifIcon extends StatelessWidget {
  const NotifIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('pengumuman')
          .where('dibaca', isEqualTo: 0)
          .snapshots(),
      builder: (context, snapshot) {
        int badgeCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          badgeCount = snapshot.data!.docs.length;
        }
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotifikasiOwnerScreen()),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 20),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
