import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz; 
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初始化本地定時通知服務 (100% 對齊 v18 具名參數)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Taipei')); // 鎖定台灣台北時區
      
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 對齊 v18 API：InitializationSettings 是第一個位置參數。
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("長者點擊了本地服藥通知，Payload: ${response.payload}");
        },
      );

      _isInitialized = true;
      await requestPermissions();
      debugPrint("本地通知服務基礎初始化成功 (v18.0.0 + 台北時區已就緒)");
    } catch (e) {
      debugPrint("本地通知服務初始化失敗: $e");
    }
  }

  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// 🎯 對外依舊維持「位置參數」設計，100% 完美相容你的 reminder_page.dart 呼叫端
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate, {
    bool isDaily = false,   
    bool isWeekly = false,  
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'elderly_medication_channel_id',
      '長者服藥提醒渠道',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    DateTimeComponents? matchComponents;
    if (isDaily) matchComponents = DateTimeComponents.time; 
    if (isWeekly) matchComponents = DateTimeComponents.dayOfWeekAndTime; 

    try {
      // 對齊 v18 API：前五個必要參數為位置參數。
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchComponents, 
      );
      debugPrint("成功排定用藥通知！ID: $id, 時間: $scheduledDate");
    } catch (e) {
      debugPrint("定時排程通知失敗: $e");
    }
  }

  /// 取消特定的通知排程
  Future<void> cancel(int id) async {
    try {
      // 對齊 v18 API：id 是第一個位置參數。
      await _notificationsPlugin.cancel(id);
      debugPrint("已成功取消 ID: $id 的通知排程");
    } catch (e) {
      debugPrint("取消通知排程失敗: $e");
    }
  }

  /// 一鍵取消全 App 所有通知排程
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
      debugPrint("已成功取消全 App 所有本地通知排程");
    } catch (e) {
      debugPrint("取消所有通知排程失敗: $e");
    }
  }
}
