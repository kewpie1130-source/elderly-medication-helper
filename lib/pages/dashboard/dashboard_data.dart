class DashboardAnalytics {
  final int totalTaken;
  final int totalMissed;
  final double adherenceRate;

  DashboardAnalytics({
    required this.totalTaken,
    required this.totalMissed,
  }) : adherenceRate = (totalTaken + totalMissed) == 0 
        ? 0.0 
        : (totalTaken / (totalTaken + totalMissed)) * 100;
}
