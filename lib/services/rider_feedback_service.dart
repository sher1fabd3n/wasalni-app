import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/config/app_config.dart';

/// حفظ تقييم الرحلة والشكاوى/المقترحات في Realtime Database.
class RiderFeedbackService {
  static Future<void> submitTripRating({
    required String tripId,
    required String driverId,
    String? driverName,
    required int driverStars,
    required int serviceStars,
    String? comment,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseDatabase.instance
        .ref()
        .child(AppConfig.riderTripRatingsPath)
        .child(tripId)
        .set({
      'userID': uid,
      'driverID': driverId,
      'driverName': driverName ?? '',
      'driverRating': driverStars,
      'serviceRating': serviceStars,
      'comment': comment ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  /// [type] قيم مقترحة: `complaint` | `suggestion`
  static Future<void> submitGeneralFeedback({
    required String type,
    required String message,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('not_signed_in');
    }

    final ref = FirebaseDatabase.instance
        .ref()
        .child(AppConfig.riderGeneralFeedbackPath)
        .push();

    await ref.set({
      'userID': uid,
      'type': type,
      'message': message.trim(),
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
