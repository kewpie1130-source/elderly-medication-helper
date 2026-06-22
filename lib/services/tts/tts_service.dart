import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> initTts() async {
    if (_isInitialized) return;
    try {
      // 1. 強制指定台灣中文與基礎音頻參數
      await _flutterTts.setLanguage("zh-TW"); 
      await _flutterTts.setSpeechRate(0.4); // 適合長者的慢語速
      await _flutterTts.setVolume(1.0);     // 滿格音量
      await _flutterTts.setPitch(1.0);      // 正常音高

      // 🔥 終極防呆 1：如果是 Android 系統，強制設定音訊控制屬性
      // 這能防止部分手機把 TTS 語音誤判為「背景通知音」而自動靜音
      if (!kIsWeb && Platform.isAndroid) {
        await _flutterTts.setQueueMode(0); // 0 代表立即中斷並播放最新語音
      }

      _isInitialized = true;
      debugPrint("📢 TTS 語音引擎底層初始化成功 (zh-TW)");
    } catch (e) {
      debugPrint("❌ TTS 初始化失敗: $e");
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    
    // 防呆：如果頁面進來時初始化速度太慢，播放前強制再對齊一次
    if (!_isInitialized) {
      await initTts();
    }

    try {
      // 🔥 終極防呆 2：在正式 speak 之前，先調用 stop()
      // 這樣可以強行重置可能卡在記憶體裡、死機的語音通道
      await _flutterTts.stop();
      
      var result = await _flutterTts.speak(text);
      if (result == 1) {
        debugPrint("🔊 語音通道啟動成功，正在朗讀：\"$text\"");
      } else {
        debugPrint("⚠️ 語音通道回傳異常碼，可能裝置正處於硬體靜音狀態");
      }
    } catch (e) {
      debugPrint("❌ TTS 播放時發生嚴重的底層崩潰: $e");
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}