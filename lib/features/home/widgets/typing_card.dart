import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lang/features/home/typing_answer.dart';
import 'package:lang/features/home/widgets/quiz_card.dart';
import 'package:lang/features/word_editor/sentence_format.dart';
import 'package:lang/library/vocabulary_set.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

List<String> typingCueLines(VocabularyWord word) {
  final lines = <String>[
    if (word.ipa.trim().isNotEmpty) word.ipa.trim(),
    if ((word.type ?? '').trim().isNotEmpty) word.type!.trim(),
    if (word.definition.trim().isNotEmpty) word.definition.trim(),
  ];
  final sentence = blankTermInSentence(
    sentencePlain(word.sentence).trim(),
    word.term,
  ).trim();
  if (sentence.isNotEmpty) {
    lines.add(sentence);
  }
  return lines;
}

class TypingCard extends StatefulWidget {
  const TypingCard({
    super.key,
    required this.word,
    required this.controller,
    required this.yourAnswerLabel,
    required this.hint,
    required this.checkLabel,
    required this.dontKnowLabel,
    required this.wrongSentence,
    required this.skipSentence,
    required this.mark,
    required this.onCheck,
    required this.onDontKnow,
    required this.onSettled,
  });

  final VocabularyWord word;
  final TextEditingController controller;
  final String yourAnswerLabel;
  final String hint;
  final String checkLabel;
  final String dontKnowLabel;
  final String wrongSentence;
  final String skipSentence;
  final QuizMark? mark;
  final VoidCallback onCheck;
  final VoidCallback onDontKnow;
  final VoidCallback onSettled;

  @override
  State<TypingCard> createState() => _TypingCardState();
}

class _TypingCardState extends State<TypingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;
  var _played = false;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    widget.controller.addListener(_onTyped);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncReveal();
  }

  @override
  void didUpdateWidget(TypingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTyped);
      widget.controller.addListener(_onTyped);
    }
    if (widget.mark != oldWidget.mark ||
        widget.word.term != oldWidget.word.term) {
      _played = false;
      _syncReveal();
    }
  }

  void _onTyped() {
    if (mounted) {
      setState(() {});
    }
  }

  void _syncReveal() {
    if (widget.mark == null) {
      _reveal.stop();
      _reveal.value = 0;
      _played = false;
      return;
    }
    if (_played) {
      return;
    }
    _played = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _reveal.value = 1;
      return;
    }
    _reveal.forward(from: 0).whenComplete(() {
      if (mounted && widget.mark != null) {
        widget.onSettled();
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTyped);
    _reveal.dispose();
    super.dispose();
  }

  bool get _canCheck {
    return widget.mark == null && widget.controller.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final locked = widget.mark != null;
    final cue = typingCueLines(widget.word);
    final prompt = switch (widget.mark) {
      QuizMark.wrong => widget.wrongSentence,
      QuizMark.skip => widget.skipSentence,
      QuizMark.correct || null => null,
    };
    return Container(
      key: const Key('typing-card'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < cue.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            Text(
              cue[index],
              style: index == 0
                  ? text.title.copyWith(fontWeight: FontWeight.w600)
                  : text.body.copyWith(color: colors.muted),
            ),
          ],
          if (locked) ...[
            const SizedBox(height: 16),
            Text(
              widget.word.term,
              key: const Key('typing-revealed-term'),
              style: text.title.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (prompt != null) ...[
            const SizedBox(height: 16),
            Text(
              prompt,
              style: text.body.copyWith(
                color: widget.mark == QuizMark.wrong
                    ? quizWrongColor
                    : colors.muted,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            widget.yourAnswerLabel,
            style: text.caption.copyWith(color: colors.muted),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('set-study-typing'),
            controller: widget.controller,
            enabled: !locked,
            readOnly: locked,
            style: text.subtitle,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (_canCheck) {
                widget.onCheck();
              }
            },
            inputFormatters: locked
                ? const <TextInputFormatter>[]
                : null,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: text.subtitle.copyWith(color: colors.placeholder),
              filled: true,
              fillColor: colors.folderFill,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) {
                  final revealed = widget.mark != null;
                  final tone = Theme.of(context).colorScheme.primary;
                  return Opacity(
                    opacity: revealed ? 1 - (0.55 * _reveal.value) : 1,
                    child: TextButton(
                      key: const Key('typing-dont-know'),
                      onPressed: revealed ? null : widget.onDontKnow,
                      style: TextButton.styleFrom(
                        disabledForegroundColor: tone,
                      ),
                      child: Text(widget.dontKnowLabel),
                    ),
                  );
                },
              ),
              const Spacer(),
              FilledButton(
                key: const Key('typing-check'),
                onPressed: _canCheck ? widget.onCheck : null,
                style: FilledButton.styleFrom(
                  backgroundColor: colors.practice,
                  foregroundColor: colors.onAccent,
                  minimumSize: const Size(88, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.checkLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
