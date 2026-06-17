import 'package:flutter/material.dart';
import 'package:elderly_medication_helper/models/medicine_model.dart';
import 'package:elderly_medication_helper/models/dose_log_model.dart';
import 'package:elderly_medication_helper/repositories/medicine_repository.dart';
import 'package:elderly_medication_helper/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class MedicineDetailPage extends StatefulWidget {
  final MedicineModel medicine;

  const MedicineDetailPage({Key? key, required this.medicine}) : super(key: key);

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineRepository _repository = MedicineRepository();
  bool _isTtsEnabled = false; // 控制語音播報開關狀態

  Future<void> _handleDoseLog() async {
    final now = DateTime.now().toIso8601String();
    
    final doseLog = DoseLogModel(
      id: const Uuid().v4(),
      medicineId: widget.medicine.id,
      scheduledTime: now,
      takenTime: now,
      status: 'taken',
      createdAt: now,
    );

    await _repository.insertDoseLog(doseLog);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👍 打卡成功！您已經吃過藥囉！', style: TextStyle(fontSize: 18)),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('藥品資訊內容', style: TextStyle(fontSize: 24, fontWeight: 'bold')),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          // 上半部滾動內容區
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 藥品大圖示與名稱卡片（仿照設計圖上方大卡片）
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(Icons.medication, size: 80, color: AppTheme.primaryColor),
                          const SizedBox(height: 12),
                          Text(
                            med.name,
                            style: const TextStyle(fontSize: 26, fontWeight: 'bold', color: AppTheme.textColor),
                            textAlign: Center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. 依照設計圖欄位順序呈現之資訊條
                  _buildInfoTile(Icons.assignment, '適應症', med.indication.isEmpty ? '無' : med.indication),
                  _buildInfoTile(Icons.medical_services, '用法與用量', med.dosage),
                  _buildInfoTile(Icons.warning, '注意事項 / 禁忌', med.notice, isWarning: true),
                  _buildInfoTile(Icons.category, '藥物類型', med.type),
                  _buildInfoTile(Icons.calendar_month, '預計用完日期', med.endDate),
                ],
              ),
            ),
          ),

          // 3. 底部並排雙大按鈕（完美還原 ui_reference.png 設計）
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 10),
            color: AppTheme.backgroundColor,
            child: Row(
              children: [
                // 左按鈕：打卡（已服藥）
                Expanded(
                  child: SizedBox(
                    height: 65, // 高度大於 56px 方便長者點擊
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor, // 綠色背景
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 3,
                      ),
                      onPressed: _handleDoseLog,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 28, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            '打卡\n(已服藥)', 
                            style: TextStyle(fontSize: 18, fontWeight: 'bold', color: Colors.white, height: 1.2),
                            textAlign: Center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // 右按鈕：播報（語音開關）
                Expanded(
                  child: SizedBox(
                    height: 65,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTtsEnabled ? AppTheme.primaryColor : Colors.grey.shade600, // 依據狀態變色
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 3,
                      ),
                      onPressed: () {
                        setState(() {
                          _isTtsEnabled = !_isTtsEnabled;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_isTtsEnabled ? '🔊 語音播報已開啟' : '🔇 語音播報已關閉', style: const TextStyle(fontSize: 16)),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_isTtsEnabled ? Icons.volume_up : Icons.volume_off, size: 28, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            _isTtsEnabled ? '播報\n(語音開啟)' : '播報\n(語音關閉)',
                            style: const TextStyle(fontSize: 18, fontWeight: 'bold', color: Colors.white, height: 1.2),
                            textAlign: Center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String content, {bool isWarning = false}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: isWarning ? Colors.orange : AppTheme.primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 15, color: Colors.grey, fontWeight: 'bold')),
                  const SizedBox(height: 4),
                  Text(content, style: TextStyle(fontSize: 18, color: isWarning ? Colors.red : AppTheme.textColor, fontWeight: 'bold')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}