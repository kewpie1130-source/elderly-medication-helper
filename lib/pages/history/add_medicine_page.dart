import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../models/medicine_model.dart';
import '../../repositories/medicine_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _indicationController = TextEditingController();
  final TextEditingController _noticeController = TextEditingController();

  final List<String> _typeOptions = ['處方藥', '指示藥', '保健食品'];
  final List<String> _timingOptions = ['早餐後', '午餐後', '晚餐後', '睡前'];
  final List<String> _selectedTiming = [];

  String _selectedType = '處方藥';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _indicationController.dispose();
    _noticeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '新增藥物紀錄',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTextFieldCard(
                label: '藥品名稱 *',
                controller: _nameController,
                hintText: '請輸入藥品名稱',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '請輸入藥品名稱';
                  }
                  return null;
                },
              ),
              _buildTypeCard(),
              _buildTextFieldCard(
                label: '用法用量',
                controller: _dosageController,
                hintText: '例如：1顆',
              ),
              _buildTextFieldCard(
                label: '使用頻率',
                controller: _frequencyController,
                hintText: '例如：每日三次',
              ),
              _buildTimingCard(),
              _buildTextFieldCard(
                label: '適應症（治療什麼）',
                controller: _indicationController,
                hintText: '例如：高血壓、感冒',
              ),
              _buildTextFieldCard(
                label: '注意事項 / 禁忌',
                controller: _noticeController,
                hintText: '請輸入注意事項',
                maxLines: 3,
              ),
              _buildDateCard(
                label: '開始日期',
                selectedDate: _startDate,
                onTap: () => _pickDate(isStartDate: true),
              ),
              _buildDateCard(
                label: '預計用完日期',
                selectedDate: _endDate,
                onTap: () => _pickDate(isStartDate: false),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 56,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveMedicine,
            icon: const Icon(Icons.check_circle, size: 22),
            label: Text(
              _isSaving ? '儲存中...' : '儲存',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.55),
              disabledForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldCard({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return _FieldCard(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 10),
        ),
      ),
    );
  }

  Widget _buildTypeCard() {
    return _FieldCard(
      label: '藥物類型',
      child: DropdownButtonFormField<String>(
        value: _selectedType,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.only(top: 8),
        ),
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.primary),
        items: _typeOptions
            .map(
              (type) => DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              ),
            )
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          setState(() => _selectedType = value);
        },
      ),
    );
  }

  Widget _buildTimingCard() {
    return _FieldCard(
      label: '服用時間',
      child: Column(
        children: _timingOptions.map((timing) {
          final bool selected = _selectedTiming.contains(timing);
          return CheckboxListTile(
            value: selected,
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: AppTheme.primary,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              timing,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: (checked) {
              setState(() {
                if (checked == true) {
                  _selectedTiming.add(timing);
                } else {
                  _selectedTiming.remove(timing);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime? selectedDate,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: double.infinity),
              _buildLabel(label),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? '點擊選擇日期'
                          : _formatDate(selectedDate),
                      style: TextStyle(
                        color: selectedDate == null
                            ? Colors.grey.shade500
                            : AppTheme.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today,
                    color: AppTheme.primary,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: AppTheme.primary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _pickDate({required bool isStartDate}) async {
    final DateTime now = DateTime.now();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: isStartDate ? (_startDate ?? now) : (_endDate ?? now),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
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

    if (selected == null) return;
    setState(() {
      if (isStartDate) {
        _startDate = selected;
      } else {
        _endDate = selected;
      }
    });
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final model = MedicineModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      type: _selectedType,
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      timing: _selectedTiming,
      notice: _noticeController.text.trim(),
      indication: _indicationController.text.trim(),
      startDate: _startDate != null ? _startDate!.toIso8601String() : '',
      endDate: _endDate != null ? _endDate!.toIso8601String() : '',
      imagePath: '',
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      final repository = MedicineRepository();
      await repository.insertMedicine(model);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 已新增藥物紀錄'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('新增藥物紀錄失敗：$error'),
          backgroundColor: Colors.red.shade600,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year} 年 ${date.month.toString().padLeft(2, '0')} 月 ${date.day.toString().padLeft(2, '0')} 日';
  }
}

class _FieldCard extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldCard({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }
}
