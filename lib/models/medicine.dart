class Medicine {
  final int? id;
  final String patientName;
  final String clinicName;
  final String medicineName;
  final String dosage;
  final String frequency;
  final String timingText;
  final bool morning;
  final bool noon;
  final bool evening;
  final bool beforeSleep;
  final bool beforeMeal;
  final bool afterMeal;
  final String startDate;
  final String endDate;
  final String notes;
  final String imagePath;
  final String ocrText;
  final String createdAt;

  const Medicine({
    this.id,
    this.patientName = '',
    this.clinicName = '',
    this.medicineName = '',
    this.dosage = '',
    this.frequency = '',
    this.timingText = '',
    this.morning = false,
    this.noon = false,
    this.evening = false,
    this.beforeSleep = false,
    this.beforeMeal = false,
    this.afterMeal = false,
    this.startDate = '',
    this.endDate = '',
    this.notes = '',
    this.imagePath = '',
    this.ocrText = '',
    this.createdAt = '',
  });

  Medicine copyWith({
    int? id,
    String? patientName,
    String? clinicName,
    String? medicineName,
    String? dosage,
    String? frequency,
    String? timingText,
    bool? morning,
    bool? noon,
    bool? evening,
    bool? beforeSleep,
    bool? beforeMeal,
    bool? afterMeal,
    String? startDate,
    String? endDate,
    String? notes,
    String? imagePath,
    String? ocrText,
    String? createdAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      patientName: patientName ?? this.patientName,
      clinicName: clinicName ?? this.clinicName,
      medicineName: medicineName ?? this.medicineName,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timingText: timingText ?? this.timingText,
      morning: morning ?? this.morning,
      noon: noon ?? this.noon,
      evening: evening ?? this.evening,
      beforeSleep: beforeSleep ?? this.beforeSleep,
      beforeMeal: beforeMeal ?? this.beforeMeal,
      afterMeal: afterMeal ?? this.afterMeal,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      ocrText: ocrText ?? this.ocrText,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'patientName': patientName,
      'clinicName': clinicName,
      'medicineName': medicineName,
      'dosage': dosage,
      'frequency': frequency,
      'timingText': timingText,
      'morning': morning ? 1 : 0,
      'noon': noon ? 1 : 0,
      'evening': evening ? 1 : 0,
      'beforeSleep': beforeSleep ? 1 : 0,
      'beforeMeal': beforeMeal ? 1 : 0,
      'afterMeal': afterMeal ? 1 : 0,
      'startDate': startDate,
      'endDate': endDate,
      'notes': notes,
      'imagePath': imagePath,
      'ocrText': ocrText,
      'createdAt': createdAt,
    };
  }

  factory Medicine.fromMap(Map<String, Object?> map) {
    return Medicine(
      id: map['id'] as int?,
      patientName: map['patientName'] as String? ?? '',
      clinicName: map['clinicName'] as String? ?? '',
      medicineName: map['medicineName'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      timingText: map['timingText'] as String? ?? '',
      morning: (map['morning'] as int? ?? 0) == 1,
      noon: (map['noon'] as int? ?? 0) == 1,
      evening: (map['evening'] as int? ?? 0) == 1,
      beforeSleep: (map['beforeSleep'] as int? ?? 0) == 1,
      beforeMeal: (map['beforeMeal'] as int? ?? 0) == 1,
      afterMeal: (map['afterMeal'] as int? ?? 0) == 1,
      startDate: map['startDate'] as String? ?? '',
      endDate: map['endDate'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      ocrText: map['ocrText'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}
