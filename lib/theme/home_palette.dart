import 'package:flutter/material.dart';

@immutable
class HomePalette extends ThemeExtension<HomePalette> {
  const HomePalette({
    required this.border,
    required this.selectedFill,
    required this.selectedSetFill,
    required this.selected,
    required this.text,
    required this.ink,
    required this.newVocab,
    required this.practice,
    required this.continueStart,
    required this.continueEnd,
    required this.folderFill,
    required this.placeholder,
    required this.chip,
    required this.toggleKnob,
    required this.scrollTrack,
    required this.scrollThumb,
    required this.chevronFill,
    required this.muted,
    required this.page,
    required this.surface,
    required this.onAccent,
  });

  final Color border;
  final Color selectedFill;
  final Color selectedSetFill;
  final Color selected;
  final Color text;
  final Color ink;
  final Color newVocab;
  final Color practice;
  final Color continueStart;
  final Color continueEnd;
  final Color folderFill;
  final Color placeholder;
  final Color chip;
  final Color toggleKnob;
  final Color scrollTrack;
  final Color scrollThumb;
  final Color chevronFill;
  final Color muted;
  final Color page;
  final Color surface;
  final Color onAccent;

  static const light = HomePalette(
    border: Color(0xFFD0D5DD),
    selectedFill: Color(0xFFE4ECFA),
    selectedSetFill: Color(0xFFD1E9FF),
    selected: Color(0xFF2E76C9),
    text: Color(0xFF344054),
    ink: Color(0xFF000000),
    newVocab: Color(0xFF022A8C),
    practice: Color(0xFF0051FF),
    continueStart: Color(0xFF0063CC),
    continueEnd: Color(0xFF0033CC),
    folderFill: Color(0xFFF2F4F7),
    placeholder: Color(0xFFD0D5DD),
    chip: Color(0xFFFAF6F2),
    toggleKnob: Color(0xFF1B4B8D),
    scrollTrack: Color(0xFFEAECF0),
    scrollThumb: Color(0xFF0033CC),
    chevronFill: Color(0xFFEAECF0),
    muted: Color(0xFF98A2B3),
    page: Colors.white,
    surface: Colors.white,
    onAccent: Colors.white,
  );

  static HomePalette of(BuildContext context) {
    return Theme.of(context).extension<HomePalette>() ?? light;
  }

  static const dark = HomePalette(
    border: Color(0xFF344054),
    selectedFill: Color(0xFF102A43),
    selectedSetFill: Color(0xFF1849A9),
    selected: Color(0xFF84CAFF),
    text: Color(0xFFD0D5DD),
    ink: Color(0xFFF5F8FF),
    newVocab: Color(0xFF3B6FE0),
    practice: Color(0xFF2E90FA),
    continueStart: Color(0xFF2E90FA),
    continueEnd: Color(0xFF175CD3),
    folderFill: Color(0xFF182230),
    placeholder: Color(0xFF667085),
    chip: Color(0xFF1D2939),
    toggleKnob: Color(0xFF84CAFF),
    scrollTrack: Color(0xFF344054),
    scrollThumb: Color(0xFF2E90FA),
    chevronFill: Color(0xFF344054),
    muted: Color(0xFF98A2B3),
    page: Color(0xFF0C111D),
    surface: Color(0xFF1D2939),
    onAccent: Colors.white,
  );

  @override
  HomePalette copyWith({
    Color? border,
    Color? selectedFill,
    Color? selectedSetFill,
    Color? selected,
    Color? text,
    Color? ink,
    Color? newVocab,
    Color? practice,
    Color? continueStart,
    Color? continueEnd,
    Color? folderFill,
    Color? placeholder,
    Color? chip,
    Color? toggleKnob,
    Color? scrollTrack,
    Color? scrollThumb,
    Color? chevronFill,
    Color? muted,
    Color? page,
    Color? surface,
    Color? onAccent,
  }) {
    return HomePalette(
      border: border ?? this.border,
      selectedFill: selectedFill ?? this.selectedFill,
      selectedSetFill: selectedSetFill ?? this.selectedSetFill,
      selected: selected ?? this.selected,
      text: text ?? this.text,
      ink: ink ?? this.ink,
      newVocab: newVocab ?? this.newVocab,
      practice: practice ?? this.practice,
      continueStart: continueStart ?? this.continueStart,
      continueEnd: continueEnd ?? this.continueEnd,
      folderFill: folderFill ?? this.folderFill,
      placeholder: placeholder ?? this.placeholder,
      chip: chip ?? this.chip,
      toggleKnob: toggleKnob ?? this.toggleKnob,
      scrollTrack: scrollTrack ?? this.scrollTrack,
      scrollThumb: scrollThumb ?? this.scrollThumb,
      chevronFill: chevronFill ?? this.chevronFill,
      muted: muted ?? this.muted,
      page: page ?? this.page,
      surface: surface ?? this.surface,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  HomePalette lerp(ThemeExtension<HomePalette>? other, double t) {
    if (other is! HomePalette) {
      return this;
    }
    return HomePalette(
      border: Color.lerp(border, other.border, t)!,
      selectedFill: Color.lerp(selectedFill, other.selectedFill, t)!,
      selectedSetFill: Color.lerp(selectedSetFill, other.selectedSetFill, t)!,
      selected: Color.lerp(selected, other.selected, t)!,
      text: Color.lerp(text, other.text, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      newVocab: Color.lerp(newVocab, other.newVocab, t)!,
      practice: Color.lerp(practice, other.practice, t)!,
      continueStart: Color.lerp(continueStart, other.continueStart, t)!,
      continueEnd: Color.lerp(continueEnd, other.continueEnd, t)!,
      folderFill: Color.lerp(folderFill, other.folderFill, t)!,
      placeholder: Color.lerp(placeholder, other.placeholder, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      toggleKnob: Color.lerp(toggleKnob, other.toggleKnob, t)!,
      scrollTrack: Color.lerp(scrollTrack, other.scrollTrack, t)!,
      scrollThumb: Color.lerp(scrollThumb, other.scrollThumb, t)!,
      chevronFill: Color.lerp(chevronFill, other.chevronFill, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      page: Color.lerp(page, other.page, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
