class DoseSession {
  final String sessionId;
  final String userId;
  final String slotId;
  final String slotName;
  final String scheduledTime;
  final String date;
  final List<String> itemIds;
  String status;
  DateTime? completedAt;
  bool locked;
  bool reminderTriggered;
  bool caregiverNotified;

  DoseSession({
    required this.sessionId,
    required this.userId,
    required this.slotId,
    required this.slotName,
    required this.scheduledTime,
    required this.date,
    required this.itemIds,
    this.status = 'pending',
    this.completedAt,
    this.locked = false,
    this.reminderTriggered = false,
    this.caregiverNotified = false,
  });

  Map<String, dynamic> toMap() {
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

  factory DoseSession.fromMap(Map<String, dynamic> map) {
    return DoseSession(
      sessionId: map['sessionId'] ?? '',
      userId: map['userId'] ?? '',
      slotId: map['slotId'] ?? '',
      slotName: map['slotName'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      date: map['date'] ?? '',
      itemIds: List<String>.from(map['itemIds'] ?? []),
      status: map['status'] ?? 'pending',
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      locked: map['locked'] ?? false,
      reminderTriggered: map['reminderTriggered'] ?? false,
      caregiverNotified: map['caregiverNotified'] ?? false,
    );
  }
}
