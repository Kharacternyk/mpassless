import 'password.dart';
import 'slug.dart';
import 'token.dart';
import 'polynomial.dart';
import 'exceptions.dart';
import 'slow_integer_mapping.dart';

abstract class RawPasswordManager {
  final BigInt modulus;
  final SlowIntegerMapping slowIntegerMapping;

  RawPasswordManager(this.modulus, this.slowIntegerMapping);

  String stringifyPassword(Password password);
  String stringifyToken(Token token);

  Set<String> generateTokens(Map<Slug, Password> passwords, int number) {
    if (number <= 1) {
      throw ArgumentError.value(number);
    }

    final salt = slowIntegerMapping.generateSecureSalt();
    final integerPasswords = _getIntegerPoints(passwords);
    final polynomial = Polynomial(modulus, {
      ..._getSlowPoints(integerPasswords, salt),
      ...integerPasswords,
    });

    var x = BigInt.one;
    final tokens = <String>{};

    for (var i = 0; i < number; ++i) {
      while (polynomial.points.keys.contains(x)) {
        x += BigInt.one;
      }

      tokens.add(stringifyToken(Token(salt, x, polynomial[x])));
      x += BigInt.one;
    }

    return tokens;
  }

  String restorePassword(
      Slug slug, Map<Slug, Password> knownPasswords, Iterable<Token> tokens) {
    final salts = List.from(tokens.map((token) => token.salt));

    if ({...salts}.length > 1) {
      throw IncompatibleTokensException();
    }

    final integerKnownPasswords = _getIntegerPoints(knownPasswords);
    final polynomial = Polynomial(modulus, {
      ...integerKnownPasswords,
      ..._getSlowPoints(integerKnownPasswords, salts.first),
      for (final token in tokens) token.x: token.y
    });

    return stringifyPassword(Password(polynomial[slug.value]));
  }

  Map<BigInt, BigInt> _getIntegerPoints(Map<Slug, Password> passwords) =>
      passwords.map((slug, password) => MapEntry(slug.value, password.value));

  Map<BigInt, BigInt> _getSlowPoints(Map<BigInt, BigInt> points, salt) =>
      points.map((x, y) => MapEntry(
          modulus - x - BigInt.one, slowIntegerMapping.map(y, salt, modulus)));
}
