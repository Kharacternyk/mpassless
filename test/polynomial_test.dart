import 'package:mpassless/polynomial.dart';
import 'package:mpassless/point.dart';
import 'package:glados/glados.dart';

final modulus = BigInt.from(17);

void main() {
  test('x² - 3x + 2 at 2 is 0', () {
    final polynomial = Polynomial(
        modulus, [Point.int(0, 2), Point.int(1, 0), Point.int(3, 2)]);

    expect(polynomial[BigInt.from(2)], BigInt.zero);
  });

  Glados<BigInt>().test('x² + b at 0 is b for any b', (b) {
    final polynomial = Polynomial(modulus, [
      Point.int(1, b.toInt() + 1),
      Point.int(2, b.toInt() + 4),
      Point.int(3, b.toInt() + 9)
    ]);

    expect(polynomial[BigInt.zero], b % modulus);
  });
}
