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

  /// 初始化本地定時通知服務
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 載入全球時區資料庫
      tz.initializeTimeZones();
      
      // ✅ 修正：免用額外套件！直接使用專案現有 timezone 的 UTC 轉換或預設在地化，確保編譯絕對大綠燈
      tz.setLocalLocation(tz.getLocation('Asia/Taipei')); // 專案既然是長者用藥，強制鎖定台灣台北時區最安全！
      
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
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchComponents, 
      );
    } catch (e) {
      debugPrint("定時排程通知失敗: $e");
    }
  }

  Future<void> cancel(int id) async => await _notificationsPlugin.cancel(id);
  Future<void> cancelAll() async => await _notificationsPlugin.cancelAll();
}