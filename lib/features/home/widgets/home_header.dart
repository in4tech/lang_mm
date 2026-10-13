import 'package:flutter/material.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/theme/home_colors.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/language_switcher.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.onMenuPressed, this.narrow = false});

  final VoidCallback onMenuPressed;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return _NarrowHeader(onMenuPressed: onMenuPressed);
    }
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Row(
        children: [
          _Brand(onMenuPressed: onMenuPressed),
          const Expanded(child: _SearchAndActions()),
        ],
      ),
    );
  }
}

class _NarrowHeader extends StatelessWidget {
  const _NarrowHeader({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('drawer-menu'),
              onPressed: onMenuPressed,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: const Icon(Icons.menu, color: HomeColors.ink),
            ),
            const SizedBox(width: 8),
            const Image(
              key: Key('header-logo'),
              image: AssetImage('assets/images/lang_logo.png'),
              width: 139,
              height: 48,
            ),
            const Spacer(),
            const LanguageSwitcher(child: _Avatar()),
          ],
        ),
        const SizedBox(height: 12),
        _SearchField(hint: localizations.searchHint),
        const SizedBox(height: 12),
        _NewVocabButton(label: localizations.newVocab, expand: true),
      ],
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand({required this.onMenuPressed});

  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: HomeSidebar.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            IconButton(
              key: const Key('drawer-menu'),
              onPressed: onMenuPressed,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              icon: const Icon(Icons.menu, color: HomeColors.ink),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Image(
                key: Key('header-logo'),
                image: AssetImage('assets/images/lang_logo.png'),
                width: 139,
                height: 48,
              ),
            ),
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
  const _NewVocabButton({required this.label, this.expand = false});

  final String label;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: HomeColors.newVocab,
        foregroundColor: Colors.white,
        minimumSize: Size(expand ? double.infinity : 131, 48),
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
    return ClipOval(
      child: Image.asset(
        'assets/images/avatar.jpg',
        width: 48,
        height: 48,
        fit: BoxFit.cover,
      ),
    );
  }
}
