import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/analytics/analytics_service.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  final AnalyticsService _analytics = AnalyticsService();
  List<File> _capturedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _capturedImages.add(File(pickedFile.path));
      });
      
      // 整合 Analytics：拍照後記錄匿名數據
      await _analytics.logAnalytics(
        ageGroup: "65-74", // 預設值，可後續調整
        gender: "other",
        medicineType: "保健食品", // 實際應用應由辨識結果傳入
        taken: true,
        hour: DateTime.now().hour.toString().padLeft(2, '0'),
      );
      
      print('已成功紀錄匿名數據至 Firestore');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("藥物相簿", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF4CAF50),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "手機相簿"),
              Tab(text: "拍攝紀錄"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildGalleryView(),
            _buildRecordView(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () => _pickImage(ImageSource.camera),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGalleryView() => const Center(child: Text("點擊相機按鈕", style: TextStyle(fontSize: 18)));

  Widget _buildRecordView() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _capturedImages.length,
      itemBuilder: (context, index) => Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(_capturedImages[index], fit: BoxFit.cover),
        ),
      ),
    );
  }
}
