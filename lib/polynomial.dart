class Polynomial {
  final BigInt modulus;
  final Map<BigInt, BigInt> points;

  const Polynomial(this.modulus, this.points);

  BigInt operator [](BigInt x) {
    var y = BigInt.zero;

    for (final excludedX in points.keys) {
      var product = points[excludedX]!;

      for (final includedX in points.keys) {
        if (includedX != excludedX) {
          product *= (x - includedX);
          product *= (excludedX - includedX).modInverse(modulus);
        }
      }

      y += product;
    }

    return y % modulus;
  }
}
