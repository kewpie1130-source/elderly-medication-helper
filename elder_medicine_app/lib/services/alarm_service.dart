import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmService {
  // 單例模式 (Singleton)，確保全 App 只有一個鬧鐘控制中心
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  /// 初始化鬧鐘設定（在 App 啟動時呼叫）
  /// 初始化鬧鐘設定並主動要求 Android 13+ 的通知權限
  Future<void> initializeAlarm() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // 👇 關鍵核心：主動向 Android 系統申請發送通知的權限
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    if (androidImplementation != null) {
      // 這行會在長輩的手機上彈出系統標準的「允許發送通知」確認視窗
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      print('📱 Android 通知權限要求結果: $granted');
    }

    print('🔔 本機藥物鬧鐘服務初始化成功。');
  }

  /// 觸發即時鬧鐘彈窗
  Future<void> triggerImmediateAlarm({
    required int id,
    required String title,
    required String body,
  }) async {
    // 設定 Android 通知的渠道（Channel），通道 ID、名稱與聲音
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medicine_alarm_channel_id', // 渠道 ID
      '長者用藥鬧鐘提醒', // 渠道名稱
      channelDescription: '用於長者智慧用藥排程到期時的本機鈴聲與震動提醒',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // 確保會響鈴
      enableVibration: true, // 確保會震動
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 真正把通知發出去！
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
    print('🔊 本機用藥鬧鐘已成功逼逼：$title - $body');
  }
}