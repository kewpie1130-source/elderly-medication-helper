class TakenRecord {
  final int? id;
  final int medicineId;
  final String medicineName;
  final String period;
  final String takenAt;
  final String date;

  const TakenRecord({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.period,
    required this.takenAt,
    required this.date,
  });

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'medicineId': medicineId,
      'medicineName': medicineName,
      'period': period,
      'takenAt': takenAt,
      'date': date,
    };
  }

  factory TakenRecord.fromMap(Map<String, Object?> map) {
    return TakenRecord(
      id: map['id'] as int?,
      medicineId: map['medicineId'] as int? ?? 0,
      medicineName: map['medicineName'] as String? ?? '',
      period: map['period'] as String? ?? '',
      takenAt: map['takenAt'] as String? ?? '',
      date: map['date'] as String? ?? '',
    );
  }
}
