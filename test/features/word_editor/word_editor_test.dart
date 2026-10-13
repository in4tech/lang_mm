import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/word_editor/word_editor.dart';
import 'package:lang/l10n/app_localizations.dart';
import 'package:lang/theme/home_colors.dart';

void main() {
  Future<void> prepareView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> pumpEditor(WidgetTester tester) async {
    await prepareView(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WordEditor(),
      ),
    );
  }

  String fieldText(WidgetTester tester, Key key) {
    return tester.widget<TextField>(find.byKey(key)).controller!.text;
  }

  Material typeChip(WidgetTester tester, String type) {
    return tester.widget<Material>(find.byKey(Key('word-type-$type')));
  }

  Text typeLabel(WidgetTester tester, String type) {
    return tester.widget<Text>(
      find.descendant(
        of: find.byKey(Key('word-type-$type')),
        matching: find.byType(Text),
      ),
    );
  }

  testWidgets('the editor opens on one empty card', (tester) async {
    await pumpEditor(tester);

    expect(fieldText(tester, const Key('word-editor-title')), isEmpty);
    expect(fieldText(tester, const Key('word-editor-description')), isEmpty);
    expect(find.byKey(const Key('word-card-1')), findsOneWidget);
    final addWordCard = tester.widget<Container>(
      find.byKey(const Key('word-card-1')),
    );
    final addWordDecoration = addWordCard.decoration! as BoxDecoration;
    expect(addWordDecoration.color, Colors.white);
    expect(addWordDecoration.boxShadow, isNotEmpty);
    expect(find.byKey(const Key('word-card-2')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(fieldText(tester, const Key('word-term')), isEmpty);
    expect(fieldText(tester, const Key('word-definition')), isEmpty);
    expect(fieldText(tester, const Key('word-sentence')), isEmpty);
    expect(fieldText(tester, const Key('word-ipa')), isEmpty);
    expect(fieldText(tester, const Key('word-singular-plural')), isEmpty);
    expect(fieldText(tester, const Key('word-note')), isEmpty);
    expect(find.text('Enter term'), findsOneWidget);
    expect(find.text('Enter definition'), findsOneWidget);
    expect(find.text('Enter sentence'), findsOneWidget);
    expect(find.text('Enter IPA'), findsOneWidget);
    expect(find.text('Enter singular and plural'), findsOneWidget);
    expect(find.text('Enter a note'), findsOneWidget);
    expect(typeChip(tester, 'chunking').color, Colors.white);
    expect(typeChip(tester, 'noun').color, Colors.white);
    expect(typeChip(tester, 'verb').color, Colors.white);
    expect(typeChip(tester, 'adj').color, Colors.white);
    expect(find.text('ein Kind haben'), findsNothing);
    expect(find.text('have a child'), findsNothing);
    expect(find.text('All posts'), findsOneWidget);
    expect(tester.getSize(find.widgetWithText(FilledButton, 'Done')).height, 44);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Add new word')).height,
      44,
    );
    final import = tester.widget<OutlinedButton>(
      find.byKey(const Key('word-editor-import')),
    );
    final importText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('word-editor-import')),
        matching: find.text('Import'),
      ),
    );
    expect(importText.style?.fontWeight, FontWeight.w700);
    expect(
      import.style?.padding?.resolve(const <WidgetState>{}),
      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
    expect(find.text('Enter your project title...'), findsNothing);
    expect(find.text('Add a discription...'), findsNothing);
    expect(find.byType(HomeHeader), findsNothing);
    expect(find.byType(HomeSidebar), findsNothing);

    for (final label in [
      'All posts',
      'Done',
      'Title',
      'Enter a title...',
      'Add a description...',
      'Import',
      'Term',
      'Definition',
      'Sentence',
      'Details',
      'IPA',
      'Singular - Plural',
      'Note',
      'Type',
      'Chunking',
      'Noun',
      'Verb',
      'Adj',
      'Add new word',
    ]) {
      expect(find.text(label), findsOneWidget, reason: label);
    }

    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

    BoxDecoration fill(Key key) {
      return tester.widget<Container>(find.byKey(key)).decoration!
          as BoxDecoration;
    }

    final titleFill = find.byKey(const Key('word-editor-title-fill'));
    final descriptionFill = find.byKey(
      const Key('word-editor-description-fill'),
    );
    expect(
      fill(const Key('word-editor-title-fill')).color,
      HomeColors.selectedFill,
    );
    expect(
      fill(const Key('word-editor-description-fill')).color,
      HomeColors.selectedFill,
    );
    expect(
      find.descendant(of: titleFill, matching: find.text('Title')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: descriptionFill, matching: find.text('Title')),
      findsNothing,
    );
    final titleLabel = tester.widget<Text>(
      find.descendant(of: titleFill, matching: find.text('Title')),
    );
    expect(titleLabel.style?.color, HomeColors.selected);
    final titleHeight = tester.getSize(titleFill).height;
    final descriptionHeight = tester.getSize(descriptionFill).height;
    expect(titleHeight, lessThan(72));
    expect((titleHeight - descriptionHeight).abs(), lessThan(8));
    final numberCenter = tester.getCenter(find.text('1'));
    final image = find.byKey(const Key('word-card-image-1'));
    final edit = find.byKey(const Key('word-card-edit-1'));
    final trash = find.byKey(const Key('word-card-trash-1'));
    expect((tester.getCenter(image).dy - numberCenter.dy).abs(), lessThan(8));
    expect((tester.getCenter(edit).dy - numberCenter.dy).abs(), lessThan(8));
    expect((tester.getCenter(trash).dy - numberCenter.dy).abs(), lessThan(8));
    expect(tester.getCenter(image).dx, greaterThan(numberCenter.dx));
    expect(tester.getCenter(edit).dx, greaterThan(tester.getCenter(image).dx));
    expect(tester.getCenter(trash).dx, greaterThan(tester.getCenter(edit).dx));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the details arrow folds the fields up and down', (
    tester,
  ) async {
    await pumpEditor(tester);

    expect(find.text('Enter IPA'), findsOneWidget);
    expect(find.text('Enter singular and plural'), findsOneWidget);
    expect(find.text('Enter a note'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);

    final divider = find.byKey(const Key('word-details-divider'));
    final card = find.byKey(const Key('word-card-1'));
    expect(divider, findsOneWidget);
    expect(tester.getSize(divider).width, tester.getSize(card).width - 42);
    expect(
      tester.getTopLeft(divider).dy -
          tester.getBottomLeft(find.byKey(const Key('word-note'))).dy,
      greaterThanOrEqualTo(16),
    );
    expect(
      tester.getCenter(divider).dy,
      greaterThan(tester.getCenter(find.text('Details')).dy),
    );
    expect(
      tester.getCenter(divider).dy,
      lessThan(tester.getCenter(find.text('Type')).dy),
    );

    await tester.enterText(find.byKey(const Key('word-ipa')), '/kaɪnd/');
    await tester.tap(find.byKey(const Key('word-details-toggle')));
    await tester.pump();

    expect(find.text('Enter IPA'), findsNothing);
    expect(find.text('Enter singular and plural'), findsNothing);
    expect(find.text('Enter a note'), findsNothing);
    expect(find.text('/kaɪnd/'), findsNothing);
    expect(find.text('Details'), findsOneWidget);
    expect(find.byKey(const Key('word-details-divider')), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);

    await tester.tap(find.byKey(const Key('word-details-toggle')));
    await tester.pump();

    expect(find.text('/kaɪnd/'), findsOneWidget);
    expect(find.text('Enter singular and plural'), findsOneWidget);
    expect(find.text('Enter a note'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
  });

  testWidgets('a long input grows the field onto the next line', (
    tester,
  ) async {
    await pumpEditor(tester);

    final field = find.byKey(const Key('word-term'));
    final before = tester.getSize(field).height;
    await tester.enterText(
      field,
      'a person who is studying at a university or college and lives nearby',
    );
    await tester.pump();

    expect(tester.getSize(field).height, greaterThan(before));
    expect(
      find.text(
        'a person who is studying at a university or college and lives nearby',
      ),
      findsOneWidget,
    );
  });

  testWidgets('a type can be selected, switched, and cleared', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.byKey(const Key('word-type-noun')));
    await tester.pump();

    expect(typeChip(tester, 'noun').color, HomeColors.selectedFill);
    expect(typeLabel(tester, 'noun').style?.color, HomeColors.selected);
    expect(typeChip(tester, 'chunking').color, Colors.white);
    expect(typeChip(tester, 'verb').color, Colors.white);
    expect(typeChip(tester, 'adj').color, Colors.white);

    await tester.tap(find.byKey(const Key('word-type-verb')));
    await tester.pump();

    expect(typeChip(tester, 'verb').color, HomeColors.selectedFill);
    expect(typeLabel(tester, 'verb').style?.color, HomeColors.selected);
    expect(typeChip(tester, 'noun').color, Colors.white);
    expect(typeLabel(tester, 'noun').style?.color, HomeColors.text);

    await tester.tap(find.byKey(const Key('word-type-verb')));
    await tester.pump();

    expect(typeChip(tester, 'verb').color, Colors.white);
    expect(typeChip(tester, 'noun').color, Colors.white);

    await tester.tap(find.byKey(const Key('word-editor-type-add')));
    await tester.pump();

    expect(find.byKey(const Key('word-type-chunking')), findsOneWidget);
    expect(find.byKey(const Key('word-type-noun')), findsOneWidget);
    expect(find.byKey(const Key('word-type-verb')), findsOneWidget);
    expect(find.byKey(const Key('word-type-adj')), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
  });

  testWidgets('add new word stacks a summary above an empty card', (
    tester,
  ) async {
    await pumpEditor(tester);

    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'Animals',
    );
    await tester.enterText(
      find.byKey(const Key('word-term')),
      'ein Kind haben',
    );
    await tester.enterText(
      find.byKey(const Key('word-definition')),
      'have a child',
    );
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    expect(find.text('Animals'), findsOneWidget);
    expect(fieldText(tester, const Key('word-term')), isEmpty);
    expect(fieldText(tester, const Key('word-definition')), isEmpty);
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-2')),
        matching: find.byKey(const Key('word-term')),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.text('ein Kind haben'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.text('have a child'),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.text('ein Kind haben')).dx,
      lessThan(tester.getTopLeft(find.text('have a child')).dx),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('word-card-2'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('word-card-1'))).dy),
    );
  });

  testWidgets('the newest card stays on top', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Add new word'));
    await tester.pump();
    await tester.ensureVisible(find.text('Add new word'));
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-3')),
        matching: find.byKey(const Key('word-term')),
      ),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('word-card-3'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('word-card-2'))).dy),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('word-card-2'))).dy,
      lessThan(tester.getTopLeft(find.byKey(const Key('word-card-1'))).dy),
    );
  });

  testWidgets('a collapsed card hides the word form', (tester) async {
    await pumpEditor(tester);

    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
    await tester.tap(find.byKey(const Key('word-type-noun')));
    await tester.pump();
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    final collapsed = find.byKey(const Key('word-card-1'));
    expect(
      find.descendant(of: collapsed, matching: find.text('Enter sentence')),
      findsNothing,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('Noun')),
      findsNothing,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('Add new word')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-2')),
        matching: find.text('Add new word'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('idle controls keep the current cards', (tester) async {
    await pumpEditor(tester);

    await tester.tap(find.byKey(const Key('word-editor-import')));
    await tester.pump();
    Color? buttonFill(Key key) {
      return tester
          .widget<IconButton>(find.byKey(key))
          .style
          ?.backgroundColor
          ?.resolve(const <WidgetState>{});
    }

    expect(buttonFill(const Key('word-editor-search')), HomeColors.selectedFill);
    expect(buttonFill(const Key('word-editor-add')), HomeColors.selectedFill);

    await tester.tap(find.byKey(const Key('word-editor-search')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-editor-add')));
    await tester.pump();

    expect(find.byKey(const Key('word-card-1')), findsOneWidget);
    expect(find.byKey(const Key('word-card-2')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.byKey(const Key('word-term')),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('word-term')),
      'ein Kind haben',
    );
    await tester.tap(find.text('Add new word'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-card-copy-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-card-delete-1')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.text('ein Kind haben'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.byKey(const Key('word-term')),
      ),
      findsNothing,
    );
  });

  testWidgets('done and back drop the draft', (tester) async {
    await prepareView(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _Opener(),
      ),
    );

    Future<void> openEditor() async {
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
    }

    await openEditor();
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(find.text('Kind'), findsNothing);

    await openEditor();
    expect(find.byKey(const Key('word-card-1')), findsOneWidget);
    expect(find.byKey(const Key('word-card-2')), findsNothing);
    expect(fieldText(tester, const Key('word-term')), isEmpty);
    expect(find.text('Kind'), findsNothing);

    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.byKey(const Key('word-editor-back')));
    await tester.pumpAndSettle();

    expect(find.text('Open editor'), findsOneWidget);
    expect(find.text('Kind'), findsNothing);

    await openEditor();
    expect(fieldText(tester, const Key('word-term')), isEmpty);
    expect(find.text('Kind'), findsNothing);
  });
}

class _Opener extends StatelessWidget {
  const _Opener();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const WordEditor()));
        },
        child: const Text('Open editor'),
      ),
    );
  }
}
