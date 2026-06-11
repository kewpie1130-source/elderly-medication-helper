class DoseItemLog {
  final String logId;
  final String sessionId;
  final String itemId;
  String status;
  DateTime? takenAt;

  DoseItemLog({
    required this.logId,
    required this.sessionId,
    required this.itemId,
    this.status = 'pending',
    this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'sessionId': sessionId,
      'itemId': itemId,
      'status': status,
      'takenAt': takenAt?.toIso8601String(),
    };
  }

  factory DoseItemLog.fromMap(Map<String, dynamic> map) {
    return DoseItemLog(
      logId: map['logId'] ?? '',
      sessionId: map['sessionId'] ?? '',
      itemId: map['itemId'] ?? '',
      status: map['status'] ?? 'pending',
      takenAt: map['takenAt'] != null ? DateTime.parse(map['takenAt']) : null,
    );
  }
}
