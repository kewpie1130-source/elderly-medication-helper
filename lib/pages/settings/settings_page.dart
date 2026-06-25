import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  String _userName = '使用者';
  String _lineId = '';
  String _language = '繁體中文';

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primary),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.primary,
              ),
              title: const Text('從相簿選擇'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _avatarImage = File(picked.path));
      }
    }
  }

  Future<void> _editUserName() async {
    final controller = TextEditingController(text: _userName);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('使用者資訊'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: '名稱'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('儲存'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (name != null && name.isNotEmpty) {
      setState(() => _userName = name);
    }
  }

  Future<void> _editLineId() async {
    final controller = TextEditingController(text: _lineId);
    final lineId = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('聯絡人設定'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'LINE ID'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('儲存'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (lineId != null) {
      setState(() => _lineId = lineId);
    }
  }

  Future<void> _selectLanguage() async {
    final language = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primary),
              title: const Text('繁體中文'),
              onTap: () => Navigator.pop(ctx, '繁體中文'),
            ),
            ListTile(
              leading: const Icon(Icons.language, color: AppTheme.primary),
              title: const Text('English'),
              onTap: () => Navigator.pop(ctx, 'English'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || language == null) return;
    setState(() => _language = language);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已切換為$language')),
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('登出'),
        content: const Text('確定要登出嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('確定'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已登出')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          '設定',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildSettingsItem(
            Icons.person,
            '使用者資訊',
            _editUserName,
            subtitle: _userName,
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            Icons.contacts,
            '聯絡人設定',
            _editLineId,
            subtitle: _lineId.isEmpty ? '設定緊急聯絡人的 LINE ID' : _lineId,
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            Icons.language,
            '語言設定',
            _selectLanguage,
            subtitle: _language,
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(Icons.logout, '登出', _confirmLogout),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.primary,
              backgroundImage:
                  _avatarImage != null ? FileImage(_avatarImage!) : null,
              child: _avatarImage == null
                  ? const Icon(Icons.person, color: Colors.white, size: 40)
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '您好，',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        leading: Icon(icon, color: AppTheme.primary, size: 26),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
