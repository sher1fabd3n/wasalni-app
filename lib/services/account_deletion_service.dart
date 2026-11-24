import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:users_app/config/app_config.dart';

/// حذف بيانات الراكب من Realtime Database وStorage ثم حذف حساب [FirebaseAuth].
/// يُفترض استدعاء [reauthenticateIfNeeded] قبل [deleteAuthUser] بعد تنظيف الخادم.
class AccountDeletionService {
  AccountDeletionService._();

  /// إزالة كل العقد التي يكون فيها الحقل `userID` يساوي [uid] تحت [baseRef]،
  /// وحذف ملف تعريف المستخدم. يُفضّل ضبط `.indexOn: ["userID"]` في قواعد RTDB
  /// لمسارات `tripRequests` و`riderTripRatings` و`riderGeneralFeedback` و`riderSubscriptionRequests` لتسريع الاستعلام.
  static Future<void> deleteUserRealtimeData(String uid) async {
    final db = FirebaseDatabase.instance;
    await _removeChildrenWhereUserIdEquals(
      db.ref().child(AppConfig.tripRequestsPath),
      uid,
    );
    await _removeChildrenWhereUserIdEquals(
      db.ref().child(AppConfig.riderTripRatingsPath),
      uid,
    );
    await _removeChildrenWhereUserIdEquals(
      db.ref().child(AppConfig.riderGeneralFeedbackPath),
      uid,
    );
    await _removeChildrenWhereUserIdEquals(
      db.ref().child(AppConfig.riderSubscriptionRequestsPath),
      uid,
    );
    await db.ref().child(AppConfig.usersPath).child(uid).remove();
  }

  /// حذف ملفات Storage تحت `users/{uid}/` إن وُجدت (لا يُستخدم التخزين حالياً في المشروع، لكن يبقى احتياطاً).
  static Future<void> deleteUserStorageFiles(String uid) async {
    try {
      final root = FirebaseStorage.instance.ref().child('users').child(uid);
      await _deleteStorageRecursive(root);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('AccountDeletionService.deleteUserStorageFiles: $e\n$st');
      }
    }
  }

  static Future<void> _deleteStorageRecursive(Reference ref) async {
    final list = await ref.listAll();
    for (final item in list.items) {
      try {
        await item.delete();
      } catch (e) {
        if (kDebugMode) debugPrint('delete file: $e');
      }
    }
    for (final prefix in list.prefixes) {
      await _deleteStorageRecursive(prefix);
    }
  }

  static Future<void> _removeChildrenWhereUserIdEquals(
    DatabaseReference baseRef,
    String uid,
  ) async {
    DataSnapshot snap;
    var usedEqualTo = true;
    try {
      snap = await baseRef.orderByChild('userID').equalTo(uid).get();
    } catch (e) {
      if (kDebugMode) {
        debugPrint(
          'AccountDeletionService: orderBy userID fallback to full scan ($baseRef): $e',
        );
      }
      usedEqualTo = false;
      snap = await baseRef.get();
    }

    if (!snap.exists || snap.value == null) return;
    final raw = snap.value;
    if (raw is! Map) return;

    final toRemove = <String, Object?>{};
    for (final entry in raw.entries) {
      final key = entry.key.toString();
      final val = entry.value;
      if (usedEqualTo) {
        toRemove[key] = null;
      } else {
        if (val is Map && val['userID']?.toString() == uid) {
          toRemove[key] = null;
        }
      }
    }
    if (toRemove.isEmpty) return;
    await baseRef.update(toRemove);
  }

  static Future<void> reauthenticateWithPassword(String password) async {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      throw StateError('no_email_user');
    }
    final cred =
        EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(cred);
  }

  static Future<void> deleteAuthUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('not_signed_in');
    }
    await user.delete();
  }
}
