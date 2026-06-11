import 'package:elderly_medication_app/services/medicine_parser_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses common Traditional Chinese prescription fields', () {
    const text = '''
安心綜合醫院
病人姓名：王小明
日期：2026年6月11日
藥品名稱：普拿疼錠 500毫克
用法：每日三次，每次一錠，早上、中午、晚上飯後服用
注意事項：如有不適請諮詢醫師或藥師
藥品名稱：胃舒平錠
用法：每日三次，每次一錠，飯前服用
''';

    final medicine = MedicineParserService().parse(text);

    expect(medicine.clinicName, '安心綜合醫院');
    expect(medicine.patientName, '王小明');
    expect(medicine.medicineName, '普拿疼錠 500毫克');
    expect(medicine.frequency, '每日三次');
    expect(medicine.morning, isTrue);
    expect(medicine.noon, isTrue);
    expect(medicine.evening, isTrue);
    expect(medicine.afterMeal, isTrue);
    expect(medicine.beforeMeal, isFalse);
    expect(medicine.startDate, '2026-06-11');
    expect(medicine.notes, '如有不適請諮詢醫師或藥師');
  });
}
