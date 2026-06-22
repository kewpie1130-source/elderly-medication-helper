import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("相簿")),
      body: const Center(
        child: Text("相簿內容展示區"),
      ),
    );
  }
}
