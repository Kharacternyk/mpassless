import 'package:mpassless/ascii_string.dart';
import 'package:mpassless/string_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  group('test bijection with specific points over [a, b]', () {
    final bijection =
        StringIntegerBijection(['a'.codeUnitAt(0), 'b'.codeUnitAt(0)]);
    final points = {
      '': BigInt.from(0),
      'b': BigInt.from(2),
      'aba': BigInt.from(9),
      'aaaa': BigInt.from(15),
    };

    for (final string in points.keys) {
      final integer = points[string]!;

      test('$string -> $integer', () {
        expect(bijection.mapToInteger(string), integer);
      });
      test('$integer -> $string', () {
        expect(bijection.mapToString(integer), string);
      });
    }
  });

  Glados2(any.nonEmptySet(any.positiveInt), any.bigInt).test(
      'integer to string conversion is reversible', (codeUnits, signedInteger) {
    if (codeUnits.length < 2) {
      return;
    }

    final integer = signedInteger.abs();
    final bijection = StringIntegerBijection(codeUnits.toList());
    final string = bijection.mapToString(integer);

    expect(bijection.mapToInteger(string), integer);
  });

  Glados(any.lowercaseLetters)
      .test('string to integer conversion is reversible over lowercase letters',
          (string) {
    final bijection =
        StringIntegerBijection(AsciiString.lowerCaseLetters.codeUnits);
    final integer = bijection.mapToInteger(string);

    expect(bijection.mapToString(integer), string);
  });
}
