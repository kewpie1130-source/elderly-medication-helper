import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz; 
import '../../services/tts/tts_service.dart';
import '../../services/notification/notification_service.dart';
import '../../theme/app_theme.dart'; 
import 'widgets/reminder_modal.dart';
import 'widgets/contact_modal.dart';

class ReminderPage extends StatefulWidget {
  final String? medicineName;

  const ReminderPage({
    super.key,
    this.medicineName,
  });

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final TtsService _ttsService = TtsService();
  final NotificationService _notificationService = NotificationService();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  int _selectedFrequencyIndex = 0;
  bool _reminderEnabled = true;

  static const List<String> _frequencyLabels = ['每天', '每週', '自訂'];

  @override
  void initState() {
    super.initState();
    _ttsService.initTts();
    _notificationService.initialize();

    if (widget.medicineName != null && widget.medicineName!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerOfficialFlow(context, widget.medicineName!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentMedicine = widget.medicineName ?? "降血壓藥";

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '新增提醒',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        backgroundColor: AppTheme.background,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _triggerOfficialFlow(context, currentMedicine),
            child: const Text(
              '儲存',
              style: TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _buildSettingsCard(context),
          const SizedBox(height: 18),
          _buildCurrentReminderCard(currentMedicine),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '設定時間',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: _pickTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedTime.hour.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                  Text(
                    _selectedTime.minute.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '重複頻率',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(_frequencyLabels.length, (index) {
              final bool selected = _selectedFrequencyIndex == index;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == _frequencyLabels.length - 1 ? 0 : 8,
                  ),
                  child: ChoiceChip(
                    label: Center(child: Text(_frequencyLabels[index])),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _selectedFrequencyIndex = index);
                    },
                    showCheckmark: false,
                    selectedColor: AppTheme.primary,
                    backgroundColor: const Color(0xFFF5F5F5),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: selected ? AppTheme.primary : Colors.transparent,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentReminderCard(String currentMedicine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 10),
          child: Text(
            '目前的提醒',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    _formatSelectedTime(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.grey.shade500,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentMedicine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _frequencyLabels[_selectedFrequencyIndex],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _reminderEnabled,
                activeThumbColor: Colors.white,
                activeTrackColor: AppTheme.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: (value) {
                  setState(() => _reminderEnabled = value);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() => _selectedTime = picked);
  }

  String _formatSelectedTime() {
    return '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
  }

  void _triggerOfficialFlow(BuildContext context, String targetMedicine) {
    _ttsService.speak("是否需要設置用藥提醒？您可以設定時間提醒自己按時服藥。");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ReminderModal(
        onChoice: (wantsReminder) async { 
          Navigator.of(dialogContext).pop(); 
          
          if (wantsReminder) {
            debugPrint("長者選擇：是，前往設定用藥提醒 -> 藥物：$targetMedicine");
        
            final tz.TZDateTime scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
            final int notificationId = targetMedicine.hashCode.abs();

            await _notificationService.zonedSchedule(
              notificationId, 
              "🔔 智慧用藥助手", 
              "阿公，吃藥時間到囉！請記得服用【$targetMedicine】。", 
              scheduledTime,
              isDaily: true, 
            );

            Future.delayed(const Duration(milliseconds: 500), () {
              // ✅ 核心修正：非同步時序延遲後，先進行 mounted 檢查
              if (!mounted) return;
              
              _ttsService.speak("是否要通知聯絡人？設定後，提醒訊息將傳送至聯絡人的 LINE。");
              
              // ✅ 核心修正：在 showDialog 中，直接使用當前 State 的無風險對象 `this.context`，徹底清除跨 async gaps 警告！
              if (this.context.mounted) {
                showDialog(
                  context: this.context, 
                  barrierDismissible: false,
                  builder: (context) => ContactModal(
                    onSave: (lineId) {
                      debugPrint("長者成功綁定聯絡人 LINE ID: $lineId");
                    },
                    onCancel: () {
                      debugPrint("長者點擊不需要，依據官方設計圖流程：強制退回畫面 2");
                      Navigator.of(context).pop(); 
                      Navigator.of(context).pop(); 
                    },
                  ),
                );
              }
            });
          }
        },
      ),
    );
  }
}
