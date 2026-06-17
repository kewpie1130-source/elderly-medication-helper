import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // 單例模式 (Singleton)，確保全 App 只有一個通知實體在管理定時排程
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  /// 初始化本地定時通知服務 (完全符合 v18.0.0 規範)
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Android 初始化設定：使用專案預設的 App 圖標
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // 2. iOS / macOS (Darwin) 初始化設定
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 3. 核心初始化 (v18.0.0 規定：停用舊版 onSelectNotification，全面改用 onDidReceiveNotificationResponse)
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint("長者點擊了本地服藥通知，Payload: ${response.payload}");
          // 這裡未來可以聯動跳轉到特定的 UI 頁面
        },
      );

      _isInitialized = true;
      debugPrint("本地通知服務基礎初始化成功 (v18.0.0)");
    } catch (e) {
      debugPrint("本地通知服務初始化失敗: $e");
    }
  }

  /// 長者定時用藥提醒排程方法 (核心修正：完全符合 v18.0.0 參數異動)
  /// [id] 通知的唯一識別碼（不可重複，否則會覆蓋舊通知）
  /// [title] 通知大標題（例如：阿公，吃藥時間到囉！）
  /// [body] 通知內容細節（例如：請服用：降血壓藥 1 顆）
  /// [scheduledDate] 預計要發出通知的精準時間點 (Timezone 本地時間)
  Future<void> zonedSchedule(
    int id,
    String title,
    String body,
    tz.TZDateTime scheduledDate,
  ) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 設定 Android 通知的渠道與重要性 (長者專用：最高音量與彈出提示)
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

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        
        // ❌ androidAllowWhileIdle: true,  <-- 這一行在 v18.0.0 已經被官方刪除，留著編譯必報錯！
        // ✅ 修正：改用 v18.0.0 強制要求的全新必填列舉參數
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
      );
      debugPrint("成功排定用藥通知！ID: $id, 時間: $scheduledDate");
    } catch (e) {
      debugPrint("定時排程通知失敗: $e");
    }
  }

  /// 取消特定的通知排程 (防呆用，長者按了「我已吃藥」，就把今天後續的重複提醒關掉)
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