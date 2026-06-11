import 'dart:math';
import '../models/analytics_model.dart';

class ChartService {
  Future<List<AnalyticsData>> getMockAnalytics() async {
    final random = Random();
    return List.generate(20, (index) {
      return AnalyticsData(
        ageGroup: ["65-74", "75-84", "85+"][random.nextInt(3)],
        gender: ["male", "female"][random.nextInt(2)],
        itemType: ["medicine", "supplement"][random.nextInt(2)],
        category: ["高血壓", "糖尿病", "維他命", "鈣片", "止痛"][random.nextInt(5)],
        completionRate: 0.6 + random.nextDouble() * 0.35, 
        missedCount: random.nextInt(5),
      );
    });
  }
}