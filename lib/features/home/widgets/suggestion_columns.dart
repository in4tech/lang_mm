import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lang/features/home/suggestions/suggestion_templates.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';

class SuggestionColumns extends StatefulWidget {
  const SuggestionColumns({super.key, this.narrow = false});

  final bool narrow;

  @override
  State<SuggestionColumns> createState() => _SuggestionColumnsState();
}

class _SuggestionColumnsState extends State<SuggestionColumns> {
  var _packIndex = 0;
  late String _featuredTerm = SuggestionTemplates.packs[_packIndex].lead.term;

  SuggestionPack get _pack => SuggestionTemplates.packs[_packIndex];

  SuggestionWord get _featured {
    return SuggestionTemplates.wordInPack(_pack, _featuredTerm) ?? _pack.lead;
  }

  void _selectPack(int index, {String? term}) {
    setState(() {
      _packIndex = index;
      _featuredTerm = term ?? SuggestionTemplates.packs[index].lead.term;
    });
  }

  void _selectTerm(String term) {
    final pack = SuggestionTemplates.packForTerm(term);
    if (pack == null) {
      return;
    }
    _selectPack(SuggestionTemplates.packs.indexOf(pack), term: term);
  }

  @override
  Widget build(BuildContext context) {
    final left = _Panel(
      child: _CatalogColumn(
        packIndex: _packIndex,
        onSelectPack: (index) => _selectPack(index),
        onSelectTerm: _selectTerm,
      ),
    );
    final right = _Panel(
      child: _PreviewColumn(
        pack: _pack,
        featured: _featured,
        onSelectTerm: (term) => setState(() => _featuredTerm = term),
        onSelectPractice: _selectTerm,
      ),
    );
    if (widget.narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, const SizedBox(height: 16), right],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 5, child: left),
        const SizedBox(width: 16),
        Expanded(flex: 6, child: right),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: child,
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: HomeText.of(context).caption.copyWith(
        color: HomePalette.of(context).muted,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _CatalogColumn extends StatelessWidget {
  const _CatalogColumn({
    required this.packIndex,
    required this.onSelectPack,
    required this.onSelectTerm,
  });

  final int packIndex;
  final ValueChanged<int> onSelectPack;
  final ValueChanged<String> onSelectTerm;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(localizations.hotSearch),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final chip in SuggestionTemplates.chips)
              _Pill(
                key: Key('hot-chip-$chip'),
                label: chip,
                onTap: () => onSelectTerm(chip),
              ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          localizations.suggestedSets,
          style: HomeText.of(context).heading,
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < SuggestionTemplates.packs.length; index++)
          Padding(
            padding: EdgeInsets.only(
              bottom: index == SuggestionTemplates.packs.length - 1 ? 0 : 8,
            ),
            child: _PackTile(
              key: Key('suggestion-set-$index'),
              title: SuggestionTemplates.packs[index].title,
              count: SuggestionTemplates.packs[index].wordCountLabel,
              selected: index == packIndex,
              onTap: () => onSelectPack(index),
              fill: colors.selectedFill,
              border: colors.border,
              accent: colors.selected,
              muted: colors.muted,
            ),
          ),
      ],
    );
  }
}

class _PreviewColumn extends StatelessWidget {
  const _PreviewColumn({
    required this.pack,
    required this.featured,
    required this.onSelectTerm,
    required this.onSelectPractice,
  });

  final SuggestionPack pack;
  final SuggestionWord featured;
  final ValueChanged<String> onSelectTerm;
  final ValueChanged<String> onSelectPractice;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.folderFill,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pack.title,
                  style: text.caption.copyWith(
                    color: colors.selected,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        featured.term,
                        style: text.title.copyWith(fontSize: 28),
                      ),
                    ),
                    _SpeakButton(term: featured.term),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  featured.ukIpa,
                  style: text.body.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  featured.usIpa,
                  style: text.body.copyWith(color: colors.muted),
                ),
                const SizedBox(height: 14),
                Text(featured.gloss, style: text.subtitle),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          pack.title,
          style: text.heading.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0; index < pack.words.length; index++)
              _Pill(
                key: Key('suggestion-term-$index'),
                label: pack.words[index].term,
                selected: pack.words[index].term == featured.term,
                onTap: () => onSelectTerm(pack.words[index].term),
              ),
          ],
        ),
        const SizedBox(height: 26),
        _SectionLabel(localizations.suggestedPractice),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var index = 0;
                index < SuggestionTemplates.practice.length;
                index++)
              _Pill(
                key: Key('suggestion-practice-$index'),
                label: SuggestionTemplates.practice[index],
                onTap: () => onSelectPractice(
                  SuggestionTemplates.packs[index].lead.term,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _PackTile extends StatelessWidget {
  const _PackTile({
    super.key,
    required this.title,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.fill,
    required this.border,
    required this.accent,
    required this.muted,
  });

  final String title;
  final String count;
  final bool selected;
  final VoidCallback onTap;
  final Color fill;
  final Color border;
  final Color accent;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final text = HomeText.of(context);
    return Material(
      color: selected ? fill : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent.withOpacity(0.35) : border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: text.subtitle.copyWith(
                      color: selected ? accent : null,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  count,
                  style: text.caption.copyWith(color: muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeakButton extends StatelessWidget {
  const _SpeakButton({required this.term});

  final String term;

  Future<void> _speak() async {
    final spoken = term.trim();
    if (spoken.isEmpty) {
      return;
    }
    try {
      final speech = FlutterTts();
      await speech.setSpeechRate(0.45);
      await speech.speak(spoken);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return IconButton(
      key: const Key('suggestion-speak'),
      onPressed: _speak,
      tooltip: term,
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      icon: Icon(
        Icons.volume_up_outlined,
        size: 22,
        color: colors.selected,
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return Material(
      color: selected ? colors.selectedFill : colors.folderFill,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: text.body.copyWith(
              color: selected ? colors.selected : colors.text,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
