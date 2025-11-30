import 'package:flutter_tts/flutter_tts.dart';

/// TTS (Text-to-Speech) 介面
///
/// 提供語音播報功能的抽象層，方便測試時 mock
abstract class TtsInterface {
  Future<void> initialize();
  Future<void> speak(String text);
  Future<void> stop();
  Future<void> pause();
  Future<void> setSpeechRate(double rate);
  Future<void> setVolume(double volume);
  Future<void> setPitch(double pitch);
  Future<List<String>> getLanguages();
  Future<void> setLanguage(String language);
}

/// FlutterTts 的封裝實作
class FlutterTtsWrapper implements TtsInterface {
  final FlutterTts _flutterTts = FlutterTts();

  @override
  Future<void> initialize() async {
    // 初始化邏輯在 TtsService 中處理
  }

  @override
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  @override
  Future<void> pause() async {
    await _flutterTts.pause();
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  @override
  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  @override
  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  @override
  Future<List<String>> getLanguages() async {
    final languages = await _flutterTts.getLanguages;
    return List<String>.from(languages);
  }

  @override
  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  /// 設置 iOS 音頻類別
  Future<void> setIosAudioCategory(
    IosTextToSpeechAudioCategory category,
    List<IosTextToSpeechAudioCategoryOptions> options,
    IosTextToSpeechAudioMode mode,
  ) async {
    await _flutterTts.setIosAudioCategory(category, options, mode);
  }

  /// 設置 iOS 共享實例
  Future<void> setSharedInstance(bool shared) async {
    await _flutterTts.setSharedInstance(shared);
  }
}
