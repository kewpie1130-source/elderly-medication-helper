class DoseSession {

  final String sessionId; // e.g., session_20260609_morning

  final String userId;

  final String slotId; // e.g., slot_morning

  final String slotName; // e.g., 早上

  final String scheduledTime; // e.g., 08:00

  final String date; // e.g., 2026-06-09

  final List<String> itemIds; // 這個時段該吃的所有藥品 ID 清單

  final String status; // pending, completed

  final DateTime? completedAt;

  final bool locked; // 鎖定狀態（防止重複服用）

  final bool reminderTriggered;

  final bool caregiverNotified;



  DoseSession({

    required this.sessionId,

    required this.userId,

    required this.slotId,

    required this.slotName,

    required this.scheduledTime,

    required this.date,

    required this.itemIds,

    required this.status,

    this.completedAt,

    required this.locked,

    required this.reminderTriggered,

    required this.caregiverNotified,

  });



  factory DoseSession.fromJson(Map<String, dynamic> json) {

    return DoseSession(

      sessionId: json['sessionId'] ?? '',

      userId: json['userId'] ?? '',

      slotId: json['slotId'] ?? '',

      slotName: json['slotName'] ?? '',

      scheduledTime: json['scheduledTime'] ?? '',

      date: json['date'] ?? '',

      itemIds: List<String>.from(json['itemIds'] ?? []),

      status: json['status'] ?? 'pending',

      completedAt: json['completedAt'] != null

          ? DateTime.parse(json['completedAt'])

          : null,

      locked: json['locked'] ?? false,

      reminderTriggered: json['reminderTriggered'] ?? false,

      caregiverNotified: json['caregiverNotified'] ?? false,

    );

  }



  Map<String, dynamic> toJson() {

    return {

      'sessionId': sessionId,

      'userId': userId,

      'slotId': slotId,

      'slotName': slotName,

      'scheduledTime': scheduledTime,

      'date': date,

      'itemIds': itemIds,

      'status': status,

      'completedAt': completedAt?.toIso8601String(),

      'locked': locked,

      'reminderTriggered': reminderTriggered,

      'caregiverNotified': caregiverNotified,

    };

  }

} 

