import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lang/features/home/widgets/home_header.dart';
import 'package:lang/features/home/widgets/home_sidebar.dart';
import 'package:lang/features/word_editor/sentence_format.dart';
import 'package:lang/features/word_editor/word_editor.dart';
import 'package:lang/library/vocabulary_set.dart';
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

  Future<void> openDetails(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('word-details-toggle')));
    await tester.pump();
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

  testWidgets('the title dropdown lists sets created earlier', (tester) async {
    await prepareView(tester);
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WordEditor(
          existingSets: <VocabularySet>[
            VocabularySet(
              title: 'German A1',
              description: 'basics',
              words: <VocabularyWord>[],
            ),
            VocabularySet(
              title: 'Travel',
              description: 'trips',
              words: <VocabularyWord>[],
            ),
          ],
        ),
      ),
    );

    expect(find.byKey(const Key('word-editor-title-sets')), findsOneWidget);
    expect(find.text('German A1'), findsNothing);

    await tester.tap(find.byKey(const Key('word-editor-title-sets')));
    await tester.pumpAndSettle();

    expect(find.text('German A1'), findsOneWidget);
    expect(find.text('Travel'), findsOneWidget);

    await tester.tap(find.byKey(const Key('word-editor-existing-set-0')));
    await tester.pumpAndSettle();

    expect(fieldText(tester, const Key('word-editor-title')), 'German A1');
    expect(fieldText(tester, const Key('word-editor-description')), 'basics');
    expect(find.text('Travel'), findsNothing);
  });

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
    expect(find.text('Enter term'), findsOneWidget);
    expect(find.text('Enter definition'), findsOneWidget);
    expect(find.text('Enter sentence'), findsOneWidget);
    expect(find.byKey(const Key('sentence-bold')), findsOneWidget);
    expect(find.byKey(const Key('sentence-italic')), findsOneWidget);
    expect(find.byKey(const Key('sentence-underline')), findsOneWidget);
    expect(find.byKey(const Key('sentence-bullet')), findsOneWidget);
    expect(find.byKey(const Key('sentence-number')), findsOneWidget);
    expect(find.byKey(const Key('sentence-color')), findsOneWidget);
    expect(find.text('Enter IPA'), findsNothing);
    expect(find.text('Type'), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('word-editor-import')),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('word-editor-add')), findsNothing);
    expect(
      find.descendant(
        of: find.byKey(const Key('word-editor-add-word')),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );

    await openDetails(tester);

    expect(fieldText(tester, const Key('word-ipa')), isEmpty);
    expect(fieldText(tester, const Key('word-singular-plural')), isEmpty);
    expect(fieldText(tester, const Key('word-note')), isEmpty);
    expect(find.text('Enter IPA'), findsOneWidget);
    expect(find.text('Enter singular and plural'), findsOneWidget);
    expect(find.text('Enter a note'), findsOneWidget);
    expect(typeChip(tester, 'chunking').color, Colors.transparent);
    expect(typeChip(tester, 'noun').color, Colors.transparent);
    expect(typeChip(tester, 'verb').color, Colors.transparent);
    expect(typeChip(tester, 'adj').color, Colors.transparent);
    expect(find.text('ein Kind haben'), findsNothing);
    expect(find.text('have a child'), findsNothing);
    expect(find.text('All posts'), findsOneWidget);
    expect(
      tester.getSize(find.widgetWithText(FilledButton, 'Done')).height,
      44,
    );
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

  testWidgets('the details arrow folds the fields up and down', (tester) async {
    await pumpEditor(tester);

    expect(find.text('Enter IPA'), findsNothing);
    expect(find.text('Type'), findsNothing);
    expect(find.text('Noun'), findsNothing);
    expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

    await openDetails(tester);

    expect(find.text('Enter IPA'), findsOneWidget);
    expect(find.text('Enter singular and plural'), findsOneWidget);
    expect(find.text('Enter a note'), findsOneWidget);
    expect(find.text('Type'), findsOneWidget);
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
    expect(find.text('Type'), findsNothing);
    expect(find.text('Noun'), findsNothing);
    expect(find.byKey(const Key('word-details-divider')), findsNothing);
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
    await openDetails(tester);

    await tester.tap(find.byKey(const Key('word-type-noun')));
    await tester.pump();

    expect(typeChip(tester, 'noun').color, const Color(0xFF026AA2));
    expect(typeLabel(tester, 'noun').style?.color, Colors.white);
    expect(typeChip(tester, 'chunking').color, Colors.transparent);
    expect(typeChip(tester, 'verb').color, Colors.transparent);
    expect(typeChip(tester, 'adj').color, Colors.transparent);

    await tester.tap(find.byKey(const Key('word-type-verb')));
    await tester.pump();

    expect(typeChip(tester, 'verb').color, const Color(0xFF067647));
    expect(typeLabel(tester, 'verb').style?.color, Colors.white);
    expect(typeChip(tester, 'noun').color, Colors.transparent);
    expect(typeLabel(tester, 'noun').style?.color, const Color(0xFFD0D5DD));

    await tester.tap(find.byKey(const Key('word-type-verb')));
    await tester.pump();

    expect(typeChip(tester, 'verb').color, Colors.transparent);
    expect(typeChip(tester, 'noun').color, Colors.transparent);

    await tester.tap(find.byKey(const Key('word-editor-type-add')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('word-editor-type-name')),
      'Phrase',
    );
    await tester.tap(find.byKey(const Key('word-editor-type-create')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('word-type-chunking')), findsOneWidget);
    expect(find.byKey(const Key('word-type-noun')), findsOneWidget);
    expect(find.byKey(const Key('word-type-verb')), findsOneWidget);
    expect(find.byKey(const Key('word-type-adj')), findsOneWidget);
    expect(find.text('+'), findsOneWidget);
    expect(find.text('Phrase'), findsOneWidget);
    expect(
      tester.widget<Material>(find.byKey(const Key('word-type-custom-0'))).color,
      const Color(0xFFB54708),
    );
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
    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
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

    Future<void> fillCard() async {
      await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
      await tester.enterText(find.byKey(const Key('word-definition')), 'child');
      await tester.enterText(
        find.byKey(const Key('word-sentence')),
        'Das Kind',
      );
    }

    await fillCard();
    await tester.tap(find.text('Add new word'));
    await tester.pump();
    await tester.ensureVisible(find.text('Add new word'));
    await fillCard();
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

    await tester.enterText(
      find.byKey(const Key('word-term')),
      'ein Kind haben',
    );
    await tester.enterText(find.byKey(const Key('word-definition')), 'child');
    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
    await openDetails(tester);
    await tester.enterText(find.byKey(const Key('word-ipa')), '/kaɪnd/');
    await tester.enterText(find.byKey(const Key('word-note')), 'people');
    await tester.enterText(
      find.byKey(const Key('word-singular-plural')),
      'Kind - Kinder',
    );
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
      find.descendant(of: collapsed, matching: find.text('Das Kind')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('Noun')),
      findsNothing,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('/kaɪnd/')),
      findsNothing,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('people')),
      findsNothing,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('Kind - Kinder')),
      findsNothing,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(
              of: collapsed,
              matching: find.text('ein Kind haben'),
            ),
          )
          .style
          ?.fontWeight,
      FontWeight.w700,
    );
    expect(
      tester
          .getSize(find.byKey(const Key('word-card-definition-column-1')))
          .width,
      greaterThan(
        tester.getSize(find.byKey(const Key('word-card-term-column-1'))).width,
      ),
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
      findsNothing,
    );
    expect(find.text('Add new word'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Add new word')).dy,
      greaterThan(tester.getTopLeft(find.byKey(const Key('word-card-1'))).dy),
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

    expect(
      buttonFill(const Key('word-editor-search')),
      HomeColors.selectedFill,
    );

    await tester.tap(find.byKey(const Key('word-editor-search')));
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
    await tester.enterText(find.byKey(const Key('word-definition')), 'child');
    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
    await tester.tap(find.text('Add new word'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-card-image-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-card-edit-1')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('word-card-trash-1')));
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

  testWidgets('the image control opens a link field', (tester) async {
    await pumpEditor(tester);

    expect(find.byKey(const Key('word-image-link-1')), findsNothing);

    await tester.tap(find.byKey(const Key('word-card-image-1')));
    await tester.pump();

    expect(find.byKey(const Key('word-image-link-1')), findsOneWidget);
    expect(find.text('Enter image link'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('word-image-link-1')),
      'https://example.com/kind.jpg',
    );
    await tester.enterText(
      find.byKey(const Key('word-term')),
      'ein Kind haben',
    );
    await tester.enterText(
      find.byKey(const Key('word-definition')),
      'have a child',
    );
    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    final collapsed = find.byKey(const Key('word-card-1'));
    expect(
      find.descendant(of: collapsed, matching: find.text('ein Kind haben')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('have a child')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: collapsed, matching: find.text('Das Kind')),
      findsOneWidget,
    );
    final photo = tester.widget<Image>(
      find.descendant(
        of: collapsed,
        matching: find.byKey(const Key('word-card-photo-1')),
      ),
    );
    final network = photo.image as NetworkImage;
    expect(network.url, 'https://example.com/kind.jpg');
    expect(network.webHtmlElementStrategy, WebHtmlElementStrategy.prefer);
    final number = find.descendant(of: collapsed, matching: find.text('1'));
    final image = find.descendant(
      of: collapsed,
      matching: find.byKey(const Key('word-card-image-1')),
    );
    final edit = find.descendant(
      of: collapsed,
      matching: find.byKey(const Key('word-card-edit-1')),
    );
    final trash = find.descendant(
      of: collapsed,
      matching: find.byKey(const Key('word-card-trash-1')),
    );
    expect(
      tester.getCenter(image).dx,
      greaterThan(tester.getCenter(number).dx),
    );
    expect(tester.getCenter(edit).dx, greaterThan(tester.getCenter(image).dx));
    expect(tester.getCenter(trash).dx, greaterThan(tester.getCenter(edit).dx));
    expect(
      tester.getTopLeft(find.text('ein Kind haben')).dx,
      lessThan(tester.getTopLeft(find.text('have a child')).dx),
    );
    final photoFinder = find.descendant(
      of: collapsed,
      matching: find.byKey(const Key('word-card-photo-1')),
    );
    final term = find.descendant(
      of: collapsed,
      matching: find.text('ein Kind haben'),
    );
    final definition = find.descendant(
      of: collapsed,
      matching: find.text('have a child'),
    );
    expect(
      tester.getTopLeft(photoFinder).dx,
      lessThan(tester.getTopLeft(term).dx),
    );
    expect(
      tester.getTopLeft(photoFinder).dx,
      lessThan(tester.getTopLeft(definition).dx),
    );
    expect(
      (tester.getCenter(photoFinder).dy - tester.getCenter(term).dy).abs(),
      lessThan(24),
    );
    expect(
      (tester.getCenter(photoFinder).dy - tester.getCenter(definition).dy)
          .abs(),
      lessThan(24),
    );
  });

  testWidgets('a long definition on a collapsed card ends with an ellipsis', (
    tester,
  ) async {
    await pumpEditor(tester);

    const definition =
        'a person who is studying at a university or college and lives nearby and walks to class every morning';
    await tester.enterText(find.byKey(const Key('word-term')), 'student');
    await tester.enterText(
      find.byKey(const Key('word-definition')),
      definition,
    );
    await tester.enterText(
      find.byKey(const Key('word-sentence')),
      'The student arrived.',
    );
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    final definitionText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('word-card-1')),
        matching: find.text(definition),
      ),
    );
    expect(definitionText.maxLines, 2);
    expect(definitionText.overflow, TextOverflow.ellipsis);
    expect(
      tester
          .getSize(
            find.descendant(
              of: find.byKey(const Key('word-card-1')),
              matching: find.text(definition),
            ),
          )
          .height,
      lessThanOrEqualTo(16 * 1.4 * 2 + 1),
    );
  });

  testWidgets('done stores a word and back drops the draft', (tester) async {
    await prepareView(tester);
    final store = _RecordingStore();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _Opener(store: store),
      ),
    );

    Future<void> openEditor() async {
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
    }

    await openEditor();
    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German',
    );
    await tester.enterText(
      find.byKey(const Key('word-editor-description')),
      'basics',
    );
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(store.saved, hasLength(1));
    expect(store.saved.single.words.single.term, 'Kind');
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

    expect(store.saved, hasLength(1));
    expect(find.text('Open editor'), findsOneWidget);
    expect(find.text('Kind'), findsNothing);

    await openEditor();
    expect(fieldText(tester, const Key('word-term')), isEmpty);
    expect(find.text('Kind'), findsNothing);
  });

  testWidgets('a failed store keeps the editor open', (tester) async {
    await prepareView(tester);
    final store = _RecordingStore()..error = Exception('offline');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _Opener(store: store),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German',
    );
    await tester.enterText(
      find.byKey(const Key('word-editor-description')),
      'basics',
    );
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(store.saved, isEmpty);
    expect(find.text('Add new word'), findsOneWidget);
    expect(fieldText(tester, const Key('word-term')), 'Kind');
  });

  testWidgets('a whitespace term closes without saving', (tester) async {
    await prepareView(tester);
    final store = _RecordingStore();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _Opener(store: store),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German',
    );
    await tester.enterText(
      find.byKey(const Key('word-editor-description')),
      'basics',
    );
    await tester.enterText(find.byKey(const Key('word-term')), '   ');
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(store.saved, isEmpty);
    expect(find.text('Open editor'), findsOneWidget);
  });

  testWidgets('add new word requires a term and a definition', (
    tester,
  ) async {
    await pumpEditor(tester);

    await tester.tap(find.text('Add new word'));
    await tester.pump();

    expect(find.byKey(const Key('word-card-2')), findsNothing);
    expect(find.text('Enter a term'), findsOneWidget);
    expect(find.text('Enter a definition'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    expect(find.byKey(const Key('word-card-2')), findsNothing);
    expect(find.text('Enter a term'), findsNothing);
    expect(find.text('Enter a definition'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('word-definition')), 'child');
    await tester.tap(find.text('Add new word'));
    await tester.pump();

    expect(find.byKey(const Key('word-card-2')), findsOneWidget);
    expect(find.text('Enter a term'), findsNothing);
    expect(find.text('Enter a definition'), findsNothing);
  });

  testWidgets('done requires a title', (tester) async {
    await prepareView(tester);
    final store = _RecordingStore();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _Opener(store: store),
      ),
    );

    await tester.tap(find.text('Open editor'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('word-term')), 'Kind');
    await tester.tap(find.text('Done'));
    await tester.pump();

    expect(store.saved, isEmpty);
    expect(find.text('Enter a title'), findsOneWidget);
    expect(find.text('Add new word'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('word-editor-title')),
      'German',
    );
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(store.saved, hasLength(1));
    expect(find.text('Open editor'), findsOneWidget);
  });

  testWidgets('the editor header stays put while the form scrolls', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WordEditor(onClose: _noop),
      ),
    );

    final headerTop = tester
        .getTopLeft(find.byKey(const Key('word-editor-back')))
        .dy;
    final termTop = tester.getTopLeft(find.byKey(const Key('word-term'))).dy;
    final scroll = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const Key('word-editor-scroll')),
        matching: find.byType(Scrollable),
      ),
    );
    scroll.position.jumpTo(200);
    await tester.pump();

    expect(
      tester.getTopLeft(find.byKey(const Key('word-editor-back'))).dy,
      headerTop,
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('word-term'))).dy,
      lessThan(termTop),
    );
  });

  testWidgets('sentence formatting applies bold, lists, and color', (
    tester,
  ) async {
    await pumpEditor(tester);

    await tester.enterText(find.byKey(const Key('word-sentence')), 'Das Kind');
    final controller =
        tester.widget<TextField>(find.byKey(const Key('word-sentence'))).controller!
            as SentenceEditingController;
    expect(controller.stored, 'Das Kind');
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 3);
    await tester.pump();
    await tester.tap(find.byKey(const Key('sentence-bold')));
    await tester.pump();

    final span = controller.buildTextSpan(
      context: tester.element(find.byKey(const Key('word-sentence'))),
      style: const TextStyle(),
      withComposing: false,
    );
    final children = span.children!;
    expect((children.first as TextSpan).text, 'Das');
    expect((children.first as TextSpan).style?.fontWeight, FontWeight.w700);
    expect((children[1] as TextSpan).text, ' Kind');
    expect((children[1] as TextSpan).style?.fontWeight, isNot(FontWeight.w700));

    await tester.tap(find.byKey(const Key('sentence-bullet')));
    await tester.pump();
    expect(fieldText(tester, const Key('word-sentence')), '• Das Kind');

    await tester.tap(find.byKey(const Key('sentence-number')));
    await tester.pump();
    expect(fieldText(tester, const Key('word-sentence')), '1. Das Kind');

    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: controller.text.length,
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('sentence-color')));
    await tester.pumpAndSettle();
    const color = Color(0xFF026AA2);
    await tester.tap(find.byKey(Key('sentence-color-${color.toARGB32()}')));
    await tester.pumpAndSettle();

    final colored = controller.buildTextSpan(
      context: tester.element(find.byKey(const Key('word-sentence'))),
      style: const TextStyle(),
      withComposing: false,
    );
    expect(
      (colored.children!.first as TextSpan).style?.color,
      color,
    );
    expect(controller.stored, isNot('1. Das Kind'));
    expect(sentencePlain(controller.stored), '1. Das Kind');
  });
}

void _noop() {}

class _RecordingStore implements VocabularySetStore {
  final saved = <VocabularySet>[];
  Object? error;

  @override
  Future<String> createFolder(
    String name, {
    bool editor = false,
    bool pinned = true,
  }) async =>
      'folder-1';

  @override
  Future<void> save(VocabularySet set) async {
    final error = this.error;
    if (error != null) {
      throw error;
    }
    saved.add(set);
  }

  @override
  Future<void> updateWords(VocabularySet set) async {}

  @override
  Future<void> renameFolder(String id, String name) async {}

  @override
  Future<void> deleteFolder(String id) async {}

  @override
  Future<void> setFolderPinned(String id, bool pinned) async {}
}

class _Opener extends StatelessWidget {
  const _Opener({this.store});

  final VocabularySetStore? store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => WordEditor(setStore: store),
            ),
          );
        },
        child: const Text('Open editor'),
      ),
    );
  }
}
