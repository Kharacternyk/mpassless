class AsciiString {
  final List<int> codeUnits;

  static final AsciiString numbers = AsciiString.fromCharacterRange('0', '9');
  static final AsciiString lowerCaseLetters =
      AsciiString.fromCharacterRange('a', 'z');
  static final AsciiString upperCaseLetters =
      AsciiString.fromCharacterRange('A', 'Z');
  static final AsciiString unitWidthCharacters =
      AsciiString.fromCharacterRange(' ', '~');

  AsciiString(this.codeUnits) {
    assert(!codeUnits.any((codeUnit) => codeUnit < 0 || codeUnit > 127));
  }
  AsciiString.fromString(String string) : this(string.codeUnits);
  AsciiString.fromCharacterRange(String firstCharacter, String lastCharacter)
      : this([
          for (var i = firstCharacter.codeUnitAt(0);
              i <= lastCharacter.codeUnitAt(0);
              ++i)
            i
        ]);

  AsciiString operator +(AsciiString other) {
    return AsciiString(codeUnits + other.codeUnits);
  }
}
