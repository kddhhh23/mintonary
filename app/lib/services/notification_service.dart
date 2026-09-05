import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static int _stringAlarmId(int equipmentId) => 100000 + equipmentId;

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final deviceTimezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(deviceTimezone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    _initialized = await _plugin.initialize(settings: settings) ?? false;
  }

  static Future<bool> requestPermission() async {
    if (!_initialized || kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            true;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return false;
    }
  }

  static Future<void> scheduleStringAlarm({
    required int equipmentId,
    required String racketName,
    required DateTime date,
  }) async {
    if (!_initialized) throw Exception('알림 기능을 초기화하지 못했습니다.');
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      9,
    );
    if (!scheduledDate.isAfter(tz.TZDateTime.now(tz.local))) {
      throw Exception('알림 날짜는 내일부터 선택해 주세요.');
    }
    await _plugin.cancel(id: _stringAlarmId(equipmentId));
    await _plugin.zonedSchedule(
      id: _stringAlarmId(equipmentId),
      title: '스트링 교체 알림',
      body: '$racketName 스트링을 교체할 예정이에요.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'string_replacement',
          '스트링 교체 알림',
          channelDescription: '예약한 날짜에 라켓 스트링 교체를 알려줍니다.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'racket:$equipmentId',
    );
  }

  static Future<void> cancelStringAlarm(int equipmentId) async {
    if (!_initialized) return;
    await _plugin.cancel(id: _stringAlarmId(equipmentId));
  }
}
