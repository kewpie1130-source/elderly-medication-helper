import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elderly_medication_app/navigation/app_router.dart';

void main() {
  testWidgets('App 可以正常啟動', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: MainNavigationPage()),
    );
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
