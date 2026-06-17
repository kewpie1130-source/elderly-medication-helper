import 'package:flutter/material.dart';

class ReminderModal extends StatelessWidget {
  final String medicineName;
  final String dosage;

  const ReminderModal({
    super.key,
    required this.medicineName,
    required this.dosage,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.0)),
      backgroundColor: Colors.amber.shade50, // 醒目且溫和的顏色
      title: const Row(
        children: [
          Icon(Icons.alarm_on, color: Colors.orange, size: 40),
          SizedBox(width: 12),
          Text('🔔 吃藥時間到囉！', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.redAccent)),
        ],
      ),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
          width: screenWidth * 0.7, height: 70, // 特大號按鈕方便長者點擊
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 6,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('👍 我已經吃藥了', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}