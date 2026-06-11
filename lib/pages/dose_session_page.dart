import 'package:flutter/material.dart';
import '../repositories/dose_session_repository.dart';
import '../models/dose_session.dart';

class DoseSessionPage extends StatefulWidget {
  const DoseSessionPage({super.key});

  @override
  State<DoseSessionPage> createState() => _DoseSessionPageState();
}

class _DoseSessionPageState extends State<DoseSessionPage> {
  final DoseSessionRepository _sessionRepo = DoseSessionRepository();
  
  // 模擬目前要查詢的時段 ID（正式環境可動態計算日期與時段）
  final String currentSessionId = "session_20260611_morning"; 
  late Future<DoseSession> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  void _loadSession() {
    // 企劃書規定的資料庫初始模板
    Map<String, dynamic> defaultSessionData = {
      "sessionId": currentSessionId,
      "userId": "user_001",
      "slotId": "slot_morning",
      "slotName": "早上",
      "scheduledTime": "08:00",
      "date": "2026-06-11",
      "itemIds": ["item_001"], // 這裡連結 MedicineItem 的 ID
      "status": "pending",
      "locked": false
    };

    setState(() {
      _sessionFuture = _sessionRepo.getOrCreateSession(currentSessionId, defaultSessionData);
    });
  }

  // 處理「本時段全部已服用」點擊
  void _handleAllCompleted() async {
    await _sessionRepo.completeSession(currentSessionId);
    _loadSession(); // 重新讀取雲端資料，觸發畫面刷新
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 本時段用藥紀錄已成功同步至 Firebase 雲端資料庫！')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('長者智慧用藥助手'),
        elevation: 0,
      ),
      body: FutureBuilder<DoseSession>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('無法自 Firebase 載入今日時段資料'));
          }

          DoseSession session = snapshot.data!;
          bool isLocked = session.locked; // 取得雲端鎖定狀態

          return Column(
            children: [
              // 藍色時段標題區
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                color: Colors.blue,
                child: Column(
                  children: [
                    Text('${session.slotName} ${session.scheduledTime} 服用時段',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('今天${session.slotName}有 ${session.itemIds.length} 個品項需要確認',
                        style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),

              // 動態藥品清單清單（此處可進一步串接 MedicineRepository 抓取詳細藥名）
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: Icon(Icons.medical_services, color: Colors.white),
                          ),
                          title: const Text('立普妥 Lipitor (降血脂藥)', 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: const Text('\n一次一顆，飯後服用\n說明：每天吃完早餐後配溫開水吃一顆喔！'),
                          trailing: Icon(
                            isLocked ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isLocked ? Colors.green : Colors.grey,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 底部安全防重複按鈕機制
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: isLocked
                      ? () {
                          // 如果已被雲端鎖定，跳出企劃書指定的警告對話框
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('系統提醒'),
                              content: const Text('此時段已完成，請勿重複服用。若資料有誤，請由照顧者協助修改。'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('確定'),
                                )
                              ],
                            ),
                          );
                        }
                      : _handleAllCompleted,
                  icon: Icon(isLocked ? Icons.lock : Icons.check_circle),
                  label: Text(isLocked ? '本時段已完成' : '本時段全部已服用', 
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLocked ? Colors.grey : Colors.blue,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}