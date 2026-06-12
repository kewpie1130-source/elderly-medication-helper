import 'package:flutter/material.dart';

import 'models/local_user.dart';
import 'pages/admin_dashboard_page.dart';
import 'pages/history_page.dart';
import 'pages/home_page.dart';
import 'pages/local_login_page.dart';
import 'pages/reminder_page.dart';
import 'pages/scan_page.dart';
import 'pages/settings_page.dart';
import 'services/database_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final DatabaseHelper _database = DatabaseHelper.instance;
  late Future<LocalUser?> _activeUser;

  @override
  void initState() {
    super.initState();
    _activeUser = _database.restoreActiveUser();
  }

  void _setActiveUser(LocalUser user) {
    setState(() {
      _activeUser = Future.value(user);
    });
  }

  Future<void> _signOut() async {
    await _database.signOut();
    if (!mounted) return;
    setState(() {
      _activeUser = Future<LocalUser?>.value(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '智慧用藥管理',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        scaffoldBackgroundColor: const Color(0xFFF4F8F4),
        useMaterial3: true,
      ),
      home: FutureBuilder<LocalUser?>(
        future: _activeUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          final user = snapshot.data;
          if (user == null) {
            return LocalLoginPage(onSignedIn: _setActiveUser);
          }
          return MainNavigationPage(
            key: ValueKey(user.userId),
            currentUser: user,
            onSignOut: _signOut,
          );
        },
      ),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  final LocalUser currentUser;
  final Future<void> Function() onSignOut;

  const MainNavigationPage({
    super.key,
    required this.currentUser,
    required this.onSignOut,
  });

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  int _refreshToken = 0;

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  void _refreshData() {
    setState(() => _refreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(refreshToken: _refreshToken, onSelectTab: _selectTab),
      ScanPage(onDataChanged: _refreshData, onViewHistory: () => _selectTab(3)),
      ReminderPage(refreshToken: _refreshToken, onDataChanged: _refreshData),
      HistoryPage(refreshToken: _refreshToken),
      const AdminDashboardPage(),
      SettingsPage(
        refreshToken: _refreshToken,
        currentUser: widget.currentUser,
        onDataChanged: _refreshData,
        onSignOut: widget.onSignOut,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首頁',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_a_photo_outlined),
            selectedIcon: Icon(Icons.add_a_photo),
            label: '新增',
          ),
          NavigationDestination(
            icon: Icon(Icons.alarm_outlined),
            selectedIcon: Icon(Icons.alarm),
            label: '提醒',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '紀錄',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: '分析',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
