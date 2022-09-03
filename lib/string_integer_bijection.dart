class StringIntegerBijection {
  final List<int> _codeUnits;
  final Map<int, int> _codeUnitToIndexMap;

  StringIntegerBijection(Iterable<int> codeUnits)
      : _codeUnits = codeUnits.toList(),
        _codeUnitToIndexMap = {
          for (final entry in codeUnits.toList().asMap().entries)
            entry.value: entry.key
        } {
    assert(codeUnits.every((codeUnit) => codeUnit >= 0));
    assert(codeUnits.length > 1);
  }

  BigInt mapToInteger(final String string) {
    var base = BigInt.zero;

    for (var power = 0; power < string.length; ++power) {
      base += BigInt.from(_codeUnits.length).pow(power);
    }

    var rest = BigInt.zero;

    for (var power = 0; power < string.length; ++power) {
      final register = _codeUnitToIndexMap[string.codeUnitAt(power)]!;

      rest *= BigInt.from(_codeUnits.length);
      rest += BigInt.from(register);
    }

    return base + rest;
  }

  String mapToString(final BigInt integer) {
    assert(integer >= BigInt.zero);

    var length = 0;
    var base = BigInt.zero;

    while (base + BigInt.from(_codeUnits.length).pow(length) <= integer) {
      base += BigInt.from(_codeUnits.length).pow(length);
      ++length;
    }

    var rest = integer - base;
    var string = '';

    for (var i = 0; i < length; ++i) {
      final codeUnit =
          _codeUnits[(rest % BigInt.from(_codeUnits.length)).toInt()];

      string = String.fromCharCode(codeUnit) + string;
      rest ~/= BigInt.from(_codeUnits.length);
    }

    return string;
  }
}
