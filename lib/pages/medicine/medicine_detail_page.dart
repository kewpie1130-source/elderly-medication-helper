import 'package:flutter/material.dart';
import 'package:elderly_medication_helper/models/medicine_model.dart';
import 'package:elderly_medication_helper/models/dose_log_model.dart';
import 'package:elderly_medication_helper/repositories/medicine_repository.dart';
import 'package:elderly_medication_helper/theme/app_theme.dart'; // 呼叫統一主題
import 'package:uuid/uuid.dart';

class MedicineDetailPage extends StatefulWidget {
  final MedicineModel medicine;

  const MedicineDetailPage({Key? key, required this.medicine}) : super(key: key);

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineRepository _repository = MedicineRepository();
  bool _isTtsEnabled = false; // TTS 語音播報開關狀態

  // 執行服藥打卡功能
  Future<void> _handleDoseLog() async {
    final now = DateTime.now().toIso8601String();
    
    // 建立打卡紀錄 Model
    final doseLog = DoseLogModel(
      id: const Uuid().v4(),
      medicineId: widget.medicine.id,
      scheduledTime: now, // 實際專案會依據排程時間，此處先以當前時間模擬
      takenTime: now,
      status: 'taken',
      createdAt: now,
    );

    // 寫入 SQLite 資料庫
    await _repository.insertDoseLog(doseLog);

    // 彈出成功提示（長者友善大提示）
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👍 打卡成功！您已經吃過藥囉！', style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor, // 遵循主題背景色
      appBar: AppBar(
        title: const Text('藥品詳細資訊', style: TextStyle(fontSize: 24, fontWeight: 'bold')),
        backgroundColor: AppTheme.primaryColor, // 遵循主題主色
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 藥品名稱大卡片
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    const Icon(Icons.medication, size: 40, color: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(med.name, style: const TextStyle(fontSize: 26, fontWeight: 'bold', color: AppTheme.textColor)),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(med.type, style: const TextStyle(fontSize: 16, color: AppTheme.primaryColor, fontWeight: 'bold')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 詳細資訊區塊
            _buildInfoTile(Icons.thumb_up, '每次劑量', med.dosage),
            _buildInfoTile(Icons.repeat, '服用頻率', med.frequency),
            _buildInfoTile(Icons.access_time, '服用時間', med.timing.join('、')),
            _buildInfoTile(Icons.warning, '注意事項 / 禁忌', med.notice, isWarning: true),
            _buildInfoTile(Icons.calendar_month, '用藥期間', '${med.startDate} 至 ${med.endDate}'),
            
            const SizedBox(height: 30),

            // 🔊 語音播報功能切換
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                      size: 30,
                      color: _isTtsEnabled ? AppTheme.primaryColor : Colors.grey,
                    ),
                    const SizedBox(width: 10),
                    const Text('🔊 語音播報功能', style: TextStyle(fontSize: 18, fontWeight: 'bold')),
                  ],
                ),
                Switch(
                  value: _isTtsEnabled,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _isTtsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ 服藥打卡大按鈕
            SizedBox(
              width: double.infinity,
              height: 60, // 高度 > 56px，長者易點擊
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
                label: const Text('✅ 我把藥吃完了（打卡）', style: TextStyle(fontSize: 20, fontWeight: 'bold', color: