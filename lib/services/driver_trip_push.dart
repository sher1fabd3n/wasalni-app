import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:users_app/config/app_config.dart';

/// إشعار السائق عبر FCM (Legacy HTTP API) — **اختياري**.
/// لو مفيش Legacy Server Key في المشروع، الإرسال يُتخطّى بصمت؛ السائق يستقبل
/// تنبيهًا محليًا من تطبيق السواق عند تحديث [newTripStatus] في نفس الـ DB.
/// عند الحاجة للتنبيه والتطبيق **مقفول تمامًا** استخدم لاحقًا Cloud Functions (غالبًا ضمن الخطة المجانية) مع FCM v1.
class DriverTripPush {
  DriverTripPush._();

  static const _fcmUrl = 'https://fcm.googleapis.com/fcm/send';

  static Future<void> sendNewTripAlert({
    required String driverUid,
    required String tripId,
  }) async {
    final key = AppConfig.serverKeyFCM.trim();
    if (key.isEmpty || key == 'paste your key here') {
      return;
    }

    final tokenSnap = await FirebaseDatabase.instance
        .ref()
        .child(AppConfig.driversPath)
        .child(driverUid)
        .child('deviceToken')
        .get();

    final token = tokenSnap.value?.toString().trim() ?? '';
    if (token.isEmpty) {
      return;
    }

    final payload = jsonEncode(<String, dynamic>{
      'to': token,
      'priority': 'high',
      'content_available': true,
      'data': <String, String>{
        'tripID': tripId,
      },
      'notification': <String, String>{
        'title': 'طلب رحلة جديد',
        'body': 'اضغط لفتح تفاصيل الطلب',
      },
    });

    try {
      final res = await http
          .post(
            Uri.parse(_fcmUrl),
            headers: <String, String>{
              'Content-Type': 'application/json',
              'Authorization': 'key=$key',
            },
            body: payload,
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        try {
          final map = jsonDecode(res.body);
          if (map is Map && map['failure'] == 1) {
            if (kDebugMode) {
              debugPrint('DriverTripPush: FCM failure — ${res.body}');
            }
          }
        } catch (_) {}
        return;
      }

      if (kDebugMode) {
        debugPrint(
          'DriverTripPush: HTTP ${res.statusCode} — ${res.body}',
        );
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('DriverTripPush: $e\n$st');
      }
    }
  }
}
