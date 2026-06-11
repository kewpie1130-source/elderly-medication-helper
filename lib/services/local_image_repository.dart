import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class LocalImageRepository {
  static const _albumDirectoryName = 'medication_images';

  Future<Directory> _albumDirectory() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final albumDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}$_albumDirectoryName',
    );

    if (!await albumDirectory.exists()) {
      await albumDirectory.create(recursive: true);
    }

    return albumDirectory;
  }

  Future<File> save(File source) async {
    final albumDirectory = await _albumDirectory();
    final extension = _extensionFrom(source.path);
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final destination = File(
      '${albumDirectory.path}${Platform.pathSeparator}'
      'medication_$timestamp$extension',
    );

    return source.copy(destination.path);
  }

  Future<File> saveBytes(Uint8List bytes, String fileName) async {
    final albumDirectory = await _albumDirectory();
    final destination = File(
      '${albumDirectory.path}${Platform.pathSeparator}$fileName',
    );
    if (!await destination.exists()) {
      await destination.writeAsBytes(bytes, flush: true);
    }
    return destination;
  }

  Future<List<File>> getAll() async {
    final albumDirectory = await _albumDirectory();
    final files = await albumDirectory
        .list()
        .where((entity) => entity is File && _isSupportedImage(entity.path))
        .cast<File>()
        .toList();

    files.sort(
      (first, second) =>
          second.lastModifiedSync().compareTo(first.lastModifiedSync()),
    );
    return files;
  }

  Future<void> delete(File image) async {
    if (await image.exists()) {
      await image.delete();
    }
  }

  String _extensionFrom(String path) {
    final fileName = path.split(RegExp(r'[/\\]')).last;
    final dotIndex = fileName.lastIndexOf('.');
    if (dotIndex == -1) return '.jpg';

    final extension = fileName.substring(dotIndex).toLowerCase();
    return _isSupportedImage(extension) ? extension : '.jpg';
  }

  bool _isSupportedImage(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.endsWith('.jpg') ||
        lowerPath.endsWith('.jpeg') ||
        lowerPath.endsWith('.png') ||
        lowerPath.endsWith('.webp') ||
        lowerPath.endsWith('.heic');
  }
}
