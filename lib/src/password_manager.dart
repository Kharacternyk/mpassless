import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'secret.dart';
import 'invalid_characters_exception.dart';
import 'incompatible_secrets_exception.dart';
import 'slow_integer_mapping.dart';

abstract class PasswordManagerTiedValue {
  final PasswordManager _manager;
  final String value;

  PasswordManagerTiedValue._(this.value, this._manager);

  String get _name;
}

class Password extends PasswordManagerTiedValue {
  Password._(String value, PasswordManager manager) : super._(value, manager);

  @override
  String get _name => 'Password';
}

class Slug extends PasswordManagerTiedValue {
  Slug._(String value, PasswordManager manager) : super._(value, manager);

  @override
  String get _name => 'Slug';
}

class PasswordManager {
  final AsciiSet _slugCharacters;
  final AsciiSet _passwordCharacters;
  final SlowIntegerMapping _slowIntegerMapping;
  final BigInt _modulus;
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;

  PasswordManager._(
    this._slugCharacters,
    this._passwordCharacters,
    this._slowIntegerMapping,
    this._modulus,
  )   : _slugBijection = StringIntegerBijection(_slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(_passwordCharacters.codeUnits);

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
      slowIntegerMapping ?? SlowIntegerMapping(200000, 3),
      BigInt.two.pow(521) - BigInt.one,
    );
  }

  Password parsePassword(String password) {
    if (!_passwordCharacters.enoughFor(password)) {
      throw InvalidCharactersException(_passwordCharacters);
    }
    //TODO check for length here
    return Password._(password, this);
  }

  Slug parseSlug(String slug) {
    if (!_slugCharacters.enoughFor(slug)) {
      throw InvalidCharactersException(_slugCharacters);
    }
    //TODO check for length here
    return Slug._(slug, this);
  }

  Set<Secret> generateSecrets(Map<Slug, Password> passwords, int number) {
    if (number <= 1) {
      throw ArgumentError.value(number);
    }

    passwords.keys.forEach(_throwIfNotOwn);
    passwords.values.forEach(_throwIfNotOwn);

    final salt = _slowIntegerMapping.generateSecureSalt();
    final integerPasswords = {
      for (final slug in passwords.keys)
        _slugBijection.mapToInteger(slug.value):
            _passwordBijection.mapToInteger(passwords[slug]!.value),
    };
    final polynomial = Polynomial(_modulus, {
      ...integerPasswords,
      for (final slug in integerPasswords.keys)
        _modulus - slug:
            _slowIntegerMapping.map(integerPasswords[slug]!, salt, _modulus)
    });

    var x = BigInt.zero;
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
    knownPasswords.keys.forEach(_throwIfNotOwn);
    knownPasswords.values.forEach(_throwIfNotOwn);
    _throwIfNotOwn(slug);

    final salts = List.from(secrets.map((secret) => secret.salt));

    if ({...salts}.length > 1) {
      throw IncompatibleSecretsException();
    }

    final integerKnownPasswords = {
      for (final knownSlug in knownPasswords.keys)
        _slugBijection.mapToInteger(knownSlug.value):
            _passwordBijection.mapToInteger(knownPasswords[knownSlug]!.value)
    };
    final polynomial = Polynomial(_modulus, {
      ...integerKnownPasswords,
      for (final slug in integerKnownPasswords.keys)
        _modulus - slug: _slowIntegerMapping.map(
            integerKnownPasswords[slug]!, salts.first, _modulus),
      for (final secret in secrets) secret.x: secret.y
    });

    return _passwordBijection
        .mapToString(polynomial[_slugBijection.mapToInteger(slug.value)]);
  }

  void _throwIfNotOwn(PasswordManagerTiedValue value) {
    if (value._manager != this) {
      throw ArgumentError(
          '$value._name can only be passed to the password manager that parsed it');
    }
  }
}
