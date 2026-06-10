import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineItem {
  final String itemId;
  final String userId;
  final String type; // medicine, supplement, unknown
  final String name;
  final String category; // e.g., 高血壓, 糖尿病, 維他命
  final String dosageText; // e.g., 一次一顆
  final List<String> scheduleSlotIds; // e.g., ['slot_morning', 'slot_evening']
  final String plainDescription; // AI 白話說明
  final String imageUrl;
  final DateTime createdAt;

  MedicineItem({
    required this.itemId,
    required this.userId,
    required this.type,
    required this.name,
    required this.category,
    required this.dosageText,
    required this.scheduleSlotIds,
    required this.plainDescription,
    required this.imageUrl,
    required this.createdAt,
  });

  factory MedicineItem.fromJson(Map<String, dynamic> json) {
    return MedicineItem(
      itemId: json['itemId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'unknown',
      name: json['name'] ?? '未知品項',
      category: json['category'] ?? '',
      dosageText: json['dosageText'] ?? '',
      scheduleSlotIds: List<String>.from(json['scheduleSlotIds'] ?? []),
      plainDescription: json['plainDescription'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'userId': userId,
      'type': type,
      'name': name,
      'category': category,
      'dosageText': dosageText,
      'scheduleSlotIds': scheduleSlotIds,
      'plainDescription': plainDescription,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}