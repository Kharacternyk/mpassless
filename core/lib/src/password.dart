class Password {
  final BigInt value;
  Password(this.value) : assert(value >= BigInt.zero);
}
