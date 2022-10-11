import 'dart:math';
import 'bytes_integer_bijection.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

class SlowIntegerMapping {
  final int _usedKiBCount;
  final int _iterationCount;

  SlowIntegerMapping(this._usedKiBCount, this._iterationCount) {
    if (_usedKiBCount <= 1) {
      throw ArgumentError.value(_usedKiBCount);
    }
    if (_iterationCount <= 0) {
      throw ArgumentError.value(_iterationCount);
    }
  }

  BigInt map(BigInt integer, BigInt salt, BigInt modulus) {
    final bijection = BytesIntegerBijection((modulus.bitLength / 8).ceil());
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      bijection.mapToBytes(salt),
      desiredKeyLength: modulus.bitLength,
      iterations: _iterationCount,
      memory: _usedKiBCount,
    );
    final generator = Argon2BytesGenerator()..init(parameters);
    final key = generator.process(bijection.mapToBytes(integer));

    return bijection.mapToInteger(key) % modulus;
  }

  BigInt generateSecureSalt() {
    final random = Random.secure();
    var salt = BigInt.zero;

    for (var i = 0; i < 4; ++i) {
      salt << 32;
      salt += BigInt.from(random.nextInt(1 << 32));
    }

    return salt;
  }
}
