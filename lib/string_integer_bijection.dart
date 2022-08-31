class StringIntegerBijection {
  final List<int> codeUnits;
  final Map<int, int> codeUnitToIntegerMap;

  StringIntegerBijection(this.codeUnits)
      : codeUnitToIntegerMap = {
          for (var i = 0; i < codeUnits.length; ++i) codeUnits[i]: i
        } {
    assert(!codeUnits.any((codeUnit) => codeUnit < 0));
    assert(codeUnits.length > 1);
  }

  BigInt? fromString(String string) {
    var integer = BigInt.zero;

    for (final codeUnit in string.codeUnits) {
      final register = codeUnitToIntegerMap[codeUnit];

      if (register == null) {
        return null;
      }

      integer *= BigInt.from(codeUnits.length);
      integer += BigInt.from(register);
    }

    return integer;
  }

  String fromInteger(BigInt integer) {
    assert(!integer.isNegative);

    var string = '';

    while (integer > BigInt.zero) {
      final codeUnit =
          codeUnits[(integer % BigInt.from(codeUnits.length)).toInt()];

      string = String.fromCharCode(codeUnit) + string;
      integer ~/= BigInt.from(codeUnits.length);
    }

    return string;
  }
}
