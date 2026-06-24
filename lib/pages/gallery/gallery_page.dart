import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/analytics/analytics_service.dart';
import '../../theme/app_theme.dart';

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
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text(
            "相簿",
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AppTheme.background,
          bottom: TabBar(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            indicator: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textDark,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: [
              Container(
                height: 38,
                alignment: Alignment.center,
                child: const Text("手機相簿載入"),
              ),
              Container(
                height: 38,
                alignment: Alignment.center,
                child: const Text("拍攝紀錄"),
              ),
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
          heroTag: 'gallery_fab',
          backgroundColor: AppTheme.primary,
          onPressed: () => _pickImage(ImageSource.camera),
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildGalleryView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.image_outlined,
                size: 82,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              "從手機相簿選取照片\n辨識藥品資訊",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "支援 JPG、PNG 圖片格式",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 42),
            SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_outlined, size: 26),
                label: const Text(
                  "從相簿選取照片",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordView() {
    if (_capturedImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 76,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 14),
            Text(
              "尚無拍攝紀錄",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 14,
        crossAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemCount: _capturedImages.length,
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _capturedImages[index],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formatImageDate(_capturedImages[index]),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  String _formatImageDate(File image) {
    final DateTime modified = image.lastModifiedSync();
    return '${modified.year}/${modified.month.toString().padLeft(2, '0')}/${modified.day.toString().padLeft(2, '0')}';
  }
}
