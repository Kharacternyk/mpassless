import 'package:mpassless/string_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  test('abba ~ 6 over [a, b]', () {
    final bijection =
        StringIntegerBijection(['a'.codeUnitAt(0), 'b'.codeUnitAt(0)]);

    expect(bijection.fromString('abba'), BigInt.from(6));
  });

  Glados2(any.nonEmptySet(any.positiveInt), any.bigInt)
      .test('integer conversion is reversible', (codeUnits, signedInteger) {
    if (codeUnits.length < 2) {
      return;
    }

    final integer = signedInteger.abs();
    final bijection = StringIntegerBijection(codeUnits.toList());
    final string = bijection.fromInteger(integer);

    expect(bijection.fromString(string), integer);
  });
}
