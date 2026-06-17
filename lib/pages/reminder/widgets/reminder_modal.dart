import 'package:flutter/material.dart';

class ReminderModal extends StatelessWidget {
  final String medicineName;
  final String dosage;
  final Function(TimeOfDay) onSave;

  const ReminderModal({
    super.key,
    required this.medicineName,
    required this.dosage,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.amber.shade50,
      title: const Row(
        children: [
          Icon(Icons.alarm_on, color: Colors.orange, size: 40),
          SizedBox(width: 12),
          // 🔥 核心修正：使用 Expanded 包裹，避免大字體在小螢幕或彈窗中發生 RIGHT OVERFLOWED 爆出
          Expanded(
            child: Text(
              '吃藥時間到囉！', // 稍微精簡字數，讓長者看得很舒服，寬度也完美
              style: TextStyle(
                fontSize: 26, // 字體稍微微調到 26，維持大字體又安全
                fontWeight: FontWeight.bold, 
                color: Colors.redAccent
              ),
              softWrap: true, // 允許自動換行
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // 靠左對齊，排版更整齊
          children: [
            const SizedBox(height: 10),
            Text('藥物名稱：$medicineName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Text('服用劑量：$dosage', style: const TextStyle(fontSize: 22, color: Colors.black54)),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 24),
      actions: [
        SizedBox(
          width: screenWidth * 0.7, height: 70,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
            ),
            onPressed: () {
              onSave(TimeOfDay.now());
              Navigator.of(context).pop(true);
            },
            child: const Text('👍 我已經吃藥了', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}