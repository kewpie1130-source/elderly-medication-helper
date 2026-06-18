import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  List<File> _capturedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _capturedImages.add(File(pickedFile.path));
      });
      print('已選取照片: \');
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
            tabs: [Tab(text: "手機相簿"), Tab(text: "拍攝紀錄")],
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

  Widget _buildGalleryView() {
    return const Center(child: Text("點擊右下角相機按鈕開始拍攝藥物"));
  }

  Widget _buildRecordView() {
    if (_capturedImages.isEmpty) {
      return const Center(child: Text("目前尚無拍攝紀錄"));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: _capturedImages.length,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.file(_capturedImages[index], fit: BoxFit.cover),
          ),
        );
      },
    );
  }
}
