import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../repositories/medicine_repository.dart';
import '../../repositories/reminder_repository.dart';
import '../../models/reminder_model.dart';

class ReminderPage extends StatefulWidget {
  final String? medicineName;

  const ReminderPage({super.key, this.medicineName});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final NotificationService _notificationService = NotificationService();
  final ReminderRepository _reminderRepository = ReminderRepository();
  final MedicineRepository _medicineRepository = MedicineRepository();

  List<dynamic> _medicineList = [];
  List<ReminderModel> _reminderList = [];
  Map<String, String> _medicineNameMap = {};

  String? _selectedMedicineId;
  String _selectedMedicineName = "請選擇藥物";
  final TimeOfDay _selectedTime = const TimeOfDay(hour: 5, minute: 32);
  final String _selectedRepeatType = "custom";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final medicines = await _medicineRepository.getAllMedicines();
      final reminders = await _reminderRepository.getAllReminders();

      final Map<String, String> nameMap = {};
      for (var med in medicines) {
        nameMap[med.id.toString()] = med.name.toString();
      }

      if (mounted) {
        setState(() {
          _medicineList = medicines;
          _reminderList = reminders;
          _medicineNameMap = nameMap;
          if (medicines.isNotEmpty) {
            _selectedMedicineId = medicines.first.id.toString();
            _selectedMedicineName = medicines.first.name.toString();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("撈取數據異常: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveReminder() async {
    if (_selectedMedicineId == null) return;

    final String formattedTime =
        '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';

    final newReminder = ReminderModel(
      id: const Uuid().v4(),
      medicineId: _selectedMedicineId!,
      time: formattedTime,
      repeatType: _selectedRepeatType,
      enabled: true,
    );

    await _reminderRepository.insertReminder(newReminder);

    final now = DateTime.now();
    var scheduleDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (scheduleDateTime.isBefore(now)) {
      scheduleDateTime = scheduleDateTime.add(const Duration(days: 1));
    }

    await _notificationService.zonedSchedule(
      newReminder.id.hashCode.abs(),
      "🔔 智慧用藥助手",
      "阿公，吃藥時間到囉！請記得服用【$_selectedMedicineName】。",
      tz.TZDateTime.from(scheduleDateTime, tz.local),
      isDaily: _selectedRepeatType == "daily",
    );

    _loadData();

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('💚 已成功儲存用藥提醒！')));
  }

  Future<void> _toggleEnabled(ReminderModel reminder, bool value) async {
    await _reminderRepository.updateReminderEnabled(reminder.id, value);
    final int notifId = reminder.id.hashCode.abs();

    if (value) {
      final parts = reminder.time.split(':');
      final now = DateTime.now();
      var scheduleDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (scheduleDateTime.isBefore(now)) {
        scheduleDateTime = scheduleDateTime.add(const Duration(days: 1));
      }
      final String currentMedName =
          _medicineNameMap[reminder.medicineId] ?? "已知藥物";

      await _notificationService.zonedSchedule(
        notifId,
        "🔔 智慧用藥助手",
        "阿公，吃藥時間到囉！請記得服用【$currentMedName】。",
        tz.TZDateTime.from(scheduleDateTime, tz.local),
        isDaily: reminder.repeatType == "daily",
      );
    } else {
      await _notificationService.cancel(notifId);
    }
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '新增提醒',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveReminder,
            child: const Text(
              '儲存',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '選擇藥物',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedMedicineId,
                        isExpanded: true,
                        items: _medicineList.map((med) {
                          return DropdownMenuItem<String>(
                            value: med.id.toString(),
                            child: Text(
                              med.name.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppTheme.textDark,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val == null) return;
                          final selected = _medicineList.firstWhere(
                            (m) => m.id.toString() == val,
                          );
                          setState(() {
                            _selectedMedicineId = val;
                            _selectedMedicineName = selected.name.toString();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '目前的提醒',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reminderList.length,
                    itemBuilder: (context, index) {
                      final reminder = _reminderList[index];
                      final medName =
                          _medicineNameMap[reminder.medicineId] ?? "未知藥物";
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.time,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      medName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      reminder.repeatType,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Switch(
                              activeThumbColor: AppTheme.primary,
                              value: reminder.enabled,
                              onChanged: (val) => _toggleEnabled(reminder, val),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
