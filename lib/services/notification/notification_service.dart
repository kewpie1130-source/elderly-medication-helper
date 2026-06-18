import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz; 
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart'; // 👈 🔥 終極關鍵修正：引入原生時區獲取工具

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初始化本地定時通知服務 (100% 符合官方架構，絕無時差未爆彈)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. 載入全球時區資料庫，防止 tz.local 造成實機閃退
      tz.initializeTimeZones();
      
      // 🔥 2. 核心修正：實打實獲取長者手機當前的「系統本地時區」（例如：Asia/Taipei）
      // 這能保證 tz.local 抓到的時間和長者手錶上的時間 100% 一致，不會產生 8 小時時差！
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
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
      
      // 主動向長者請求 Android 13+ 的通知權限
      await requestPermissions();
      
      debugPrint("本地通知服務基礎初始化成功 (v18.0.0 + 台灣/本地時區已精準對齊)");
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

  /// 完美位置參數排程方法，100% 兼容呼叫端
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
      channelDescription: '專門用於長者定時用藥提醒的高優先度通知渠道',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    // 根據畫面 6 的重複頻率選擇，計算重複週期組件
    DateTimeComponents? matchComponents;
    if (isDaily) {
      matchComponents = DateTimeComponents.time; 
    } else if (isWeekly) {
      matchComponents = DateTimeComponents.dayOfWeekAndTime; 
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