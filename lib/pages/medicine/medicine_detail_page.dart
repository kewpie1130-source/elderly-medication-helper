import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../models/dose_log_model.dart';
import '../../repositories/medicine_repository.dart';
import 'package:uuid/uuid.dart';

class MedicineDetailPage extends StatefulWidget {
  final MedicineModel medicine;

  const MedicineDetailPage({
    super.key,
    required this.medicine,
  }); // 🛠️ 優化：使用簡化型 super.key

  @override
  State<MedicineDetailPage> createState() => _MedicineDetailPageState();
}

class _MedicineDetailPageState extends State<MedicineDetailPage> {
  final MedicineRepository _repository = MedicineRepository();
  bool _isTtsEnabled = false;

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
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final med = widget.medicine;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '藥品資訊內容頁',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    color: Colors.white,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.medication,
                            size: 70,
                            color: Color(0xFF4CAF50),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            med.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoTile(Icons.mode_edit_outline, '用法與用量', med.dosage),
                  _buildInfoTile(Icons.repeat, '服用頻率', med.frequency),
                  _buildInfoTile(
                    Icons.access_time,
                    '服用時間',
                    med.timing.join('、'),
                  ),
                  _buildInfoTile(
                    Icons.health_and_safety_outlined,
                    '主要適應症',
                    med.indication.isEmpty ? '未填寫適應症' : med.indication,
                  ),
                  _buildInfoTile(
                    Icons.error_outline,
                    '注意事項 / 禁忌',
                    med.notice.isEmpty ? '無特殊備註' : med.notice,
                    isWarning: true,
                  ),
                  _buildInfoTile(Icons.category_outlined, '藥物類型', med.type),
                  _buildInfoTile(
                    Icons.calendar_today_outlined,
                    '開始日期',
                    med.startDate,
                  ),
                  _buildInfoTile(
                    Icons.calendar_month_outlined,
                    '預計用完日期',
                    med.endDate,
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 24,
              top: 10,
            ),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 1,
                      ),
                      onPressed: _handleDoseLog,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, size: 28, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            '打卡\n(已服藥)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isTtsEnabled
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () {
                        setState(() {
                          _isTtsEnabled = !_isTtsEnabled;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                            size: 28,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTtsEnabled ? '播報\n(語音開啟)' : '播報\n(語音關閉)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
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

  Widget _buildInfoTile(
    IconData icon,
    String title,
    String content, {
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 26,
            color: isWarning ? Colors.red.shade400 : const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 18,
                    color: isWarning ? Colors.red : const Color(0xFF333333),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
