import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/service/tts/tts_service.dart';
import '../../../mock/mock_tts.dart';

void main() {
  group('TtsService', () {
    late MockTts mockTts;
    late TtsService ttsService;

    setUp(() {
      mockTts = MockTts();
      ttsService = TtsService(tts: mockTts);
    });

    tearDown(() {
      mockTts.clear();
    });

    group('speak', () {
      test('should speak the given text', () async {
        // Arrange
        const text = '前方測速照相';

        // Act
        await ttsService.speak(text);

        // Assert
        expect(mockTts.spokenTexts, contains(text));
        expect(mockTts.spokenTexts.length, 1);
      });

      test('should initialize before speaking if not initialized', () async {
        // Arrange
        const text = '測試語音';

        // Act
        await ttsService.speak(text);

        // Assert
        expect(mockTts.language, 'zh-TW');
        expect(mockTts.speechRate, 0.5);
        expect(mockTts.volume, 1.0);
        expect(mockTts.pitch, 1.0);
        expect(mockTts.spokenTexts, contains(text));
      });

      test('should speak multiple texts in sequence', () async {
        // Arrange
        const text1 = '前方測速照相';
        const text2 = '請減速慢行';

        // Act
        await ttsService.speak(text1);
        await ttsService.speak(text2);

        // Assert
        expect(mockTts.spokenTexts.length, 2);
        expect(mockTts.spokenTexts[0], text1);
        expect(mockTts.spokenTexts[1], text2);
      });
    });

    group('stop', () {
      test('should stop the speech', () async {
        // Arrange
        await ttsService.speak('測試');

        // Act
        await ttsService.stop();

        // Assert
        expect(mockTts.isStopped, true);
        expect(mockTts.isPaused, false);
      });
    });

    group('pause', () {
      test('should pause the speech', () async {
        // Arrange
        await ttsService.speak('測試');

        // Act
        await ttsService.pause();

        // Assert
        expect(mockTts.isPaused, true);
      });
    });

    group('setSpeechRate', () {
      test('should set speech rate within valid range', () async {
        // Arrange
        const rate = 0.7;

        // Act
        await ttsService.setSpeechRate(rate);

        // Assert
        expect(mockTts.speechRate, rate);
      });

      test('should clamp speech rate to minimum 0.0', () async {
        // Arrange
        const rate = -0.5;

        // Act
        await ttsService.setSpeechRate(rate);

        // Assert
        expect(mockTts.speechRate, 0.0);
      });

      test('should clamp speech rate to maximum 1.0', () async {
        // Arrange
        const rate = 1.5;

        // Act
        await ttsService.setSpeechRate(rate);

        // Assert
        expect(mockTts.speechRate, 1.0);
      });
    });

    group('setVolume', () {
      test('should set volume within valid range', () async {
        // Arrange
        const volume = 0.8;

        // Act
        await ttsService.setVolume(volume);

        // Assert
        expect(mockTts.volume, volume);
      });

      test('should clamp volume to minimum 0.0', () async {
        // Arrange
        const volume = -0.5;

        // Act
        await ttsService.setVolume(volume);

        // Assert
        expect(mockTts.volume, 0.0);
      });

      test('should clamp volume to maximum 1.0', () async {
        // Arrange
        const volume = 2.0;

        // Act
        await ttsService.setVolume(volume);

        // Assert
        expect(mockTts.volume, 1.0);
      });
    });

    group('setPitch', () {
      test('should set pitch within valid range', () async {
        // Arrange
        const pitch = 1.2;

        // Act
        await ttsService.setPitch(pitch);

        // Assert
        expect(mockTts.pitch, pitch);
      });

      test('should clamp pitch to minimum 0.5', () async {
        // Arrange
        const pitch = 0.3;

        // Act
        await ttsService.setPitch(pitch);

        // Assert
        expect(mockTts.pitch, 0.5);
      });

      test('should clamp pitch to maximum 2.0', () async {
        // Arrange
        const pitch = 3.0;

        // Act
        await ttsService.setPitch(pitch);

        // Assert
        expect(mockTts.pitch, 2.0);
      });
    });

    group('setLanguage', () {
      test('should set language', () async {
        // Arrange
        const language = 'en-US';

        // Act
        await ttsService.setLanguage(language);

        // Assert
        expect(mockTts.language, language);
      });
    });

    group('getLanguages', () {
      test('should return available languages', () async {
        // Act
        final languages = await ttsService.getLanguages();

        // Assert
        expect(languages, isNotEmpty);
        expect(languages, contains('zh-TW'));
      });
    });

    group('initialize', () {
      test('should initialize with default settings', () async {
        // Act
        await ttsService.initialize();

        // Assert
        expect(mockTts.language, 'zh-TW');
        expect(mockTts.speechRate, 0.5);
        expect(mockTts.volume, 1.0);
        expect(mockTts.pitch, 1.0);
      });

      test('should only initialize once', () async {
        // Act
        await ttsService.initialize();
        await ttsService.initialize();

        // Assert - 如果初始化兩次，語言應該還是 zh-TW
        expect(mockTts.language, 'zh-TW');
      });
    });

    group('dispose', () {
      test('should stop speech and reset initialization flag', () async {
        // Arrange
        await ttsService.speak('測試');

        // Act
        await ttsService.dispose();

        // Assert
        expect(mockTts.isStopped, true);
      });
    });

    group('integration scenarios', () {
      test('should handle speed camera alert scenario', () async {
        // Arrange
        const distance = 500;
        const speedLimit = 60;

        // Act
        await ttsService.speak('前方 $distance 公尺有測速照相');
        await ttsService.speak('限速 $speedLimit 公里');

        // Assert
        expect(mockTts.spokenTexts.length, 2);
        expect(mockTts.spokenTexts[0], '前方 500 公尺有測速照相');
        expect(mockTts.spokenTexts[1], '限速 60 公里');
      });

      test('should handle overspeed warning scenario', () async {
        // Act
        await ttsService.speak('您已超速');
        await ttsService.speak('請減速慢行');

        // Assert
        expect(mockTts.spokenTexts.length, 2);
        expect(mockTts.spokenTexts, contains('您已超速'));
        expect(mockTts.spokenTexts, contains('請減速慢行'));
      });

      test('should allow stopping during speech', () async {
        // Act
        await ttsService.speak('這是一段很長的語音播報');
        await ttsService.stop();

        // Assert
        expect(mockTts.isStopped, true);
        expect(mockTts.spokenTexts.length, 1);
      });
    });
  });
}
