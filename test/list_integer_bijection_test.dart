import 'dart:typed_data';
import 'package:mpassless/list_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  group('test bijection with specific points and size of two', () {
    final bijection = ListIntegerBijection(2);
    final points = {
      [0, 0]: BigInt.from(0),
      [0, 2]: BigInt.from(2),
      [1, 0]: BigInt.from(256),
      [8, 2]: BigInt.from(2050),
    };

    for (final list in points.keys) {
      final integer = points[list]!;

      test('$list -> $integer', () {
        expect(bijection.mapToInteger(Uint8List.fromList(list)), integer);
      });
      test('$integer -> $list', () {
        expect(bijection.mapToList(integer), Uint8List.fromList(list));
      });
    }
  });

  Glados(any.bigInt).test('integer to list conversion is reversible',
      (signedInteger) {
    final integer = signedInteger.abs();
    final bijection = ListIntegerBijection(integer.bitLength ~/ 8 + 1);
    final list = bijection.mapToList(integer);

    expect(bijection.mapToInteger(list), integer);
  });

  Glados(any.nonEmptyList(any.intInRange(0, 256)))
      .test('list to integer conversion is reversible', (list) {
    final bijection = ListIntegerBijection(list.length);
    final integer = bijection.mapToInteger(Uint8List.fromList(list));

    expect(bijection.mapToList(integer), list);
  });
}
