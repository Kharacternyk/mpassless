class Token {
  final BigInt salt;
  final BigInt x;
  final BigInt y;
  Token(this.salt, this.x, this.y)
      : assert(salt >= BigInt.zero),
        assert(x >= BigInt.zero),
        assert(y >= BigInt.zero);
}
