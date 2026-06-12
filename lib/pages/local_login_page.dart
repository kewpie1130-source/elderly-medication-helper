import 'package:flutter/material.dart';

import '../models/local_user.dart';
import '../services/database_helper.dart';

class LocalLoginPage extends StatefulWidget {
  final ValueChanged<LocalUser> onSignedIn;

  const LocalLoginPage({super.key, required this.onSignedIn});

  @override
  State<LocalLoginPage> createState() => _LocalLoginPageState();
}

class _LocalLoginPageState extends State<LocalLoginPage> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  final TextEditingController _createNameController = TextEditingController();
  final TextEditingController _createEmailController = TextEditingController();
  final TextEditingController _createPasswordController =
      TextEditingController();
  final TextEditingController _createConfirmPasswordController =
      TextEditingController();
  late Future<List<LocalUser>> _usersFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _usersFuture = _database.getLocalUsers();
  }

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _createNameController.dispose();
    _createEmailController.dispose();
    _createPasswordController.dispose();
    _createConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _reloadUsers() async {
    setState(() {
      _usersFuture = _database.getLocalUsers();
    });
  }

  Future<void> _signIn() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;
    if (email.isEmpty || password.isEmpty) {
      _showMessage('請輸入 EMAIL 與密碼');
      return;
    }

    setState(() => _isBusy = true);
    try {
      final user = await _database.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      widget.onSignedIn(user);
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _createAccount() async {
    final displayName = _createNameController.text.trim();
    final email = _createEmailController.text.trim();
    final password = _createPasswordController.text;
    final confirmPassword = _createConfirmPasswordController.text;

    if (displayName.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('請填完顯示名稱、EMAIL 與密碼');
      return;
    }
    if (password != confirmPassword) {
      _showMessage('兩次密碼輸入不一致');
      return;
    }

    setState(() => _isBusy = true);
    try {
      final user = await _database.createAccount(
        email: email,
        displayName: displayName,
        password: password,
      );
      await _reloadUsers();
      widget.onSignedIn(user);
    } catch (error) {
      if (mounted) _showMessage('$error');
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _fillLoginFromUser(LocalUser user) {
    setState(() {
      _loginEmailController.text = user.email;
      _createEmailController.text = user.email;
      _createNameController.text = user.displayName;
    });
    _showMessage('已帶入 ${user.shortLabel}，請輸入密碼登入');
  }

  String _avatarText(LocalUser user) {
    final label = user.shortLabel.trim();
    if (label.isNotEmpty) {
      return label.substring(0, 1).toUpperCase();
    }
    final email = user.email.trim();
    return email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.black54, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Icon(
                        Icons.medication_liquid_outlined,
                        size: 84,
                        color: Color(0xFF2E7D32),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '用藥管理登入',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '使用 EMAIL + 密碼登入。每個帳號會保留自己的 SQLite 資料。',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 24),
                      FutureBuilder<List<LocalUser>>(
                        future: _usersFuture,
                        builder: (context, snapshot) {
                          final users = snapshot.data ?? const <LocalUser>[];
                          return Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionTitle(
                                    '已儲存的帳號',
                                    '點一下可快速帶入 EMAIL，然後輸入密碼登入。',
                                  ),
                                  const SizedBox(height: 16),
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  else if (users.isEmpty)
                                    const Text(
                                      '目前沒有已儲存的帳號，請先建立第一個帳號。',
                                      style: TextStyle(fontSize: 16),
                                    )
                                  else
                                    Column(
                                      children: users
                                          .map(
                                            (user) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                onTap: () =>
                                                    _fillLoginFromUser(user),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xFFF7FBF7,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      16,
                                                    ),
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFD5E8D5,
                                                      ),
                                                    ),
                                                  ),
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          const Color(
                                                        0xFFC8E6C9,
                                                      ),
                                                      child: Text(
                                                        _avatarText(user),
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF1B5E20,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    title: Text(
                                                      user.shortLabel,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    subtitle:
                                                        Text(user.email),
                                                    trailing: const Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionTitle(
                                '登入現有帳號',
                                '輸入你自己的 EMAIL 與密碼。',
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _loginEmailController,
                                label: 'EMAIL',
                                icon: Icons.email_outlined,
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _loginPasswordController,
                                label: '密碼',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: _isBusy ? null : _signIn,
                                  icon: const Icon(Icons.login),
                                  label: const Text(
                                    '登入',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildSectionTitle(
                                '建立新帳號',
                                '新的帳號會擁有獨立資料，登入後不會跟其他帳號混在一起。',
                              ),
                              const SizedBox(height: 16),
                              _buildInputField(
                                controller: _createNameController,
                                label: '顯示名稱',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _createEmailController,
                                label: 'EMAIL',
                                icon: Icons.alternate_email,
                                hintText: 'name@example.com',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _createPasswordController,
                                label: '密碼',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 12),
                              _buildInputField(
                                controller: _createConfirmPasswordController,
                                label: '確認密碼',
                                icon: Icons.lock_reset_outlined,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 56,
                                child: FilledButton.icon(
                                  onPressed: _isBusy ? null : _createAccount,
                                  icon: const Icon(Icons.person_add_alt_1),
                                  label: const Text(
                                    '建立並登入',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                '密碼會以雜湊方式儲存，不會直接存成明文。',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.black54,
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
            if (_isBusy)
              const ColoredBox(
                color: Color(0x55000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
