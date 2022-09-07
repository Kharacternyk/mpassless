import 'list_integer_bijection.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/argon2.dart';

class KeyDerivator {
  BigInt deriveKey(BigInt integer, BigInt salt, BigInt modulus) {
    final bijection = ListIntegerBijection((modulus.bitLength / 8).ceil());
    final parameters = Argon2Parameters(
      Argon2Parameters.ARGON2_d,
      bijection.mapToList(salt),
      desiredKeyLength: modulus.bitLength,
      iterations: 100,
    );
    final generator = Argon2BytesGenerator()..init(parameters);
    final key = generator.process(bijection.mapToList(integer));

    return bijection.mapToInteger(key) % modulus;
  }
}
