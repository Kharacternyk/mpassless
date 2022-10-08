class InvalidLengthException implements Exception {
  final int minLength;
  final int maxLength;

  InvalidLengthException(this.maxLength, [this.minLength = 0]);
}
