class MedicineItem {
  final String itemId;
  final String userId;
  final String type;
  final String name;
  final String category;
  final String dosageText;
  final String plainDescription;
  final String imageUrl;
  final DateTime createdAt;

  MedicineItem({
    required this.itemId,
    required this.userId,
    required this.type,
    required this.name,
    required this.category,
    required this.dosageText,
    required this.plainDescription,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'userId': userId,
      'type': type,
      'name': name,
      'category': category,
      'dosageText': dosageText,
      'plainDescription': plainDescription,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicineItem.fromMap(Map<String, dynamic> map) {
    return MedicineItem(
      itemId: map['itemId'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? 'medicine',
      name: map['name'] ?? '未知品項',
      category: map['category'] ?? '未分類',
      dosageText: map['dosageText'] ?? '',
      plainDescription: map['plainDescription'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
