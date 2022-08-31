import 'package:mpassless/polynomial.dart';
import 'package:glados/glados.dart';

BigInt b(int x) => BigInt.from(x);

final modulus = b(17);
final fieldElements = [for (var i = b(0); i < modulus; i += b(1)) i];

extension AnyFiniteFieldElement on Any {
  Generator<BigInt> get x => choose(fieldElements);
}

void main() {
  test('x² - 3x + 2 at 2 is 0', () {
    final polynomial =
        Polynomial(modulus, {b(0): b(2), b(1): b(0), b(3): b(2)});

    expect(polynomial[b(2)], b(0));
  });

  Glados(any.x).test('x² + y at 0 is y for any y', (y) {
    final polynomial = Polynomial(modulus, {
      b(1): y + b(1),
      b(2): y + b(4),
      b(3): y + b(9),
    });

    expect(polynomial[b(0)], y);
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
