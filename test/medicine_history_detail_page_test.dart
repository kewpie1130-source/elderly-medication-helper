import 'package:elderly_medication_app/models/medicine.dart';
import 'package:elderly_medication_app/pages/medicine_history_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows saved medicine details and OCR text', (tester) async {
    const medicine = Medicine(
      id: 1,
      medicineName: '測試藥品',
      dosage: '每次一錠',
      morning: true,
      afterMeal: true,
      ocrText: '藥品名稱：測試藥品',
      createdAt: '2026-06-12T12:00:00',
    );

    await tester.pumpWidget(
      const MaterialApp(home: MedicineHistoryDetailPage(medicine: medicine)),
    );

    expect(find.text('用藥資料詳情'), findsOneWidget);
    expect(find.text('測試藥品'), findsOneWidget);
    expect(find.text('早上'), findsOneWidget);
    expect(find.text('飯後'), findsOneWidget);
    expect(find.text('OCR 原始辨識文字'), findsOneWidget);
    expect(find.text('藥品名稱：測試藥品'), findsOneWidget);
    expect(find.text('編輯這筆用藥資料'), findsOneWidget);
    expect(find.byTooltip('刪除'), findsOneWidget);
  });
}
