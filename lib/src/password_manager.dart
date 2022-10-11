import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'exceptions.dart';
import 'slow_integer_mapping.dart';

class Password {
  final BigInt _value;
  Password._(this._value);
}

class Slug {
  final BigInt _value;
  Slug._(this._value);
}

class Token {
  final BigInt _salt;
  final BigInt _x;
  final BigInt _y;
  Token._(this._salt, this._x, this._y);
}

class PasswordManager {
  final AsciiSet slugCharacters;
  final AsciiSet passwordCharacters;
  final AsciiSet tokenCharacters;
  final String tokenDelimiter;
  final String tokenConvenienceDelimiter;
  final int _tokenConvenienceDelimiterPeriod;
  final SlowIntegerMapping _slowIntegerMapping;
  final BigInt _modulus;
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;
  final StringIntegerBijection _tokenBijection;

  PasswordManager._(
    this.slugCharacters,
    this.passwordCharacters,
    this.tokenCharacters,
    this.tokenDelimiter,
    this.tokenConvenienceDelimiter,
    this._tokenConvenienceDelimiterPeriod,
    this._slowIntegerMapping,
    this._modulus,
  )   : _slugBijection = StringIntegerBijection(slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(passwordCharacters.codeUnits),
        _tokenBijection = StringIntegerBijection(tokenCharacters.codeUnits) {
    if (tokenCharacters.enoughFor(tokenDelimiter) ||
        tokenCharacters.enoughFor(tokenConvenienceDelimiter)) {
      throw ArgumentError.value(tokenCharacters);
    }
    if (_tokenConvenienceDelimiterPeriod <= 0) {
      throw ArgumentError.value(_tokenConvenienceDelimiterPeriod);
    }
    if (passwordCharacters.isEmpty) {
      throw ArgumentError.value(passwordCharacters);
    }
    if (slugCharacters.isEmpty) {
      throw ArgumentError.value(slugCharacters);
    }
    if (tokenCharacters.isEmpty) {
      throw ArgumentError.value(tokenCharacters);
    }
  }

  factory PasswordManager.v1(
      {AsciiSet? slugCharacters,
      AsciiSet? passwordCharacters,
      AsciiSet? tokenCharacters,
      String? tokenDelimiter,
      String? tokenConvenienceDelimiter,
      int? tokenConvenienceDelimiterPeriod,
      SlowIntegerMapping? slowIntegerMapping}) {
    return PasswordManager._(
      slugCharacters ??
          AsciiSet.lowerCaseLetters +
              AsciiSet.numbers +
              AsciiSet.fromString('.-'),
      passwordCharacters ?? AsciiSet.unitWidthCharacters,
      tokenCharacters ?? AsciiSet.lowerCaseLetters,
      tokenDelimiter ?? '-',
      tokenConvenienceDelimiter ?? '.',
      tokenConvenienceDelimiterPeriod ?? 5,
      slowIntegerMapping ?? SlowIntegerMapping(200000, 2),
      BigInt.two.pow(521) - BigInt.one,
    );
  }

  Password parsePassword(String password) {
    final value = _passwordBijection.mapToInteger(password);

    if (value >= _modulus) {
      throw TooLongException();
    }

    return Password._(value);
  }

  Slug parseSlug(String slug) {
    final value = _slugBijection.mapToInteger(slug);

    if (value >= _modulus) {
      throw TooLongException();
    }

    return Slug._(value);
  }

  Token parseToken(String token) {
    final chunks = token
        .split(tokenDelimiter)
        .map((string) => string.replaceAll(tokenConvenienceDelimiter, ''))
        .toList();

    if (chunks.length != 3) {
      throw MalformedTokenException();
    }
    if (!chunks.every(tokenCharacters.enoughFor)) {
      throw InvalidCharactersException();
    }

    final salt = _tokenBijection.mapToInteger(chunks[0]);
    final x = _tokenBijection.mapToInteger(chunks[1]);
    final y = _tokenBijection.mapToInteger(chunks[2]);

    if ([x, y].any((integer) => integer >= _modulus)) {
      throw TooLongException();
    }

    return Token._(salt, x, y);
  }

  Map<Slug, Password> parsePasswords(Map<String, String> passwords) =>
      passwords.map((slug, password) =>
          MapEntry(parseSlug(slug), parsePassword(password)));

  Set<String> generateTokens(Map<Slug, Password> passwords, int number) {
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
    final tokens = <String>{};

    for (var i = 0; i < number; ++i) {
      while (polynomial.points.keys.contains(x)) {
        x += BigInt.one;
      }

      tokens.add(_stringifyToken(Token._(salt, x, polynomial[x])));
      x += BigInt.one;
    }

    return tokens;
  }

  String restorePassword(
      Slug slug, Map<Slug, Password> knownPasswords, Iterable<Token> tokens) {
    final salts = List.from(tokens.map((token) => token._salt));

    if ({...salts}.length > 1) {
      throw IncompatibleTokensException();
    }

    final integerKnownPasswords = _getIntegerPoints(knownPasswords);
    final polynomial = Polynomial(_modulus, {
      ...integerKnownPasswords,
      ..._getSlowPoints(integerKnownPasswords, salts.first),
      for (final token in tokens) token._x: token._y
    });

    return _passwordBijection.mapToString(polynomial[slug._value]);
  }

  Map<BigInt, BigInt> _getIntegerPoints(Map<Slug, Password> passwords) =>
      passwords.map((slug, password) => MapEntry(slug._value, password._value));

  Map<BigInt, BigInt> _getSlowPoints(Map<BigInt, BigInt> points, salt) =>
      points.map((x, y) => MapEntry(_modulus - x - BigInt.one,
          _slowIntegerMapping.map(y, salt, _modulus)));

  String _stringifyToken(Token token) {
    return [token._salt, token._x, token._y]
        .map(_tokenBijection.mapToString)
        .map(_insertConvenienceDelimiters)
        .join(tokenDelimiter);
  }

  String _insertConvenienceDelimiters(String string) {
    final buffer = StringBuffer();

    for (var i = 0; i < string.length; ++i) {
      if (i > 0 && i % _tokenConvenienceDelimiterPeriod == 0) {
        buffer.write(tokenConvenienceDelimiter);
      }
      buffer.write(string[i]);
    }

    return buffer.toString();
  }
}
