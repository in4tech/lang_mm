import 'package:flutter/material.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/language_switcher.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 80,
      width: 1440,
      child: Row(
        children: [
          _Brand(),
          Expanded(child: _SearchAndActions()),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 288,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: HomeColors.ink),
              visualDensity: VisualDensity.compact,
            ),
            Image.asset('assets/images/lang_logo.png', width: 139, height: 48),
          ],
        ),
      ),
    );
  }
}

class _SearchAndActions extends StatelessWidget {
  const _SearchAndActions();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 20, 16),
      child: Row(
        children: [
          Expanded(child: _SearchField(hint: localizations.searchHint)),
          const SizedBox(width: 24),
          _NewVocabButton(label: localizations.newVocab),
          const SizedBox(width: 24),
          const LanguageSwitcher(child: _Avatar()),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: HomeText.subtitle.copyWith(color: HomeColors.placeholder),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14),
          child: Icon(Icons.search, size: 28, color: HomeColors.text),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HomeColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HomeColors.border, width: 2),
        ),
      ),
    );
  }
}

class _NewVocabButton extends StatelessWidget {
  const _NewVocabButton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: HomeColors.newVocab,
        foregroundColor: Colors.white,
        minimumSize: const Size(131, 48),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
      child: Text(label),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: HomeColors.avatar,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
