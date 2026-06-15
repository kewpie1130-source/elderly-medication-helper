// [邱靖喻] 全組統一資料格式
// 需要新增或修改欄位請找邱靖喻，不可自行修改
class ReminderModel {
  final String id;
  final String medicineId;
  final String time;
  final String repeatType;
  final bool enabled;

  const ReminderModel({
    required this.id,
    required this.medicineId,
    required this.time,
    required this.repeatType,
    required this.enabled,
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id'] as String? ?? '',
      medicineId: json['medicineId'] as String? ?? '',
      time: json['time'] as String? ?? '',
      repeatType: json['repeatType'] as String? ?? '',
      enabled: _parseEnabled(json['enabled']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicineId': medicineId,
      'time': time,
      'repeatType': repeatType,
      'enabled': enabled,
    };
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String? ?? '',
      medicineId: map['medicineId'] as String? ?? '',
      time: map['time'] as String? ?? '',
      repeatType: map['repeatType'] as String? ?? '',
      enabled: _parseEnabled(map['enabled']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'time': time,
      'repeatType': repeatType,
      'enabled': enabled ? 1 : 0,
    };
  }

  static bool _parseEnabled(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return false;
  }
}
