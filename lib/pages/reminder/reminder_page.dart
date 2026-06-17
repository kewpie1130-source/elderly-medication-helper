import 'package:flutter/material.dart';
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import '../../services/line/line_service.dart';
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();
  final LineService _lineService = LineService();

  String _currentLineId = "尚未設定";

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '智慧用藥 - 用藥提醒', 
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xff4CAF50),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xffFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xff4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "👥 當前綁定照護者 LINE ID:\n$_currentLineId",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff222222)),
                  ),
                ),
                const SizedBox(height: 20),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🔔 本地鬧鐘與語音測試', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            onPressed: () async {
                              final now = DateTime.now().add(const Duration(minutes: 1));
                              final String testTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
                              await _notificationService.scheduleDailyReminder(reminderId: "test_id", medicineName: "阿斯匹靈", timeString: testTime);
                              _ttsService.speak("已設定 $testTime 鬧鐘");
                            },
                            icon: const Icon(Icons.alarm, color: Colors.white),
                            label: const Text('設定 1 分鐘後測試鬧鐘', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 15),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('🎨 畫面 7：長者用藥時間設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff81C784), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ReminderModal(
                                  medicineName: "維他命 C",
                                  onSave: (chosenTime) async {
                                    await _notificationService.scheduleDailyReminder(reminderId: "vit_c", medicineName: "維他命 C", timeString: chosenTime);
                                    _ttsService.speak("每天 $chosenTime 提醒吃維他命 C");
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.touch_app, color: Colors.white),
                            label: const Text('模擬新增提醒 (叫出設定彈窗)', style: TextStyle(fontSize: 16, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('👥 畫面 8：照護者聯絡人綁定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        const Text('點擊叫出彈窗，輸入照護者的 LINE User ID 進行遠端連線綁定。', style: TextStyle(fontSize: 15, color: Color(0xff222222))),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff222222),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ContactModal(
                                  onSave: (String lineUserId) {
                                    setState(() {
                                      _currentLineId = lineUserId;
                                    });
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_add, color: Colors.white),
                            label: const Text('點擊綁定聯絡人 (叫出彈窗)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬 LINE 照護者遠端通知', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff4CAF50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                            onPressed: () async {
                              final now = DateTime.now();
                              await _lineService.notifyMedicationTaken(elderName: "王大同阿公", medicineName: "降血壓藥", time: "${now.hour}:${now.minute}");
                              _ttsService.speak("已打卡並發送 LINE 通知。");
                            },
                            icon: const Icon(Icons.check_circle, color: Colors.white),
                            label: const Text('模擬長者打卡（發送已服藥通知）', style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}