import 'package:elderly_medication_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows MVP home and bottom navigation', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('智慧用藥管理'), findsOneWidget);
    expect(find.text('今天應服用藥物摘要'), findsOneWidget);
    expect(find.text('新增用藥影像'), findsOneWidget);
    expect(find.text('今日用藥提醒'), findsOneWidget);
    expect(find.text('用藥紀錄'), findsOneWidget);
    expect(find.text('設定'), findsWidgets);
    expect(find.text('首頁'), findsOneWidget);
    expect(find.text('新增'), findsOneWidget);
    expect(find.text('提醒'), findsOneWidget);
    expect(find.text('紀錄'), findsOneWidget);

    await tester.tap(find.text('提醒'));
    await tester.pump();

    expect(find.text('開始本時段用藥打卡'), findsOneWidget);
  });
}
