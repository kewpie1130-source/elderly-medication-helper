import 'dart:convert';

// [邱靖喻] 全組統一資料格式
// 需要新增或修改欄位請找邱靖喻，不可自行修改
class MedicineModel {
  final String id;
  final String name;
  final String type;
  final String dosage;
  final String frequency;
  final List<String> timing;
  final String notice;
  final String indication;
  // 適應症：這個藥用於治療什麼症狀
  final String startDate;
  final String endDate;
  final String imagePath;
  final String createdAt;
  final String batchId;

  const MedicineModel({
    required this.id,
    required this.name,
    required this.type,
    required this.dosage,
    required this.frequency,
    required this.timing,
    required this.notice,
    required this.indication,
    required this.startDate,
    required this.endDate,
    required this.imagePath,
    required this.createdAt,
    this.batchId = '',
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      dosage: json['dosage'] as String? ?? '',
      frequency: json['frequency'] as String? ?? '',
      timing: _parseTiming(json['timing']),
      notice: json['notice'] as String? ?? '',
      indication: json['indication'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      imagePath: json['imagePath'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      batchId: json['batchId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'frequency': frequency,
      'timing': timing,
      'notice': notice,
      'indication': indication,
      'startDate': startDate,
      'endDate': endDate,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'batchId': batchId,
    };
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      frequency: map['frequency'] as String? ?? '',
      timing: _parseTiming(map['timing']),
      notice: map['notice'] as String? ?? '',
      indication: map['indication'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      endDate: map['endDate'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
      batchId: map['batchId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'dosage': dosage,
      'frequency': frequency,
      'timing': jsonEncode(timing),
      'notice': notice,
      'indication': indication,
      'startDate': startDate,
      'endDate': endDate,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'batchId': batchId,
    };
  }

  MedicineModel copyWith({
    String? id,
    String? name,
    String? type,
    String? dosage,
    String? frequency,
    List<String>? timing,
    String? notice,
    String? indication,
    String? startDate,
    String? endDate,
    String? imagePath,
    String? createdAt,
    String? batchId,
  }) {
    return MedicineModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      timing: timing ?? this.timing,
      notice: notice ?? this.notice,
      indication: indication ?? this.indication,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      batchId: batchId ?? this.batchId,
    );
  }

  static List<String> _parseTiming(dynamic value) {
    if (value is String) {
      if (value.trim().isEmpty) return const [];
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((item) => item.toString()).toList();
        }
      } on FormatException {
        return const [];
      }
    }
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
