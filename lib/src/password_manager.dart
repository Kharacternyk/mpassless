import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'secret.dart';
import 'exceptions.dart';
import 'slow_integer_mapping.dart';

class Password {
  final BigInt value;
  Password._(this.value);
}

class Slug {
  final BigInt value;
  Slug._(this.value);
}

class PasswordManager {
  final AsciiSet slugCharacters;
  final AsciiSet passwordCharacters;
  final SlowIntegerMapping _slowIntegerMapping;
  final BigInt _modulus;
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;

  PasswordManager._(
    this.slugCharacters,
    this.passwordCharacters,
    this._slowIntegerMapping,
    this._modulus,
  )   : _slugBijection = StringIntegerBijection(slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(passwordCharacters.codeUnits);

  factory PasswordManager.v1(
      {AsciiSet? slugCharacters,
      AsciiSet? passwordCharacters,
      SlowIntegerMapping? slowIntegerMapping}) {
    return PasswordManager._(
      slugCharacters ??
          AsciiSet.lowerCaseLetters +
              AsciiSet.numbers +
              AsciiSet.fromString('.-'),
      passwordCharacters ?? AsciiSet.unitWidthCharacters,
      slowIntegerMapping ?? SlowIntegerMapping(200000, 2),
      BigInt.two.pow(521) - BigInt.one,
    );
  }

  Password parsePassword(String password) {
    final value = _passwordBijection.mapToInteger(password);

    if (value > _modulus) {
      throw TooLongException();
    }

    return Password._(value);
  }

  Slug parseSlug(String slug) {
    final value = _passwordBijection.mapToInteger(slug);

    if (value > _modulus) {
      throw TooLongException();
    }

    return Slug._(value);
  }

  Map<Slug, Password> parsePasswords(Map<String, String> passwords) =>
      passwords.map((slug, password) =>
          MapEntry(parseSlug(slug), parsePassword(password)));

  Set<Secret> generateSecrets(Map<Slug, Password> passwords, int number) {
    if (number <= 1) {
      throw ArgumentError.value(number);
    }

    final salt = _slowIntegerMapping.generateSecureSalt();
    final integerPasswords = _getIntegerPoints(passwords);
    final polynomial = Polynomial(_modulus, {
      ..._getSlowPoints(integerPasswords, salt),
      ...integerPasswords,
    });

    var x = BigInt.one;
    var secrets = <Secret>{};

    for (var i = 0; i < number; ++i) {
      while (polynomial.points.keys.contains(x)) {
        x += BigInt.one;
      }

      secrets.add(Secret(salt, x, polynomial[x]));
      x += BigInt.one;
    }

    return secrets;
  }

  String restorePassword(
      Slug slug, Map<Slug, Password> knownPasswords, Set<Secret> secrets) {
    final salts = List.from(secrets.map((secret) => secret.salt));

    if ({...salts}.length > 1) {
      throw IncompatibleSecretsException();
    }

    final integerKnownPasswords = _getIntegerPoints(knownPasswords);
    final polynomial = Polynomial(_modulus, {
      ...integerKnownPasswords,
      ..._getSlowPoints(integerKnownPasswords, salts.first),
      for (final secret in secrets) secret.x: secret.y
    });

    return _passwordBijection.mapToString(polynomial[slug.value]);
  }

  Map<BigInt, BigInt> _getIntegerPoints(Map<Slug, Password> passwords) =>
      passwords.map((slug, password) => MapEntry(slug.value, password.value));

  Map<BigInt, BigInt> _getSlowPoints(Map<BigInt, BigInt> points, salt) =>
      points.map((x, y) =>
          MapEntry(_modulus - x, _slowIntegerMapping.map(y, salt, _modulus)));
}
