import 'package:flutter/material.dart';
import 'package:lang/features/home/suggestions/suggestion_templates.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';

class SuggestionColumns extends StatelessWidget {
  const SuggestionColumns({super.key, this.narrow = false});

  final bool narrow;

  @override
  Widget build(BuildContext context) {
    const left = _SuggestionCard(child: _SearchColumn());
    const right = _SuggestionCard(child: _WordColumn());
    if (narrow) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, SizedBox(height: 16), right],
      );
    }
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        SizedBox(width: 16),
        Expanded(child: right),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: HomeColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: child,
      ),
    );
  }
}

class _SearchColumn extends StatelessWidget {
  const _SearchColumn();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(localizations.hotSearch, style: HomeText.heading),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip in SuggestionTemplates.chips) _SearchChip(chip),
          ],
        ),
        const SizedBox(height: 24),
        Text(localizations.suggestedSets, style: HomeText.heading),
        const SizedBox(height: 8),
        for (var index = 0; index < SuggestionTemplates.sets.length; index++)
          _SuggestionRow(
            key: Key('suggestion-set-$index'),
            icon: Icons.menu_book_outlined,
            label: SuggestionTemplates.sets[index],
          ),
      ],
    );
  }
}

class _WordColumn extends StatelessWidget {
  const _WordColumn();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(SuggestionTemplates.word, style: HomeText.title),
        const SizedBox(height: 12),
        const Text(SuggestionTemplates.uk, style: HomeText.body),
        const SizedBox(height: 4),
        const Text(SuggestionTemplates.us, style: HomeText.body),
        const SizedBox(height: 12),
        const Text(SuggestionTemplates.gloss, style: HomeText.body),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              localizations.saveCount(SuggestionTemplates.saveCount),
              style: HomeText.body,
            ),
            const Spacer(),
            FilledButton(
              key: const Key('suggestion-save'),
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: HomeColors.practice,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: Text(localizations.saveWord),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(localizations.suggestedPractice, style: HomeText.heading),
        const SizedBox(height: 8),
        for (
          var index = 0;
          index < SuggestionTemplates.practice.length;
          index++
        )
          _SuggestionRow(
            key: Key('suggestion-practice-$index'),
            icon: Icons.menu_book_outlined,
            label: SuggestionTemplates.practice[index],
          ),
      ],
    );
  }
}

class _SearchChip extends StatelessWidget {
  const _SearchChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key('hot-chip-$label'),
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: HomeColors.text,
        side: const BorderSide(color: HomeColors.border),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: HomeText.body,
      ),
      child: Text(label),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: HomeColors.ink),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: HomeText.body.copyWith(color: HomeColors.ink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
