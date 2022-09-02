import 'dart:collection' show SplayTreeSet;

class AsciiSet {
  final SplayTreeSet<int> codeUnits;

  static final AsciiSet numbers = AsciiSet.fromCharacterRange('0', '9');
  static final AsciiSet lowerCaseLetters =
      AsciiSet.fromCharacterRange('a', 'z');
  static final AsciiSet upperCaseLetters =
      AsciiSet.fromCharacterRange('A', 'Z');
  static final AsciiSet unitWidthCharacters =
      AsciiSet.fromCharacterRange(' ', '~');

  AsciiSet(this.codeUnits) {
    assert(!codeUnits.any((codeUnit) => codeUnit < 0 || codeUnit > 127));
  }
  AsciiSet.fromString(String string)
      : this(SplayTreeSet.from(string.codeUnits));
  AsciiSet.fromCharacterRange(String firstCharacter, String lastCharacter)
      : this(SplayTreeSet.from([
          for (var i = firstCharacter.codeUnitAt(0);
              i <= lastCharacter.codeUnitAt(0);
              ++i)
            i
        ]));

  AsciiSet operator +(AsciiSet other) {
    return AsciiSet(SplayTreeSet.from(codeUnits.union(other.codeUnits)));
  }
}
