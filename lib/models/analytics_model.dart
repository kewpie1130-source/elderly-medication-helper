class AnalyticsData {
  final String ageGroup;
  final String gender;
  final String itemType;
  final String category;
  final double completionRate;
  final int missedCount;

  AnalyticsData({
    required this.ageGroup,
    required this.gender,
    required this.itemType,
    required this.category,
    required this.completionRate,
    required this.missedCount,
  });
}