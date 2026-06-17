import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 模擬資料，未來會替換成 SQLite 或 Firebase 的真實資料
    final List<String> imageUrls = List.generate(10, (index) => 'https://via.placeholder.com/150');

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("相簿", style: TextStyle(fontSize: AppTheme.titleFontSize)),
          backgroundColor: AppTheme.primary,
          bottom: const TabBar(
            tabs: [
              Tab(text: "手機相簿"),
              Tab(text: "拍攝紀錄"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 分頁 1: 手機相簿
            const Center(child: Text("手機相簿功能開發中", style: TextStyle(fontSize: AppTheme.bodyFontSize))),
            
            // 分頁 2: App 拍攝紀錄 (GridView 實作)
            GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, 
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), // 符合 SPEC.md 規範
                  elevation: 3, // 符合 SPEC.md 規範
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(imageUrls[index], fit: BoxFit.cover),
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