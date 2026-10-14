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
    required this.onNewFolder,
    this.narrow = false,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onNewVocab;
  final VoidCallback onNewFolder;
  final bool narrow;

  static const searchWidth = 750.0;

  @override
  Widget build(BuildContext context) {
    if (narrow) {
      return _NarrowHeader(
        onMenuPressed: onMenuPressed,
        onNewVocab: onNewVocab,
        onNewFolder: onNewFolder,
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
                child: _HeaderActions(
                  onNewVocab: onNewVocab,
                  onNewFolder: onNewFolder,
                ),
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
  const _NarrowHeader({
    required this.onMenuPressed,
    required this.onNewVocab,
    required this.onNewFolder,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback onNewVocab;
  final VoidCallback onNewFolder;

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
        _NewVocabMenu(
          onNewTerm: onNewVocab,
          onNewFolder: onNewFolder,
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
  const _HeaderActions({required this.onNewVocab, required this.onNewFolder});

  final VoidCallback onNewVocab;
  final VoidCallback onNewFolder;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NewVocabMenu(onNewTerm: onNewVocab, onNewFolder: onNewFolder),
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

class _NewVocabMenu extends StatelessWidget {
  const _NewVocabMenu({
    required this.onNewTerm,
    required this.onNewFolder,
    this.expand = false,
  });

  final VoidCallback onNewTerm;
  final VoidCallback onNewFolder;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final localizations = AppLocalizations.of(context);
    return MenuAnchor(
      alignmentOffset: const Offset(0, 8),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(colors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shadowColor: const WidgetStatePropertyAll(Color(0x33101828)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(vertical: 8),
        ),
      ),
      menuChildren: [
        MenuItemButton(
          key: const Key('new-vocab-term'),
          onPressed: onNewTerm,
          leadingIcon: Icon(
            Icons.menu_book_outlined,
            size: 22,
            color: colors.ink,
          ),
          child: Text(
            localizations.newTerm,
            style: HomeText.of(context).subtitle,
          ),
        ),
        Divider(height: 1, thickness: 1, color: colors.border),
        MenuItemButton(
          key: const Key('new-vocab-folder'),
          onPressed: onNewFolder,
          leadingIcon: Icon(Icons.folder_outlined, size: 22, color: colors.ink),
          child: Text(
            localizations.newFolder,
            style: HomeText.of(context).subtitle,
          ),
        ),
      ],
      builder: (context, controller, child) {
        return _NewVocabButton(
          label: localizations.newVocab,
          expand: expand,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
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

Future<String?> showNewFolderDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _NewFolderDialog(),
  );
}

class _NewFolderDialog extends StatefulWidget {
  const _NewFolderDialog();

  @override
  State<_NewFolderDialog> createState() => _NewFolderDialogState();
}

class _NewFolderDialogState extends State<_NewFolderDialog> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _create() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final text = HomeText.of(context);
    final localizations = AppLocalizations.of(context);
    return Dialog(
      alignment: Alignment.center,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(localizations.newFolder, style: text.heading),
            const SizedBox(height: 16),
            TextField(
              key: const Key('new-folder-name'),
              controller: _name,
              autofocus: true,
              style: text.subtitle,
              onSubmitted: (_) => _create(),
              decoration: InputDecoration(
                hintText: localizations.newFolderHint,
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: const Key('new-folder-cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(foregroundColor: colors.text),
                  child: Text(localizations.cancelAction, style: text.subtitle),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  key: const Key('new-folder-create'),
                  onPressed: _create,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.newVocab,
                    foregroundColor: colors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: text.subtitle.copyWith(color: colors.onAccent),
                  ),
                  child: Text(localizations.createFolder),
                ),
              ],
            ),
          ],
        ),
      ),
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
