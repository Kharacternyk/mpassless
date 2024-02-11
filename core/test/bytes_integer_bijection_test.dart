import 'dart:typed_data';
import 'package:mpassless/src/bytes_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  group('test bijection with specific points and size of two', () {
    final bijection = BytesIntegerBijection(2);
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
        expect(bijection.mapToBytes(integer), Uint8List.fromList(list));
      });
    }
  });

  Glados(any.bigInt).test('integer to bytes conversion is reversible',
      (signedInteger) {
    final integer = signedInteger.abs();
    final bijection = BytesIntegerBijection(integer.bitLength ~/ 8 + 1);
    final bytes = bijection.mapToBytes(integer);

    expect(bijection.mapToInteger(bytes), integer);
  });

  Glados(any.nonEmptyList(any.intInRange(0, 256)))
      .test('bytes to integer conversion is reversible', (bytes) {
    final bijection = BytesIntegerBijection(bytes.length);
    final integer = bijection.mapToInteger(Uint8List.fromList(bytes));

    expect(bijection.mapToBytes(integer), bytes);
  });
}
