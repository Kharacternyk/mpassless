import 'dart:typed_data';

class BytesIntegerBijection {
  static final _big256 = BigInt.two.pow(8);
  final int byteCount;

  BytesIntegerBijection(this.byteCount) {
    assert(byteCount > 0);
  }

  Uint8List mapToBytes(BigInt integer) {
    final integerByteSize = (integer.bitLength / 8).ceil();
    final unpaddedReversedList = <int>[];

    assert(integer >= BigInt.zero && integerByteSize <= byteCount);

    while (integer > BigInt.zero) {
      unpaddedReversedList.add((integer % _big256).toInt());
      integer ~/= _big256;
    }

    final result = Uint8List(byteCount);

    for (var i = 0; i < unpaddedReversedList.length; ++i) {
      result[byteCount - i - 1] = unpaddedReversedList[i];
    }

    return result;
  }

  BigInt mapToInteger(Uint8List bytes) {
    var result = BigInt.zero;

    for (final register in bytes) {
      result *= _big256;
      result += BigInt.from(register);
    }

    return result;
  }
}
