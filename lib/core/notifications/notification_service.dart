import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const _androidDetails = AndroidNotificationDetails(
  'driver_finance',
  'Driver Finance',
  channelDescription: 'Alertas de manutenção e metas do Driver Finance',
  importance: Importance.high,
  priority: Priority.high,
);

const _darwinDetails = DarwinNotificationDetails();

const _notifDetails = NotificationDetails(
  android: _androidDetails,
  iOS: _darwinDetails,
  macOS: _darwinDetails,
);

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(id, title, body, _notifDetails);
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
