import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart'; // ✅ 引入專案規格主題

class ReminderModal extends StatelessWidget {
  final Function(bool) onChoice; 

  const ReminderModal({
    super.key,
    required this.onChoice,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    
    return AlertDialog(
      // ✅ 修正圓角：28.0 -> 一律改為符合規範的 20.0
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(28.0),
      content: SizedBox(
        width: screenWidth * 0.85,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.notifications, color: AppTheme.primary, size: 50), // ✅ 統一 AppTheme
            ),
            const SizedBox(height: 24),
            const Text(
              '是否需要設置用藥提醒？',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textDark), // ✅ 統一 AppTheme
            ),
            const SizedBox(height: 16),
            const Text(
              '您可以設定時間提醒自己按時服藥',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppTheme.textDark), // ✅ 統一 AppTheme
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 60, // ✅ 高度維持 60，大於等於最低標準的 56px
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary, // ✅ 統一 AppTheme
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => onChoice(true), 
                child: const Text('是，前往設定', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEEEEEE),
                  foregroundColor: AppTheme.textDark, // ✅ 統一 AppTheme
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () => onChoice(false), 
                child: const Text('暫時略過', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}