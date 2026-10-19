import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/quiz_tone.dart';

void main() {
  test(
    'correct records the high tone and wrong records the low tone',
    () async {
      final tone = RecordingQuizTone();

      await tone.play(QuizTonePitch.high);
      await tone.play(QuizTonePitch.low);

      expect(tone.pitches, <QuizTonePitch>[
        QuizTonePitch.high,
        QuizTonePitch.low,
      ]);
    },
  );

  test('a failed play does not throw', () async {
    final tone = AssetQuizTone(
      playAsset: (asset) async {
        throw StateError(asset);
      },
    );

    await tone.play(QuizTonePitch.high);
    await tone.play(QuizTonePitch.low);
  });
}
