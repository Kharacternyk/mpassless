import 'package:mpassless/polynomial.dart';
import 'package:glados/glados.dart';

final modulus = BigInt.from(17);

BigInt _(int x) => BigInt.from(x);

void main() {
  test('x² - 3x + 2 at 2 is 0', () {
    final polynomial =
        Polynomial(modulus, {_(0): _(2), _(1): _(0), _(3): _(2)});

    expect(polynomial[BigInt.from(2)], BigInt.zero);
  });

  Glados<BigInt>().test('x² + b at 0 is b for any b', (b) {
    final polynomial = Polynomial(modulus, {
      _(1): b + _(1),
      _(2): b + _(4),
      _(3): b + _(9),
    });

    expect(polynomial[BigInt.zero], b % modulus);
  });
}
