import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'invalid_characters_exception.dart';
import 'invalid_length_exception.dart';

class Secret {
  static const delimiter = '-';
  static final asciiSet = AsciiSet.lowerCaseLetters;
  static final _bijection = StringIntegerBijection(asciiSet.codeUnits);

  final BigInt salt;
  final BigInt x;
  final BigInt y;

  Secret(this.salt, this.x, this.y);
  factory Secret.fromString(String string) {
    final chunks = string.split(delimiter);

    if (chunks.length != 3) {
      //FIXME
      throw InvalidLengthException(0);
    }
    if (!chunks.every(asciiSet.enoughFor)) {
      throw InvalidCharactersException(asciiSet);
    }

    final salt = _bijection.mapToInteger(chunks[0]);
    final x = _bijection.mapToInteger(chunks[1]);
    final y = _bijection.mapToInteger(chunks[2]);

    return Secret(salt, x, y);
  }

  @override
  String toString() => "$salt$delimiter$x$delimiter$y";
}
