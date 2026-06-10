class DoseItemLog {
  final String logId;
  final String sessionId;
  final String itemId;
  final String status; // taken, missed
  final DateTime? takenAt;

  DoseItemLog({
    required this.logId,
    required this.sessionId,
    required this.itemId,
    required this.status,
    this.takenAt,
  });

  factory DoseItemLog.fromJson(Map<String, dynamic> json) {
    return DoseItemLog(
      logId: json['logId'] ?? '',
      sessionId: json['sessionId'] ?? '',
      itemId: json['itemId'] ?? '',
      status: json['status'] ?? 'pending',
      takenAt: json['takenAt'] != null
          ? DateTime.parse(json['takenAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'sessionId': sessionId,
      'itemId': itemId,
      'status': status,
      'takenAt': takenAt?.toIso8601String(),
    };
  }
}