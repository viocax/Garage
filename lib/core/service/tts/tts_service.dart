import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:garage/core/models/tts_speaking_token.dart';
import 'package:garage/core/utils/auto_release_queue.dart';
import 'tts_interface.dart';

/// TTS (Text-to-Speech) 服務
///
/// 提供語音播報功能，用於測速照相提示等場景
class TtsService {
  final TtsInterface tts;
  bool _isInitialized = false;

  /// TTS 播報隊列，確保播報按順序執行，不會重疊
  final AutoReleaseQueue _speakQueue = AutoReleaseQueue();

  TtsService({TtsInterface? tts}) : tts = tts ?? FlutterTtsWrapper();

  /// 初始化 TTS 引擎
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 設置語言為繁體中文
      await tts.setLanguage('zh-TW');

      // 設置語速 (0.0 - 1.0，預設 0.5)
      await tts.setSpeechRate(0.5);

      // 設置音量 (0.0 - 1.0，預設 1.0)
      await tts.setVolume(1.0);

      // 設置音調 (0.5 - 2.0，預設 1.0)
      await tts.setPitch(1.0);

      // iOS 特定設置
      if (defaultTargetPlatform == TargetPlatform.iOS &&
          tts is FlutterTtsWrapper) {
        final wrapper = tts as FlutterTtsWrapper;
        await wrapper.setSharedInstance(true);
        await wrapper.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      }

      _isInitialized = true;
      debugPrint('TtsService: 初始化成功');
    } catch (e) {
      debugPrint('TtsService: 初始化失敗 - $e');
      rethrow;
    }
  }

  /// 播報文字
  ///
  /// [text] 要播報的文字內容
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      debugPrint('TtsService: 播報 - $text');
      await tts.speak(text);
    } catch (e) {
      debugPrint('TtsService: 播報失敗 - $e');
    }
  }

  /// 播報超速警告
  ///
  /// [token] TTS播報令牌，包含速度、限速、距離等資訊
  /// 使用隊列機制確保播報按順序執行，不會重疊
  void speakOverSpeed(TTSSpeakingToken token) {
    // 創建帶有執行邏輯的 token 並放入隊列
    if (_speakQueue.lastItem is TTSSpeakingToken) {
      final lastToken = _speakQueue.lastItem as TTSSpeakingToken;
      if (lastToken.shouldSpeak(token) == false) {
        return;
      }
    }
    final executableToken = token.copyWith(
      onExecute: (t) async {
        if (!_isInitialized) {
          await initialize();
        }

        try {
          // TODO: unit, 語音 要根據user設定去切換
          final text = '超速警告，前方 ${t.distance.toStringAsFixed(0)} 公尺，'
              '限速 ${t.speedLimit.toStringAsFixed(0)} 公里，'
              '目前速度 ${t.currentSpeed.toStringAsFixed(0)} 公里';

          debugPrint('TtsService: 播報超速警告 - $text');
          await tts.speak(text);
        } catch (e) {
          debugPrint('TtsService: 播報超速警告失敗 - $e');
        }
      },
    );

    // 將 token 加入隊列，確保順序執行
    _speakQueue.enqueue(executableToken);
  }

  /// 停止播報
  Future<void> stop() async {
    try {
      await tts.stop();
      debugPrint('TtsService: 停止播報');
    } catch (e) {
      debugPrint('TtsService: 停止失敗 - $e');
    }
  }

  /// 暫停播報
  Future<void> pause() async {
    try {
      await tts.pause();
      debugPrint('TtsService: 暫停播報');
    } catch (e) {
      debugPrint('TtsService: 暫停失敗 - $e');
    }
  }

  /// 設置語速
  ///
  /// [rate] 語速 (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    try {
      await tts.setSpeechRate(rate.clamp(0.0, 1.0));
      debugPrint('TtsService: 設置語速 - $rate');
    } catch (e) {
      debugPrint('TtsService: 設置語速失敗 - $e');
    }
  }

  /// 設置音量
  ///
  /// [volume] 音量 (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await tts.setVolume(volume.clamp(0.0, 1.0));
      debugPrint('TtsService: 設置音量 - $volume');
    } catch (e) {
      debugPrint('TtsService: 設置音量失敗 - $e');
    }
  }

  /// 設置音調
  ///
  /// [pitch] 音調 (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    try {
      await tts.setPitch(pitch.clamp(0.5, 2.0));
      debugPrint('TtsService: 設置音調 - $pitch');
    } catch (e) {
      debugPrint('TtsService: 設置音調失敗 - $e');
    }
  }

  /// 獲取可用語言列表
  Future<List<String>> getLanguages() async {
    try {
      return await tts.getLanguages();
    } catch (e) {
      debugPrint('TtsService: 獲取語言列表失敗 - $e');
      return [];
    }
  }

  /// 設置語言
  ///
  /// [language] 語言代碼 (例如: 'zh-TW', 'en-US')
  Future<void> setLanguage(String language) async {
    try {
      await tts.setLanguage(language);
      debugPrint('TtsService: 設置語言 - $language');
    } catch (e) {
      debugPrint('TtsService: 設置語言失敗 - $e');
    }
  }

  /// 釋放資源
  Future<void> dispose() async {
    try {
      await tts.stop();
      _isInitialized = false;
      debugPrint('TtsService: 資源已釋放');
    } catch (e) {
      debugPrint('TtsService: 釋放資源失敗 - $e');
    }
  }
}
