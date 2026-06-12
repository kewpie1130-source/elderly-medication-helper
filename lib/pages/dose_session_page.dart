import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dose_item_log.dart';
import '../models/dose_session.dart';
import '../models/medicine_item.dart';
import '../repositories/dose_item_log_repository.dart';
import '../repositories/dose_session_repository.dart';
import '../repositories/medicine_repository.dart';
import '../services/database_helper.dart';

class DoseSessionPage extends StatefulWidget {
  const DoseSessionPage({super.key});

  @override
  State<DoseSessionPage> createState() => _DoseSessionPageState();
}

class _DoseSessionPageState extends State<DoseSessionPage> {
  final DoseSessionRepository _sessionRepository = DoseSessionRepository();
  final DoseItemLogRepository _logRepository = DoseItemLogRepository();
  final MedicineRepository _medicineRepository = MedicineRepository();
  final DatabaseHelper _database = DatabaseHelper.instance;

  late final _DoseSlot _slot;
  late final String _sessionId;
  late Future<_DoseSessionViewData> _viewData;

  @override
  void initState() {
    super.initState();
    _slot = _DoseSlot.forTime(DateTime.now());
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _sessionId = 'session_${_database.activeUserId}_${date}_${_slot.id}';
    _viewData = _loadViewData();
  }

  Future<_DoseSessionViewData> _loadViewData() async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final medicines = await _medicineRepository.getMedicineItemsForSlot(
      _slot.id,
    );
    final session = await _sessionRepository.getOrCreateSession(_sessionId, {
      'sessionId': _sessionId,
      'userId': _database.activeUserId,
      'slotId': _slot.id,
      'slotName': _slot.name,
      'scheduledTime': _slot.scheduledTime,
      'date': date,
      'itemIds': medicines.map((medicine) => medicine.itemId).toList(),
      'status': 'pending',
      'locked': false,
      'reminderTriggered': false,
      'caregiverNotified': false,
    });

    final sessionMedicines = <MedicineItem>[];
    for (final itemId in session.itemIds) {
      final medicine = await _medicineRepository.getMedicineItemById(itemId);
      if (medicine != null) {
        sessionMedicines.add(medicine);
      }
    }
    return _DoseSessionViewData(session, sessionMedicines);
  }

  Future<void> _completeSession(_DoseSessionViewData data) async {
    final takenAt = DateTime.now();
    for (final medicine in data.medicines) {
      await _logRepository.logItemStatus(
        DoseItemLog(
          logId: '${data.session.sessionId}_${medicine.itemId}',
          sessionId: data.session.sessionId,
          itemId: medicine.itemId,
          status: 'taken',
          takenAt: takenAt,
        ),
      );
    }
    await _sessionRepository.completeSession(data.session.sessionId);

    if (!mounted) return;
    setState(() {
      _viewData = _loadViewData();
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('本時段用藥紀錄已儲存在本機。')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('今日用藥打卡'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: FutureBuilder<_DoseSessionViewData>(
        future: _viewData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('無法載入本機用藥時段資料'));
          }

          final data = snapshot.data!;
          final session = data.session;
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                color: Colors.blue,
                child: Column(
                  children: [
                    Text(
                      '${session.slotName} ${session.scheduledTime} 服用時段',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '此時段有 ${data.medicines.length} 個品項需要確認',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: data.medicines.isEmpty
                    ? const Center(child: Text('此時段沒有設定藥物'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: data.medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = data.medicines[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.orangeAccent,
                                child: Icon(
                                  Icons.medical_services,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                medicine.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  medicine.dosageText,
                                  medicine.plainDescription,
                                ].where((text) => text.isNotEmpty).join('\n'),
                              ),
                              trailing: Icon(
                                session.locked
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: session.locked
                                    ? Colors.green
                                    : Colors.grey,
                                size: 32,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: session.locked || data.medicines.isEmpty
                      ? null
                      : () => _completeSession(data),
                  icon: Icon(session.locked ? Icons.lock : Icons.check_circle),
                  label: Text(
                    session.locked ? '本時段已完成' : '本時段全部已服用',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

class _DoseSessionViewData {
  final DoseSession session;
  final List<MedicineItem> medicines;

  const _DoseSessionViewData(this.session, this.medicines);
}

class _DoseSlot {
  final String id;
  final String name;
  final String scheduledTime;

  const _DoseSlot(this.id, this.name, this.scheduledTime);

  factory _DoseSlot.forTime(DateTime time) {
    if (time.hour < 11) {
      return const _DoseSlot('morning', '早上', '08:00');
    }
    if (time.hour < 15) {
      return const _DoseSlot('noon', '中午', '12:00');
    }
    if (time.hour < 21) {
      return const _DoseSlot('evening', '晚上', '18:00');
    }
    return const _DoseSlot('before_sleep', '睡前', '21:00');
  }
}
