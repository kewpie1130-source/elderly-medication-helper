import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  // 單例模式 (Singleton)，確保全 App 只有一個 TTS 實例在運作
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  /// 初始化 TTS 設定
  Future<void> initTts() async {
    if (_isInitialized) return;

    try {
      // 1. 設定語言為台灣中文 (zh-TW)
      await _flutterTts.setLanguage("zh-TW");

      // 2. 長者友善設定：調慢語速 (預設通常是 0.5，調成 0.4 讓長者聽得更清楚)
      await _flutterTts.setSpeechRate(0.4);

      // 3. 設定音調 (1.0 為正常音調，通常不需要太高尖，保持沉穩)
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // 4. 針對 iOS 的特殊語音通道設定（避免靜音模式沒聲音）
      if (!kIsWeb && Platform.isIOS) {
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            IosTextToSpeechAudioCategoryOptions.allowBluetooth
          ],
        );
      }

      _isInitialized = true;
      debugPrint("TTS 語音服務初始化成功 (zh-TW)");
    } catch (e) {
      debugPrint("TTS 初始化失敗: $e");
    }
  }

  /// 語音播報核心方法
  /// [text] 傳入想要讓 App 說出來的白話文字
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initTts();
    }
    
    if (text.isEmpty) return;

    // 先停止上一次還沒說完的話，避免聲音重疊
    await _flutterTts.stop();
    // 開始對長者說話
    await _flutterTts.speak(text);
  }

  /// 停止播報（防呆用，例如長者按了已服藥，就立刻讓聲音閉嘴）
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}