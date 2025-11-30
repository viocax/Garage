import 'package:flutter/foundation.dart';
import 'package:garage/core/service/tts/tts_interface.dart';

/// Mock TTS 實作，用於測試
class MockTts implements TtsInterface {
  final List<String> spokenTexts = [];
  bool isStopped = false;
  bool isPaused = false;
  double speechRate = 0.5;
  double volume = 1.0;
  double pitch = 1.0;
  String language = 'zh-TW';

  @override
  Future<void> initialize() async {
    debugPrint('MockTts: initialize called');
  }

  @override
  Future<void> speak(String text) async {
    spokenTexts.add(text);
    isStopped = false;
    isPaused = false;
    debugPrint('MockTts: speak - $text');
  }

  @override
  Future<void> stop() async {
    isStopped = true;
    isPaused = false;
    debugPrint('MockTts: stop called');
  }

  @override
  Future<void> pause() async {
    isPaused = true;
    debugPrint('MockTts: pause called');
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    speechRate = rate;
    debugPrint('MockTts: setSpeechRate - $rate');
  }

  @override
  Future<void> setVolume(double volume) async {
    this.volume = volume;
    debugPrint('MockTts: setVolume - $volume');
  }

  @override
  Future<void> setPitch(double pitch) async {
    this.pitch = pitch;
    debugPrint('MockTts: setPitch - $pitch');
  }

  @override
  Future<List<String>> getLanguages() async {
    return ['zh-TW', 'en-US', 'ja-JP'];
  }

  @override
  Future<void> setLanguage(String language) async {
    this.language = language;
    debugPrint('MockTts: setLanguage - $language');
  }

  /// 清除記錄
  void clear() {
    spokenTexts.clear();
    isStopped = false;
    isPaused = false;
  }
}
