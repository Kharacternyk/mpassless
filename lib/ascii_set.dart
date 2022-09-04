import 'dart:collection' show SplayTreeSet;

class AsciiSet {
  final SplayTreeSet<int> _codeUnits;
  Iterable<int> get codeUnits => _codeUnits;

  static final AsciiSet numbers = AsciiSet.fromCharacterRange('0', '9');
  static final AsciiSet lowerCaseLetters =
      AsciiSet.fromCharacterRange('a', 'z');
  static final AsciiSet upperCaseLetters =
      AsciiSet.fromCharacterRange('A', 'Z');
  static final AsciiSet unitWidthCharacters =
      AsciiSet.fromCharacterRange(' ', '~');

  AsciiSet._unsafe(this._codeUnits) {
    assert(_codeUnits.every((codeUnit) => codeUnit >= 0 && codeUnit <= 127));
  }
  AsciiSet.fromString(String string)
      : this._unsafe(SplayTreeSet.from(string.codeUnits));
  AsciiSet.fromCharacterRange(String firstCharacter, String lastCharacter)
      : this._unsafe(SplayTreeSet.from([
          for (var i = firstCharacter.codeUnitAt(0);
              i <= lastCharacter.codeUnitAt(0);
              ++i)
            i
        ]));

  AsciiSet operator +(AsciiSet other) {
    return AsciiSet._unsafe(
        SplayTreeSet.from(_codeUnits.union(other._codeUnits)));
  }

  bool enoughFor(String string) {
    return string.codeUnits.every((codeUnit) => _codeUnits.contains(codeUnit));
  }

  @override
  String toString() => String.fromCharCodes(_codeUnits);
}
