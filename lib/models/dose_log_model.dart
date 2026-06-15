// [邱靖喻] 全組統一資料格式
// 需要新增或修改欄位請找邱靖喻，不可自行修改
class DoseLogModel {
  final String id;
  final String medicineId;
  final String scheduledTime;
  final String takenTime;
  final String status;
  final String createdAt;

  const DoseLogModel({
    required this.id,
    required this.medicineId,
    required this.scheduledTime,
    required this.takenTime,
    required this.status,
    required this.createdAt,
  });

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['id'] as String? ?? '',
      medicineId: json['medicineId'] as String? ?? '',
      scheduledTime: json['scheduledTime'] as String? ?? '',
      takenTime: json['takenTime'] as String? ?? '',
      status: json['status'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'scheduledTime': scheduledTime,
      'takenTime': takenTime,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory DoseLogModel.fromMap(Map<String, dynamic> map) {
    return DoseLogModel(
      id: map['id'] as String? ?? '',
      medicineId: map['medicineId'] as String? ?? '',
      scheduledTime: map['scheduledTime'] as String? ?? '',
      takenTime: map['takenTime'] as String? ?? '',
      status: map['status'] as String? ?? '',
      createdAt: map['createdAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'scheduledTime': scheduledTime,
      'takenTime': takenTime,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
