import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/config/app_config.dart';

/// طلبات رحلات بالاشتراك — مسار [AppConfig.riderSubscriptionRequestsPath].
class RiderSubscriptionService {
  RiderSubscriptionService._();

  static Future<void> submitStructured({
    required String fullName,
    required String phone,
    required String pickupAddress,
    required String dropoffAddress,
    required bool hasWaitTime,
    required int daysPerWeek,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('not_signed_in');
    }
    if (daysPerWeek < 1 || daysPerWeek > 7) {
      throw ArgumentError('daysPerWeek');
    }
    final ref = FirebaseDatabase.instance
        .ref()
        .child(AppConfig.riderSubscriptionRequestsPath)
        .push();
    await ref.set({
      'userID': uid,
      'fullName': fullName.trim(),
      'phone': phone.trim(),
      'pickupAddress': pickupAddress.trim(),
      'dropoffAddress': dropoffAddress.trim(),
      'hasWaitTime': hasWaitTime,
      'daysPerWeek': daysPerWeek,
      'schemaVersion': 2,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
