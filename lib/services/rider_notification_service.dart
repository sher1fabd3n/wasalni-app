import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// إشعارات محلية للراكب (وصول السائق، إلخ) دون الحاجة لخادم FCM.
class RiderNotificationService {
  RiderNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'trip_updates',
    'تحديثات الرحلة',
    description: 'إشعارات حالة السائق والرحلة',
    importance: Importance.high,
  );

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    _initialized = true;
  }

  static Future<void> showDriverArrived({
    required String title,
    required String body,
  }) async {
    if (!_initialized) await init();

    await _plugin.show(
      91001,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
