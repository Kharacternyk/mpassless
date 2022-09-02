class StringIntegerBijection {
  final List<int> codeUnits;
  final Map<int, int> codeUnitToIndexMap;

  StringIntegerBijection(this.codeUnits)
      : codeUnitToIndexMap = {
          for (var i = 0; i < codeUnits.length; ++i) codeUnits[i]: i
        } {
    assert(!codeUnits.any((codeUnit) => codeUnit < 0));
    assert(codeUnits.length > 1);
  }

  BigInt mapToInteger(final String string) {
    var base = BigInt.zero;

    for (var power = 0; power < string.length; ++power) {
      base += BigInt.from(codeUnits.length).pow(power);
    }

    var rest = BigInt.zero;

    for (var power = 0; power < string.length; ++power) {
      final register = codeUnitToIndexMap[string.codeUnitAt(power)]!;

      rest *= BigInt.from(codeUnits.length);
      rest += BigInt.from(register);
    }

    return base + rest;
  }

  String mapToString(final BigInt integer) {
    assert(!integer.isNegative);

    var length = 0;
    var base = BigInt.zero;

    while (base + BigInt.from(codeUnits.length).pow(length) <= integer) {
      base += BigInt.from(codeUnits.length).pow(length);
      ++length;
    }

    var rest = integer - base;
    var string = '';

    for (var i = 0; i < length; ++i) {
      final codeUnit =
          codeUnits[(rest % BigInt.from(codeUnits.length)).toInt()];

      string = String.fromCharCode(codeUnit) + string;
      rest ~/= BigInt.from(codeUnits.length);
    }

    return string;
  }
}
