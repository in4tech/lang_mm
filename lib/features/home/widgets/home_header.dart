import 'package:flutter/material.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/theme/home_palette.dart';
import 'package:lang/theme/home_text.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/language/language_switcher.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onMenuPressed,
    required this.onNewVocab,
    this.narrow = false,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onNewVocab;
  final bool narrow;

  static const searchWidth = 750.0;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return _NarrowHeader(
        onMenuPressed: onMenuPressed,
        onNewVocab: onNewVocab,
      );
    }
    final localizations = AppLocalizations.of(context);
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              _Brand(onMenuPressed: onMenuPressed),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _HeaderActions(onNewVocab: onNewVocab),
              ),
            ],
          ),
          SizedBox(
            width: searchWidth,
            child: _SearchField(hint: localizations.searchHint),
          ),
        ],
      ),
    );
  }
}

class _NarrowHeader extends StatelessWidget {
  const _NarrowHeader({required this.onMenuPressed, required this.onNewVocab});

  final VoidCallback onMenuPressed;
  final VoidCallback onNewVocab;

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
              icon: Icon(Icons.menu, color: HomePalette.of(context).ink),
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
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: HomeHeader.searchWidth),
            child: SizedBox(
              width: double.infinity,
              child: _SearchField(hint: localizations.searchHint),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _NewVocabButton(
          label: localizations.newVocab,
          onPressed: onNewVocab,
          expand: true,
        ),
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
              icon: Icon(Icons.menu, color: HomePalette.of(context).ink),
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

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({required this.onNewVocab});

  final VoidCallback onNewVocab;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NewVocabButton(label: localizations.newVocab, onPressed: onNewVocab),
        const SizedBox(width: 24),
        const LanguageSwitcher(child: _Avatar()),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: text.subtitle.copyWith(color: colors.placeholder),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(Icons.search, size: 28, color: colors.text),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border, width: 2),
        ),
      ),
    );
  }
}

class _NewVocabButton extends StatelessWidget {
  const _NewVocabButton({
    required this.label,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: colors.newVocab,
        foregroundColor: colors.onAccent,
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
