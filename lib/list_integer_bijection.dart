import 'dart:typed_data';

class ListIntegerBijection {
  static final _big256 = BigInt.two.pow(8);
  final int listLength;

  ListIntegerBijection(this.listLength) {
    assert(listLength > 0);
  }

  Uint8List mapToList(BigInt integer) {
    final integerByteSize = (integer.bitLength / 8).ceil();
    final unpaddedReversedList = <int>[];

    assert(integer >= BigInt.zero && integerByteSize <= listLength);

    while (integer > BigInt.zero) {
      unpaddedReversedList.add((integer % _big256).toInt());
      integer ~/= _big256;
    }

    final result = Uint8List(listLength);

    for (var i = 0; i < unpaddedReversedList.length; ++i) {
      result[listLength - i - 1] = unpaddedReversedList[i];
    }

    return result;
  }

  BigInt mapToInteger(Uint8List list) {
    var result = BigInt.zero;

    for (final register in list) {
      result *= _big256;
      result += BigInt.from(register);
    }

    return result;
  }
}
