import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lang/theme/home_palette.dart';

const _prefix = '\u{E000}rt1:';

const sentencePalette = <Color>[
  Color(0xFFD92D20),
  Color(0xFFC47B4A),
  Color(0xFF067647),
  Color(0xFF026AA2),
  Color(0xFF6941C6),
];

class SentenceMark {
  const SentenceMark({
    required this.start,
    required this.end,
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
  });

  final int start;
  final int end;
  final bool bold;
  final bool italic;
  final bool underline;
  final int? color;

  bool get hasStyle => bold || italic || underline || color != null;

  SentenceMark copy({
    int? start,
    int? end,
    bool? bold,
    bool? italic,
    bool? underline,
    int? color,
    bool clearColor = false,
  }) {
    return SentenceMark(
      start: start ?? this.start,
      end: end ?? this.end,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      underline: underline ?? this.underline,
      color: clearColor ? null : color ?? this.color,
    );
  }

  TextStyle apply(TextStyle base) {
    return base.copyWith(
      fontWeight: bold ? FontWeight.w700 : base.fontWeight,
      fontStyle: italic ? FontStyle.italic : base.fontStyle,
      decoration: underline ? TextDecoration.underline : base.decoration,
      color: color == null ? base.color : Color(color!),
    );
  }
}

class SentenceDocument {
  const SentenceDocument(this.text, this.marks);

  final String text;
  final List<SentenceMark> marks;

  bool get hasMarks => marks.isNotEmpty;

  static SentenceDocument parse(String stored) {
    if (!stored.startsWith(_prefix)) {
      return SentenceDocument(stored, const <SentenceMark>[]);
    }
    try {
      final decoded = jsonDecode(stored.substring(_prefix.length));
      if (decoded is! Map) {
        return SentenceDocument(stored, const <SentenceMark>[]);
      }
      final text = decoded['t'];
      final rawMarks = decoded['m'];
      if (text is! String || rawMarks is! List) {
        return SentenceDocument(stored, const <SentenceMark>[]);
      }
      final marks = <SentenceMark>[];
      for (final item in rawMarks) {
        if (item is! Map) {
          continue;
        }
        final start = item['s'];
        final end = item['e'];
        if (start is! int ||
            end is! int ||
            start < 0 ||
            end > text.length ||
            start >= end) {
          continue;
        }
        final color = item['c'];
        marks.add(
          SentenceMark(
            start: start,
            end: end,
            bold: item['b'] == 1,
            italic: item['i'] == 1,
            underline: item['u'] == 1,
            color: color is int ? color : null,
          ),
        );
      }
      return SentenceDocument(text, marks);
    } catch (_) {
      return SentenceDocument(stored, const <SentenceMark>[]);
    }
  }

  String encode() {
    if (marks.isEmpty) {
      return text;
    }
    final payload = jsonEncode(<String, Object>{
      't': text,
      'm': <Object>[
        for (final mark in marks)
          <String, Object>{
            's': mark.start,
            'e': mark.end,
            if (mark.bold) 'b': 1,
            if (mark.italic) 'i': 1,
            if (mark.underline) 'u': 1,
            if (mark.color != null) 'c': mark.color!,
          },
      ],
    });
    return '$_prefix$payload';
  }
}

String sentencePlain(String stored) => SentenceDocument.parse(stored).text;

class _TypingStyle {
  const _TypingStyle({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.color,
    this.pinned = false,
  });

  final bool bold;
  final bool italic;
  final bool underline;
  final int? color;
  final bool pinned;
}

class SentenceEditingController extends TextEditingController {
  SentenceEditingController({String stored = ''})
    : super(text: SentenceDocument.parse(stored).text) {
    _marks = List<SentenceMark>.of(SentenceDocument.parse(stored).marks);
    _last = value;
    addListener(_onValue);
  }

  List<SentenceMark> _marks = <SentenceMark>[];
  TextEditingValue _last = TextEditingValue.empty;
  _TypingStyle _typing = const _TypingStyle();
  var _adjusting = false;
  var _insertAt = 0;
  var _insertLength = 0;

  String get stored => SentenceDocument(text, _marks).encode();

  bool get boldActive => _active((mark) => mark.bold, _typing.bold);

  bool get italicActive => _active((mark) => mark.italic, _typing.italic);

  bool get underlineActive =>
      _active((mark) => mark.underline, _typing.underline);

  int? get colorActive {
    final range = _range();
    if (range == null) {
      return _typing.color;
    }
    SentenceMark? found;
    for (var index = range.$1; index < range.$2; index++) {
      final mark = _at(index);
      if (mark == null || mark.color == null) {
        return null;
      }
      found ??= mark;
      if (found.color != mark.color) {
        return null;
      }
    }
    return found?.color;
  }

  void load(String stored) {
    final document = SentenceDocument.parse(stored);
    _marks = List<SentenceMark>.of(document.marks);
    _typing = const _TypingStyle();
    _last = TextEditingValue(text: document.text);
    _adjusting = true;
    value = _last;
    _adjusting = false;
  }

  void toggleBold() => _toggle((mark) => mark.bold, bold: true);

  void toggleItalic() => _toggle((mark) => mark.italic, italic: true);

  void toggleUnderline() => _toggle((mark) => mark.underline, underline: true);

  void applyColor(Color? color) {
    final next = color?.toARGB32();
    final range = _range();
    if (range == null) {
      _pin(color: next, clearColor: next == null);
      notifyListeners();
      return;
    }
    _marks = _paint(
      _marks,
      range.$1,
      range.$2,
      color: next,
      clearColor: next == null,
    );
    notifyListeners();
  }

  void toggleBullet() => _toggleList(numbered: false);

  void toggleNumbered() => _toggleList(numbered: true);

  (int, int)? _range() {
    final selected = selection;
    if (!selected.isValid || selected.isCollapsed) {
      return null;
    }
    return (
      math.min(selected.start, selected.end),
      math.max(selected.start, selected.end),
    );
  }

  bool _active(bool Function(SentenceMark mark) test, bool typing) {
    final range = _range();
    if (range == null) {
      return typing;
    }
    for (var index = range.$1; index < range.$2; index++) {
      final mark = _at(index);
      if (mark == null || !test(mark)) {
        return false;
      }
    }
    return true;
  }

  void _toggle(
    bool Function(SentenceMark mark) test, {
    bool bold = false,
    bool italic = false,
    bool underline = false,
  }) {
    final range = _range();
    if (range == null) {
      final enable = !test(_typingMark());
      _pin(
        bold: bold ? enable : null,
        italic: italic ? enable : null,
        underline: underline ? enable : null,
      );
      notifyListeners();
      return;
    }
    final turnOn = !_uniform(range.$1, range.$2, test);
    _marks = _paint(
      _marks,
      range.$1,
      range.$2,
      bold: bold ? turnOn : null,
      italic: italic ? turnOn : null,
      underline: underline ? turnOn : null,
    );
    notifyListeners();
  }

  bool _uniform(int start, int end, bool Function(SentenceMark mark) test) {
    if (start >= end) {
      return false;
    }
    for (var index = start; index < end; index++) {
      final mark = _at(index);
      if (mark == null || !test(mark)) {
        return false;
      }
    }
    return true;
  }

  SentenceMark _typingMark() {
    return SentenceMark(
      start: 0,
      end: 0,
      bold: _typing.bold,
      italic: _typing.italic,
      underline: _typing.underline,
      color: _typing.color,
    );
  }

  void _pin({
    bool? bold,
    bool? italic,
    bool? underline,
    int? color,
    bool clearColor = false,
  }) {
    final neighbor = _beforeCursor();
    final seeded = _typing.pinned
        ? _typing
        : _TypingStyle(
            bold: neighbor?.bold ?? false,
            italic: neighbor?.italic ?? false,
            underline: neighbor?.underline ?? false,
            color: neighbor?.color,
          );
    _typing = _TypingStyle(
      bold: bold ?? seeded.bold,
      italic: italic ?? seeded.italic,
      underline: underline ?? seeded.underline,
      color: clearColor ? null : color ?? seeded.color,
      pinned: true,
    );
  }

  SentenceMark? _beforeCursor() {
    final selected = selection;
    final offset = selected.isValid ? selected.extentOffset : text.length;
    if (offset <= 0) {
      return null;
    }
    return _at(offset - 1);
  }

  SentenceMark? _at(int index) {
    for (final mark in _marks) {
      if (index >= mark.start && index < mark.end) {
        return mark;
      }
    }
    return null;
  }

  void _onValue() {
    final next = value;
    final previous = _last;
    if (next.text != previous.text) {
      _marks = _shift(_marks, previous.text, next.text);
      if (!_adjusting && _typing.pinned && _insertLength > 0) {
        _marks = _paint(
          _marks,
          _insertAt,
          _insertAt + _insertLength,
          bold: _typing.bold,
          italic: _typing.italic,
          underline: _typing.underline,
          color: _typing.color,
          clearColor: _typing.color == null,
        );
      }
    } else if (next.selection != previous.selection) {
      _typing = const _TypingStyle();
    }
    _last = next;
  }

  void _toggleList({required bool numbered}) {
    _adjusting = true;
    value = _listed(numbered: numbered);
    _adjusting = false;
  }

  TextEditingValue _listed({required bool numbered}) {
    final current = text;
    final selected = selection;
    final start = selected.isValid
        ? math.min(selected.start, selected.end)
        : current.length;
    final end = selected.isValid
        ? math.max(selected.start, selected.end)
        : current.length;
    final blockStart = start == 0
        ? 0
        : current.lastIndexOf('\n', start - 1) + 1;
    var blockEnd = current.indexOf('\n', end);
    if (blockEnd < 0) {
      blockEnd = current.length;
    }
    final lines = current.substring(blockStart, blockEnd).split('\n');
    final populated = lines.where((line) => line.isNotEmpty);
    final remove = populated.isNotEmpty &&
        populated.every((line) => _hasListPrefix(line, numbered: numbered));
    final next = <String>[];
    var number = _numberBefore(current, blockStart);
    for (final line in lines) {
      final stripped = line.replaceFirst(RegExp(r'^(?:• |\d+\. )'), '');
      if (remove) {
        next.add(stripped);
      } else if (numbered) {
        next.add('$number. $stripped');
        number += 1;
      } else {
        next.add('• $stripped');
      }
    }
    final replaced = next.join('\n');
    return TextEditingValue(
      text: current.replaceRange(blockStart, blockEnd, replaced),
      selection: TextSelection.collapsed(offset: blockStart + replaced.length),
    );
  }

  List<SentenceMark> _shift(
    List<SentenceMark> marks,
    String before,
    String after,
  ) {
    var prefix = 0;
    final maxPrefix = math.min(before.length, after.length);
    while (prefix < maxPrefix &&
        before.codeUnitAt(prefix) == after.codeUnitAt(prefix)) {
      prefix += 1;
    }
    var suffix = 0;
    while (suffix < before.length - prefix &&
        suffix < after.length - prefix &&
        before.codeUnitAt(before.length - 1 - suffix) ==
            after.codeUnitAt(after.length - 1 - suffix)) {
      suffix += 1;
    }
    final at = prefix;
    final deleted = before.length - suffix - prefix;
    final inserted = after.length - suffix - prefix;
    _insertAt = at;
    _insertLength = inserted;
    final endDelete = at + deleted;
    final next = <SentenceMark>[];
    for (final mark in marks) {
      if (mark.end <= at) {
        next.add(mark);
        continue;
      }
      if (mark.start >= endDelete) {
        final delta = inserted - deleted;
        next.add(
          mark.copy(start: mark.start + delta, end: mark.end + delta),
        );
        continue;
      }
      if (deleted == 0 && mark.start < at && mark.end >= at) {
        next.add(mark.copy(end: mark.end + inserted));
        continue;
      }
      final left = mark.start < at ? at - mark.start : 0;
      final right = mark.end > endDelete ? mark.end - endDelete : 0;
      if (left + right == 0) {
        continue;
      }
      final start = mark.start < at ? mark.start : at;
      next.add(mark.copy(start: start, end: start + left + inserted + right));
    }
    return _merge(next);
  }

  List<SentenceMark> _paint(
    List<SentenceMark> marks,
    int rawStart,
    int rawEnd, {
    bool? bold,
    bool? italic,
    bool? underline,
    int? color,
    bool clearColor = false,
  }) {
    final start = math.min(rawStart, rawEnd).clamp(0, text.length);
    final end = math.max(rawStart, rawEnd).clamp(0, text.length);
    if (start >= end) {
      return marks;
    }
    final points = <int>{0, text.length, start, end};
    for (final mark in marks) {
      points.add(mark.start.clamp(0, text.length));
      points.add(mark.end.clamp(0, text.length));
    }
    final sorted = points.toList()..sort();
    final next = <SentenceMark>[];
    for (var index = 0; index < sorted.length - 1; index++) {
      final from = sorted[index];
      final to = sorted[index + 1];
      if (from >= to) {
        continue;
      }
      final existing = _cover(marks, from);
      var mark = SentenceMark(
        start: from,
        end: to,
        bold: existing?.bold ?? false,
        italic: existing?.italic ?? false,
        underline: existing?.underline ?? false,
        color: existing?.color,
      );
      if (from >= start && to <= end) {
        mark = mark.copy(
          bold: bold,
          italic: italic,
          underline: underline,
          color: color,
          clearColor: clearColor,
        );
      }
      if (mark.hasStyle) {
        next.add(mark);
      }
    }
    return _merge(next);
  }

  SentenceMark? _cover(List<SentenceMark> marks, int index) {
    for (final mark in marks) {
      if (index >= mark.start && index < mark.end) {
        return mark;
      }
    }
    return null;
  }

  List<SentenceMark> _merge(List<SentenceMark> marks) {
    final sorted = <SentenceMark>[...marks]
      ..sort((a, b) => a.start.compareTo(b.start));
    final merged = <SentenceMark>[];
    for (final mark in sorted) {
      if (!mark.hasStyle || mark.start >= mark.end) {
        continue;
      }
      if (merged.isEmpty) {
        merged.add(mark);
        continue;
      }
      final last = merged.last;
      final same = last.bold == mark.bold &&
          last.italic == mark.italic &&
          last.underline == mark.underline &&
          last.color == mark.color;
      if (same && last.end >= mark.start) {
        merged[merged.length - 1] = last.copy(
          end: math.max(last.end, mark.end),
        );
      } else {
        merged.add(mark);
      }
    }
    return merged;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final base = style ?? const TextStyle();
    final composing = withComposing &&
            value.isComposingRangeValid &&
            !value.composing.isCollapsed
        ? value.composing
        : null;
    return sentenceSpan(text: text, marks: _marks, base: base, composing: composing);
  }
}

TextSpan sentenceSpan({
  required String text,
  required List<SentenceMark> marks,
  required TextStyle base,
  TextRange? composing,
}) {
  if (text.isEmpty) {
    return TextSpan(text: '', style: base);
  }
  final cuts = <int>{0, text.length};
  for (final mark in marks) {
    if (mark.start > 0 && mark.start < text.length) {
      cuts.add(mark.start);
    }
    if (mark.end > 0 && mark.end < text.length) {
      cuts.add(mark.end);
    }
  }
  if (composing != null && composing.isValid && !composing.isCollapsed) {
    if (composing.start > 0 && composing.start < text.length) {
      cuts.add(composing.start);
    }
    if (composing.end > 0 && composing.end < text.length) {
      cuts.add(composing.end);
    }
  }
  final points = cuts.toList()..sort();
  final children = <TextSpan>[];
  for (var index = 0; index < points.length - 1; index++) {
    final start = points[index];
    final end = points[index + 1];
    if (start >= end) {
      continue;
    }
    SentenceMark? mark;
    for (final item in marks) {
      if (start >= item.start && start < item.end) {
        mark = item;
        break;
      }
    }
    var style = mark == null ? base : mark.apply(base);
    if (composing != null &&
        start >= composing.start &&
        end <= composing.end) {
      style = style.copyWith(decoration: TextDecoration.underline);
    }
    children.add(TextSpan(text: text.substring(start, end), style: style));
  }
  return TextSpan(style: base, children: children);
}

bool _hasListPrefix(String line, {required bool numbered}) {
  if (numbered) {
    return RegExp(r'^\d+\. ').hasMatch(line);
  }
  return line.startsWith('• ');
}

int _numberBefore(String text, int lineStart) {
  if (lineStart == 0) {
    return 1;
  }
  final previousEnd = lineStart - 1;
  final previousStart = text.lastIndexOf('\n', previousEnd - 1) + 1;
  final previous = text.substring(previousStart, previousEnd);
  final match = RegExp(r'^(\d+)\. ').firstMatch(previous);
  if (match == null) {
    return 1;
  }
  return int.parse(match.group(1)!) + 1;
}

class FormattedSentence extends StatelessWidget {
  const FormattedSentence({
    super.key,
    required this.stored,
    required this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String stored;
  final TextStyle style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final document = SentenceDocument.parse(stored);
    if (!document.hasMarks) {
      return Text(
        document.text.trim(),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: sentenceSpan(text: document.text, marks: document.marks, base: style),
    );
  }
}

class SentenceFormatBar extends StatefulWidget {
  const SentenceFormatBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final SentenceEditingController controller;
  final VoidCallback onChanged;

  @override
  State<SentenceFormatBar> createState() => _SentenceFormatBarState();
}

class _SentenceFormatBarState extends State<SentenceFormatBar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(SentenceFormatBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_rebuild);
    widget.controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_rebuild);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final controller = widget.controller;
    Widget button({
      required Key buttonKey,
      required IconData icon,
      required bool active,
      required VoidCallback onPressed,
    }) {
      return Material(
        color: active ? colors.selectedFill : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: buttonKey,
          canRequestFocus: false,
          onTap: () {
            onPressed();
            widget.onChanged();
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              size: 20,
              color: active ? colors.selected : colors.muted,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          button(
            buttonKey: const Key('sentence-bold'),
            icon: Icons.format_bold,
            active: controller.boldActive,
            onPressed: controller.toggleBold,
          ),
          button(
            buttonKey: const Key('sentence-italic'),
            icon: Icons.format_italic,
            active: controller.italicActive,
            onPressed: controller.toggleItalic,
          ),
          button(
            buttonKey: const Key('sentence-underline'),
            icon: Icons.format_underlined,
            active: controller.underlineActive,
            onPressed: controller.toggleUnderline,
          ),
          button(
            buttonKey: const Key('sentence-bullet'),
            icon: Icons.format_list_bulleted,
            active: false,
            onPressed: controller.toggleBullet,
          ),
          button(
            buttonKey: const Key('sentence-number'),
            icon: Icons.format_list_numbered,
            active: false,
            onPressed: controller.toggleNumbered,
          ),
          _ColorButton(controller: controller, onChanged: widget.onChanged),
        ],
      ),
    );
  }
}

class _ColorButton extends StatefulWidget {
  const _ColorButton({required this.controller, required this.onChanged});

  final SentenceEditingController controller;
  final VoidCallback onChanged;

  @override
  State<_ColorButton> createState() => _ColorButtonState();
}

class _ColorButtonState extends State<_ColorButton> {
  TextSelection? _held;

  @override
  Widget build(BuildContext context) {
    final colors = HomePalette.of(context);
    final controller = widget.controller;
    final selected = controller.colorActive;
    return Listener(
      onPointerDown: (_) => _held = controller.selection,
      child: PopupMenuButton<int>(
      key: const Key('sentence-color'),
      tooltip: '',
      padding: EdgeInsets.zero,
      onSelected: (value) {
        final held = _held;
        if (held != null && held.isValid) {
          controller.selection = held;
        }
        controller.applyColor(value == 0 ? null : Color(value));
        widget.onChanged();
      },
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        for (final color in sentencePalette)
          PopupMenuItem<int>(
            key: Key('sentence-color-${color.toARGB32()}'),
            value: color.toARGB32(),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
        const PopupMenuItem<int>(
          key: Key('sentence-color-clear'),
          value: 0,
          child: Icon(Icons.format_color_reset, size: 20),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          Icons.format_color_text,
          size: 20,
          color: selected == null ? colors.muted : Color(selected),
        ),
      ),
      ),
    );
  }
}
