import 'package:flutter/material.dart';

class ReminderModal extends StatelessWidget {
  final Function(bool) onChoice; // 改為傳回長者的選擇（是或略過）

  const ReminderModal({
    super.key,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.0)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(28.0),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. 官方設計圖綠色大鈴鐺圖標
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.notifications, color: Color(0xFF4CAF50), size: 50),
            ),
            const SizedBox(height: 24),
            
            // 2. 官方標題：是否需要設置用藥提醒？
            const Text(
              '是否需要設置用藥提醒？',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            
            // 3. 官方副標題
            const Text(
              '您可以設定時間提醒自己按時服藥',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            
            // 4. 按鈕 1：是，前往設定（綠底大按鈕）
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onChoice(true); // 前往設定
                },
                child: const Text('是，前往設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            
            // 5. 按鈕 2：暫時略過（灰底大按鈕）
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEEEEE),
                  foregroundColor: Colors.black54,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onChoice(false); // 略過
                },
                child: const Text('暫時略過', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}