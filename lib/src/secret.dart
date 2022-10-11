import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'exceptions.dart';

class Secret {
  static const _delimiter = '-';
  static const _convenienceDelimiter = '.';
  static const _convenienceDelimiterPeriod = 5;
  static final _asciiSet = AsciiSet.lowerCaseLetters;
  static final _bijection = StringIntegerBijection(_asciiSet.codeUnits);

  final BigInt salt;
  final BigInt x;
  final BigInt y;

  Secret(this.salt, this.x, this.y);
  factory Secret.fromString(String string) {
    final chunks = string
        .split(_delimiter)
        .map((string) => string.replaceAll(_convenienceDelimiter, ''))
        .toList();

    if (chunks.length != 3) {
      throw MalformedSecretException();
    }
    if (!chunks.every(_asciiSet.enoughFor)) {
      throw InvalidCharactersException();
    }

    final salt = _bijection.mapToInteger(chunks[0]);
    final x = _bijection.mapToInteger(chunks[1]);
    final y = _bijection.mapToInteger(chunks[2]);

    return Secret(salt, x, y);
  }

  @override
  String toString() => "${_bijection.mapToString(salt)}$_delimiter"
      "${_bijection.mapToString(x)}$_delimiter"
      "${_insertConvenienceDelimiters(_bijection.mapToString(y))}";

  static String _insertConvenienceDelimiters(String string) {
    final buffer = StringBuffer();

    for (var i = 0; i < string.length; ++i) {
      if (i > 0 && i % _convenienceDelimiterPeriod == 0) {
        buffer.write(_convenienceDelimiter);
      }
      buffer.write(string[i]);
    }

    return buffer.toString();
  }
}
