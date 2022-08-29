import "point.dart";

class Polynomial {
  final BigInt modulus;
  final List<Point> points;

  const Polynomial(this.modulus, this.points);

  BigInt operator [](BigInt x) {
    var y = BigInt.zero;

    for (final excludedPoint in points) {
      var product = excludedPoint.y;

      for (final point in points) {
        if (point != excludedPoint) {
          product *= (x - point.x);
          product *= (excludedPoint.x - point.x).modInverse(modulus);
        }
      }

      y += product;
    }

    return y % modulus;
  }
}
