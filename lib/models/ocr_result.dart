class OcrResult {
  final String ocrId;
  final String itemId;
  final String rawText;
  final String correctedText;
  final String imageUrl;
  final DateTime createdAt;

  OcrResult({
    required this.ocrId,
    required this.itemId,
    required this.rawText,
    required this.correctedText,
    required this.imageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'ocrId': ocrId,
      'itemId': itemId,
      'rawText': rawText,
      'correctedText': correctedText,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory OcrResult.fromMap(Map<String, dynamic> map) {
    return OcrResult(
      ocrId: map['ocrId'] ?? '',
      itemId: map['itemId'] ?? '',
      rawText: map['rawText'] ?? '',
      correctedText: map['correctedText'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
