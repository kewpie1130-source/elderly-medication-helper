import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初始化通知設定
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // 初始化時區資料
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Taipei'));

    // Android 圖示設定
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 權限與彈窗設定
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // android: 和 iOS: 的新版具名參數
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 加上 settings: 標籤
    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  /// 點擊通知後的行為
  void _onNotificationTap(NotificationResponse response) {
    // 這裡未來可以透過路由引導長者直接進入「打卡服藥」頁面
  }

  /// 設定每日定時鬧鐘
  Future<void> scheduleDailyReminder({
    required String reminderId,
    required String medicineName,
    required String timeString,
  }) async {
    if (!_isInitialized) await initNotification();

    final List<String> parts = timeString.split(':');
    final int hour = int.parse(parts[0]);
    final int minute = int.parse(parts[1]);

    final int notificationId = reminderId.hashCode;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'elderly_medicine_channel_id',
      '長者智慧用藥提醒',
      channelDescription: '此頻道用於每日定時提醒長者服用藥物',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    // 依據最新官方規格，全部加上具名標籤
    await _notificationsPlugin.zonedSchedule(
      id: notificationId,
      title: '💊 吃藥時間到囉！',
      body: '阿公/阿嬤，請記得服用【$medicineName】，健康最重要！',
      scheduledDate: scheduledDate,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: jsonEncode({'medicineName': medicineName, 'reminderId': reminderId}),
    );
  }

  /// 取消特定的鬧鐘
  Future<void> cancelReminder(String reminderId) async {
    final int notificationId = reminderId.hashCode;
    await _notificationsPlugin.cancel(id: notificationId);
  }

  /// ✨【已完美修復括號結構】確保 return 絕對不漏空
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    } // <-- if 在這裡關閉
    
    return scheduledDate; // 💡 放在最外層，保證一定會 return 成功！
  }
}