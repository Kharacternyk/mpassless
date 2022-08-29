class Point {
  final BigInt x;
  final BigInt y;

  const Point(this.x, this.y);
  Point.int(int x, int y)
      : x = BigInt.from(x),
        y = BigInt.from(y);
}
