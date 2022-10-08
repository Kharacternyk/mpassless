import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'secret.dart';
import 'invalid_characters_exception.dart';

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
  final BigInt _modulus;
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;

  PasswordManager._(
    this._slugCharacters,
    this._passwordCharacters,
    this._modulus,
  )   : _slugBijection = StringIntegerBijection(_slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(_passwordCharacters.codeUnits);

  factory PasswordManager.v1({
    AsciiSet? slugCharacters,
    AsciiSet? passwordCharacters,
  }) {
    return PasswordManager._(
      slugCharacters ??
          AsciiSet.lowerCaseLetters +
              AsciiSet.numbers +
              AsciiSet.fromString('.-'),
      passwordCharacters ?? AsciiSet.unitWidthCharacters,
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
    if (number <= 0) {
      throw ArgumentError.value(number);
    }

    passwords.keys.forEach(_throwIfNotOwn);
    passwords.values.forEach(_throwIfNotOwn);

    final polynomial = Polynomial(_modulus, {
      for (final slug in passwords.keys)
        _slugBijection.mapToInteger(slug.value):
            _passwordBijection.mapToInteger(passwords[slug]!.value)
    });

    //TODO Random salts and xs
    return {
      for (var i = 0; i < number; ++i)
        Secret(BigInt.zero, _modulus - BigInt.from(i),
            polynomial[_modulus - BigInt.from(i)])
    };
  }

  String restorePassword(
      Slug slug, Map<Slug, Password> knownPasswords, Set<Secret> secrets) {
    knownPasswords.keys.forEach(_throwIfNotOwn);
    knownPasswords.values.forEach(_throwIfNotOwn);
    _throwIfNotOwn(slug);

    //TODO Check secrets share the same salt
    final polynomial = Polynomial(_modulus, {
      for (final knownSlug in knownPasswords.keys)
        _slugBijection.mapToInteger(knownSlug.value):
            _passwordBijection.mapToInteger(knownPasswords[knownSlug]!.value),
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
