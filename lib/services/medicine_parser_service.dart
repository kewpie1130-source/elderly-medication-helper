import 'package:flutter/foundation.dart';

import '../models/medicine.dart';

class MedicineParserService {
  Medicine parse(String rawText, {String imagePath = ''}) {
    final text = _normalize(rawText);
    final lines = text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final medicineLines = _firstMedicineSection(lines);
    final medicineText = medicineLines.join('\n');
    final timingText = _findTimingText(medicineLines);
    final frequency = _findFrequency(medicineText);
    final inferredPeriods = _inferPeriods(medicineText, frequency);
    final now = DateTime.now();

    final medicine = Medicine(
      patientName: _valueAfterLabel(text, const ['病人姓名', '患者姓名', '姓名']),
      clinicName: _findClinicName(lines),
      medicineName: _findMedicineName(lines),
      dosage: _findDosage(medicineText),
      frequency: frequency,
      timingText: timingText,
      morning: inferredPeriods.$1,
      noon: inferredPeriods.$2,
      evening: inferredPeriods.$3,
      beforeSleep: inferredPeriods.$4,
      beforeMeal: medicineText.contains('飯前'),
      afterMeal: medicineText.contains('飯後'),
      startDate: _findDate(text),
      endDate: '',
      notes: _findNotes(lines),
      imagePath: imagePath,
      ocrText: rawText,
      createdAt: now.toIso8601String(),
    );
    debugPrint('【Parser結果】${medicine.toMap()}');
    return medicine;
  }

  String _normalize(String text) {
    return text
        .replaceAll('\r\n', '\n')
        .replaceAll('：', ':')
        .replaceAll(RegExp(r'[ \t]+'), ' ');
  }

  String _valueAfterLabel(String text, List<String> labels) {
    for (final label in labels) {
      final match = RegExp(
        '$label\\s*[:：]?\\s*([^\\n]+)',
        caseSensitive: false,
      ).firstMatch(text);
      if (match != null) {
        return match.group(1)?.trim() ?? '';
      }
    }
    return '';
  }

  String _findClinicName(List<String> lines) {
    for (final line in lines.take(6)) {
      if (_containsAny(line, const ['醫院', '診所', '藥局', '醫療院所'])) {
        return line.replaceAll(RegExp(r'[（(].*?[）)]'), '').trim();
      }
    }
    return '';
  }

  String _findMedicineName(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line.contains('藥品名稱')) {
        final value = line
            .replaceFirst(RegExp(r'.*藥品名稱\s*[:：]?\s*'), '')
            .trim();
        if (value.isNotEmpty) return value;
        if (index + 1 < lines.length) return lines[index + 1];
      }
    }

    for (final line in lines) {
      if (_containsAny(line, const ['錠', '膠囊', '藥水', '顆粒', '軟膏'])) {
        return line;
      }
    }
    return '';
  }

  List<String> _firstMedicineSection(List<String> lines) {
    final firstLabelIndex = lines.indexWhere((line) => line.contains('藥品名稱'));
    if (firstLabelIndex == -1) return lines;

    final nextLabelOffset = lines
        .skip(firstLabelIndex + 1)
        .toList()
        .indexWhere((line) => line.contains('藥品名稱'));
    final endIndex = nextLabelOffset == -1
        ? lines.length
        : firstLabelIndex + 1 + nextLabelOffset;
    return lines.sublist(firstLabelIndex, endIndex);
  }

  String _findDosage(String text) {
    final match = RegExp(
      r'(每次\s*[一二三四五六七八九十\d.]+\s*(?:錠|顆|粒|包|毫升|mL|ml)|'
      r'\d+(?:\.\d+)?\s*(?:mg|毫克|g|克|mL|ml|毫升))',
      caseSensitive: false,
    ).firstMatch(text);
    return match?.group(0)?.trim() ?? '';
  }

  String _findFrequency(String text) {
    final match = RegExp(
      r'(每日\s*[一二三四五六七八九十\d]+\s*次|一天\s*[一二三四五六七八九十\d]+\s*次|'
      r'每\s*\d+\s*小時\s*一次)',
    ).firstMatch(text);
    return match?.group(0)?.trim() ?? '';
  }

  (bool, bool, bool, bool) _inferPeriods(String text, String frequency) {
    var morning = _containsAny(text, const ['早上', '早餐', '晨']);
    var noon = _containsAny(text, const ['中午', '午餐']);
    var evening = _containsAny(text, const ['晚上', '晚餐']);
    var beforeSleep = _containsAny(text, const ['睡前', '就寢前']);
    if (morning || noon || evening || beforeSleep) {
      return (morning, noon, evening, beforeSleep);
    }

    final normalizedFrequency = frequency
        .replaceAll('一', '1')
        .replaceAll('二', '2')
        .replaceAll('兩', '2')
        .replaceAll('三', '3')
        .replaceAll('四', '4');
    final count = int.tryParse(
      RegExp(r'\d+').firstMatch(normalizedFrequency)?.group(0) ?? '',
    );
    morning = count != null && count >= 1;
    evening = count != null && count >= 2;
    noon = count != null && count >= 3;
    beforeSleep = count != null && count >= 4;
    return (morning, noon, evening, beforeSleep);
  }

  String _findTimingText(List<String> lines) {
    final timingLines = lines.where(
      (line) => _containsAny(line, const [
        '用法',
        '每日',
        '一天',
        '飯前',
        '飯後',
        '早餐',
        '午餐',
        '晚餐',
        '睡前',
      ]),
    );
    return timingLines.take(3).join('；');
  }

  String _findDate(String text) {
    final match = RegExp(
      r'(\d{4})\s*[年/\-.]\s*(\d{1,2})\s*[月/\-.]\s*(\d{1,2})',
    ).firstMatch(text);
    if (match == null) return '';
    final year = match.group(1);
    final month = match.group(2)!.padLeft(2, '0');
    final day = match.group(3)!.padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _findNotes(List<String> lines) {
    for (var index = 0; index < lines.length; index++) {
      if (_containsAny(lines[index], const ['注意事項', '備註'])) {
        return lines[index]
            .replaceFirst(RegExp(r'^(注意事項|備註)\s*[:：]?\s*'), '')
            .trim();
      }
    }
    return '';
  }

  bool _containsAny(String text, List<String> values) {
    return values.any(text.contains);
  }
}
