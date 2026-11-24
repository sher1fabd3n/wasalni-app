import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/config/app_config.dart';

/// يحوّل «بريد أو هاتف» إلى بريد إلكتروني لـ Firebase Auth (email/password).
class UserLoginLookupService {
  UserLoginLookupService._();

  /// يُطبَّق على أرقام مصر: 010… / +2010… / 2010…
  static String normalizePhone(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return '';

    if (digits.startsWith('20') && digits.length >= 12) {
      return '0${digits.substring(2)}';
    }
    if (digits.startsWith('0') && digits.length >= 10) {
      return digits;
    }
    if (digits.length == 10 && digits.startsWith('1')) {
      return '0$digits';
    }
    return digits;
  }

  static bool looksLikePhone(String input) {
    if (input.trim().contains('@')) return false;
    final digits = input.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7;
  }

  static bool looksLikeEmail(String input) {
    final t = input.trim();
    return t.contains('@') && t.length >= 5;
  }

  static bool isValidLoginIdentifier(String input) {
    return looksLikeEmail(input) || looksLikePhone(input);
  }

  /// يُخزَّن عند التسجيل/التحديث لربط الهاتف بالحساب.
  static Future<void> indexPhoneForUser({
    required String phone,
    required String email,
    required String uid,
  }) async {
    final normalized = normalizePhone(phone);
    if (normalized.length < 7) return;
    final cleanEmail = email.trim().toLowerCase();
    if (!cleanEmail.contains('@')) return;

    await FirebaseDatabase.instance
        .ref()
        .child(AppConfig.usersByPhonePath)
        .child(normalized)
        .set({
      'email': cleanEmail,
      'uid': uid,
    });
  }

  /// يعيد البريد المرتبط بالهاتف، أو null إن لم يُوجد حساب.
  static Future<String?> resolveEmailForLogin(String emailOrPhone) async {
    final trimmed = emailOrPhone.trim();
    if (looksLikeEmail(trimmed)) {
      return trimmed.toLowerCase();
    }
    if (!looksLikePhone(trimmed)) return null;

    final normalized = normalizePhone(trimmed);

    final fromIndex = await FirebaseDatabase.instance
        .ref()
        .child(AppConfig.usersByPhonePath)
        .child(normalized)
        .get();
    if (fromIndex.exists && fromIndex.value is Map) {
      final map = Map<String, dynamic>.from(fromIndex.value as Map);
      final email = map['email']?.toString().trim().toLowerCase();
      if (email != null && email.contains('@')) return email;
    }

    try {
      final byStoredPhone = await FirebaseDatabase.instance
          .ref()
          .child(AppConfig.usersPath)
          .orderByChild('phone')
          .equalTo(normalized)
          .limitToFirst(1)
          .get();
      final email = _emailFromSnapshot(byStoredPhone);
      if (email != null) return email;
    } catch (_) {}

    if (trimmed != normalized) {
      try {
        final byRawPhone = await FirebaseDatabase.instance
            .ref()
            .child(AppConfig.usersPath)
            .orderByChild('phone')
            .equalTo(trimmed)
            .limitToFirst(1)
            .get();
        final email = _emailFromSnapshot(byRawPhone);
        if (email != null) return email;
      } catch (_) {}
    }

    final allUsers =
        await FirebaseDatabase.instance.ref(AppConfig.usersPath).get();
    if (!allUsers.exists) return null;

    for (final child in allUsers.children) {
      final phone = child.child('phone').value?.toString() ?? '';
      if (normalizePhone(phone) == normalized) {
        final email = child.child('email').value?.toString().trim().toLowerCase();
        if (email != null && email.contains('@')) return email;
      }
    }
    return null;
  }

  static String? _emailFromSnapshot(DataSnapshot snap) {
    if (!snap.exists) return null;
    for (final child in snap.children) {
      final email = child.child('email').value?.toString().trim().toLowerCase();
      if (email != null && email.contains('@')) return email;
    }
    return null;
  }
}
