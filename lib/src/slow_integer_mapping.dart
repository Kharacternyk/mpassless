import 'bytes_integer_bijection.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

class SlowIntegerMapping {
  final int usedKiBCount;
  final int iterationCount;

  SlowIntegerMapping({this.usedKiBCount = 200000, this.iterationCount = 3}) {
    assert(usedKiBCount > 0);
    assert(iterationCount > 0);
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
}
