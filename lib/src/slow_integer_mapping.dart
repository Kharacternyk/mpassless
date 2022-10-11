import 'dart:math';
import 'bytes_integer_bijection.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

class SlowIntegerMapping {
  final int usedKiBCount;
  final int iterationCount;

  SlowIntegerMapping(this.usedKiBCount, this.iterationCount) {
    if (usedKiBCount <= 1) {
      throw ArgumentError.value(usedKiBCount);
    }
    if (iterationCount <= 0) {
      throw ArgumentError.value(iterationCount);
    }
  }

  BigInt map(BigInt integer, BigInt salt, BigInt modulus) {
    final bijection = BytesIntegerBijection((modulus.bitLength / 8).ceil());
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_id,
      bijection.mapToBytes(salt),
      desiredKeyLength: modulus.bitLength,
      iterations: iterationCount,
      memory: usedKiBCount,
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
