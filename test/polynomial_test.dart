import 'package:mpassless/polynomial.dart';
import 'package:glados/glados.dart';

BigInt _(int x) => BigInt.from(x);

final modulus = BigInt.from(17);
final fieldElements = [for (var i = _(0); i < modulus; i += _(1)) i];

extension AnyFiniteFieldElement on Any {
  Generator<BigInt> get x => choose(fieldElements);
}

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

  Glados3(any.map(any.x, any.x), any.x, any.x).test(
      'polynomial does not change if we swap one point with another from its graph',
      (points, xForSwap, xForEval) {
    points.remove(xForSwap);

    final polynomial = Polynomial(modulus, points);

    for (final excludedX in points.keys) {
      final samePolynomial = Polynomial(modulus, {
        xForSwap: polynomial[xForSwap],
        for (final x in points.keys)
          if (x != excludedX) x: points[x]!
      });

      expect(polynomial[xForEval], samePolynomial[xForEval]);
    }
  });
}
