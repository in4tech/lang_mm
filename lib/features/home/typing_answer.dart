/// Blanks whole-word matches of [term] in [sentence] as `---`.
///
/// Matching is case-insensitive. A match must sit on a word boundary so
/// `memorize` does not blank inside `memorized`.
String blankTermInSentence(String sentence, String term) {
  final needle = term.trim();
  if (needle.isEmpty || sentence.isEmpty) {
    return sentence;
  }
  final lowerNeedle = needle.toLowerCase();
  final lowerSentence = sentence.toLowerCase();
  final buffer = StringBuffer();
  var index = 0;
  while (index < sentence.length) {
    final found = lowerSentence.indexOf(lowerNeedle, index);
    if (found < 0) {
      buffer.write(sentence.substring(index));
      break;
    }
    if (!_isWordChar(sentence, found - 1) &&
        !_isWordChar(sentence, found + needle.length)) {
      buffer.write(sentence.substring(index, found));
      buffer.write('---');
      index = found + needle.length;
    } else {
      buffer.write(sentence.substring(index, found + 1));
      index = found + 1;
    }
  }
  return buffer.toString();
}

/// True when [typed] matches [term] after trim and lowercase.
bool typingAnswerMatches(String typed, String term) {
  return typed.trim().toLowerCase() == term.trim().toLowerCase();
}

bool _isWordChar(String text, int index) {
  if (index < 0 || index >= text.length) {
    return false;
  }
  final code = text.codeUnitAt(index);
  final isLetter =
      (code >= 65 && code <= 90) ||
      (code >= 97 && code <= 122) ||
      (code >= 192 && code <= 255);
  final isDigit = code >= 48 && code <= 57;
  return isLetter || isDigit || code == 95;
}
