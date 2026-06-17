import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
      
      // 主動向長者請求 Android 13+ 的通知權限，防止被系統自動封鎖
      await requestPermissions();
      
      debugPrint("本地通知服務基礎初始化成功 (v18.0.0)");
    } catch (e) {
      debugPrint("本地通知服務初始化失敗: $e");
    }
  }

  /// 請求權限（針對 Android 13+ 與 iOS）
  Future<void> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  /// 🎯 完美版：位置參數設計，100% 兼容你舊有的 reminder_page.dart 呼叫方式
  /// 同時保留對齊官方設計圖畫面 6 的重複頻率功能
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate, {
    bool isDaily = false,   // 👈 放在最後面當選填具名參數，預設不重複
    bool isWeekly = false,  // 👈 放在最後面當選填具名參數，預設不重複
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'elderly_medication_channel_id',
      '長者服藥提醒渠道',
      channelDescription: '專門用於長者定時用藥提醒的高優先度通知渠道',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    // 根據畫面 6 的選擇，計算重複週期組件
    DateTimeComponents? matchComponents;
    if (isDaily) {
      matchComponents = DateTimeComponents.time; // 每天的這個時間都會響
    } else if (isWeekly) {
      matchComponents = DateTimeComponents.dayOfWeekAndTime; // 每週的這一天這一時間響
    }

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
      debugPrint("成功排定用藥通知！ID: $id, 重複模式: ${matchComponents ?? '單次'}, 時間: $scheduledDate");
    } catch (e) {
      debugPrint("定時排程通知失敗: $e");
    }
  }

  /// 取消特定的通知排程
  Future<void> cancel(int id) async {
    try {
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