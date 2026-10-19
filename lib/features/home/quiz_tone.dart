import 'package:audioplayers/audioplayers.dart';

/// A short Quiz result tone. [high] is the correct answer and [low] is wrong.
enum QuizTonePitch { high, low }

abstract class QuizTone {
  Future<void> play(QuizTonePitch pitch);
}

class RecordingQuizTone implements QuizTone {
  final pitches = <QuizTonePitch>[];

  @override
  Future<void> play(QuizTonePitch pitch) async {
    pitches.add(pitch);
  }
}

class AssetQuizTone implements QuizTone {
  AssetQuizTone({Future<void> Function(String asset)? playAsset})
    : _playAsset = playAsset ?? _playFile;

  static const highAsset = 'sounds/quiz_correct.wav';
  static const lowAsset = 'sounds/quiz_wrong.wav';

  final Future<void> Function(String asset) _playAsset;

  static Future<void> _playFile(String asset) async {
    final player = AudioPlayer();
    try {
      await player.play(AssetSource(asset));
      player.onPlayerComplete.first.whenComplete(player.dispose);
    } catch (_) {
      await player.dispose();
      rethrow;
    }
  }

  @override
  Future<void> play(QuizTonePitch pitch) async {
    final asset = switch (pitch) {
      QuizTonePitch.high => highAsset,
      QuizTonePitch.low => lowAsset,
    };
    try {
      await _playAsset(asset);
    } catch (_) {}
  }
}
