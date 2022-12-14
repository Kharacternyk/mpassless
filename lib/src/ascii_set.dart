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

  AsciiSet._(this._codeUnits) {
    if (!(_codeUnits.every((codeUnit) => codeUnit >= 0 && codeUnit <= 127))) {
      throw ArgumentError.value(_codeUnits);
    }
  }
  AsciiSet.fromString(String string)
      : this._(SplayTreeSet.from(string.codeUnits));
  AsciiSet.fromCharacterRange(String firstCharacter, String lastCharacter)
      : this._(SplayTreeSet.from([
          for (var i = firstCharacter.codeUnitAt(0);
              i <= lastCharacter.codeUnitAt(0);
              ++i)
            i
        ]));

  AsciiSet operator +(AsciiSet other) {
    return AsciiSet._(SplayTreeSet.from(_codeUnits.union(other._codeUnits)));
  }

  bool enoughFor(String string) {
    return string.codeUnits.every((codeUnit) => _codeUnits.contains(codeUnit));
  }

  bool get isEmpty => _codeUnits.isEmpty;

  @override
  String toString() => String.fromCharCodes(_codeUnits);
}
