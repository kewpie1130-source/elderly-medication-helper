import 'dart:io';

import 'package:flutter/material.dart';

import '../services/local_image_repository.dart';
import 'scan_page.dart';

class ImageHistoryPage extends StatefulWidget {
  const ImageHistoryPage({super.key});

  @override
  State<ImageHistoryPage> createState() => _ImageHistoryPageState();
}

class _ImageHistoryPageState extends State<ImageHistoryPage> {
  final LocalImageRepository _repository = LocalImageRepository();
  late Future<List<File>> _images;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _images = _repository.getAll();
  }

  Future<void> _deleteImage(File image) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除影像'),
        content: const Text('確定要刪除這筆用藥影像紀錄嗎？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
    if (shouldDelete != true) return;

    try {
      await _repository.delete(image);
      if (!mounted) return;
      setState(_reload);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('刪除圖片失敗：$error')));
    }
  }

  void _openImage(File image) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _StoredImagePage(image: image)),
    ).then((_) {
      if (mounted) setState(_reload);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text(
          '用藥影像紀錄',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<File>>(
        future: _images,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            );
          }
          if (snapshot.hasError) {
            return _AlbumMessage(
              icon: Icons.error_outline,
              title: '無法讀取影像紀錄',
              subtitle: snapshot.error.toString(),
            );
          }

          final images = snapshot.data ?? const <File>[];
          if (images.isEmpty) {
            return const _AlbumMessage(
              icon: Icons.photo_library_outlined,
              title: '目前沒有影像紀錄',
              subtitle: '拍攝或從手機相簿匯入藥單、藥盒、保健食品後，會自動保存在這裡。',
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(_reload),
            color: const Color(0xFF2E7D32),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openImage(image),
                    onLongPress: () => _deleteImage(image),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFFE0E0E0),
                              child: Icon(Icons.broken_image, size: 48),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _formatDate(image.lastModifiedSync()),
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return '${date.year}/${twoDigits(date.month)}/${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}';
  }
}

class _StoredImagePage extends StatelessWidget {
  final File image;

  const _StoredImagePage({required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: const Text('影像紀錄'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Center(child: Image.file(image, fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScanPage(initialImage: image),
                      ),
                    );
                  },
                  icon: const Icon(Icons.document_scanner_outlined),
                  label: const Text('辨識這張圖片', style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AlbumMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: const Color(0xFF81C784)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
