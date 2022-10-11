import 'password.dart';
import 'slug.dart';
import 'token.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'exceptions.dart';
import 'slow_integer_mapping.dart';
import 'raw_password_manager.dart';

class PasswordManager extends RawPasswordManager {
  final AsciiSet slugCharacters;
  final AsciiSet passwordCharacters;
  final AsciiSet tokenCharacters;
  final String tokenDelimiter;
  final String tokenConvenienceDelimiter;
  final int tokenConvenienceDelimiterPeriod;
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;
  final StringIntegerBijection _tokenBijection;

  PasswordManager._(
    this.slugCharacters,
    this.passwordCharacters,
    this.tokenCharacters,
    this.tokenDelimiter,
    this.tokenConvenienceDelimiter,
    this.tokenConvenienceDelimiterPeriod,
    super.modulus,
    super.slowIntegerMapping,
  )   : _slugBijection = StringIntegerBijection(slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(passwordCharacters.codeUnits),
        _tokenBijection = StringIntegerBijection(tokenCharacters.codeUnits) {
    if (tokenCharacters.enoughFor(tokenDelimiter) ||
        tokenCharacters.enoughFor(tokenConvenienceDelimiter)) {
      throw ArgumentError.value(tokenCharacters);
    }
    if (tokenConvenienceDelimiterPeriod <= 0) {
      throw ArgumentError.value(tokenConvenienceDelimiterPeriod);
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
      BigInt.two.pow(521) - BigInt.one,
      slowIntegerMapping ?? SlowIntegerMapping(200000, 2),
    );
  }

  @override
  String stringifyPassword(Password password) {
    return _passwordBijection.mapToString(password.value);
  }

  @override
  String stringifyToken(Token token) {
    return [token.salt, token.x, token.y]
        .map(_tokenBijection.mapToString)
        .map(_insertConvenienceDelimiters)
        .join(tokenDelimiter);
  }

  Password parsePassword(String password) {
    final value = _passwordBijection.mapToInteger(password);

    if (value >= modulus) {
      throw TooLongException();
    }

    return Password(value);
  }

  Slug parseSlug(String slug) {
    final value = _slugBijection.mapToInteger(slug);

    if (value >= modulus) {
      throw TooLongException();
    }

    return Slug(value);
  }

  Token parseToken(String token) {
    final chunks = token
        .split(tokenDelimiter)
        .map((string) => string.replaceAll(tokenConvenienceDelimiter, ''))
        .toList();

    if (chunks.length != 3) {
      throw MalformedTokenException();
    }

    final salt = _tokenBijection.mapToInteger(chunks[0]);
    final x = _tokenBijection.mapToInteger(chunks[1]);
    final y = _tokenBijection.mapToInteger(chunks[2]);

    if ([x, y].any((integer) => integer >= modulus)) {
      throw TooLongException();
    }

    return Token(salt, x, y);
  }

  Map<Slug, Password> parsePasswords(Map<String, String> passwords) =>
      passwords.map((slug, password) =>
          MapEntry(parseSlug(slug), parsePassword(password)));

  String _insertConvenienceDelimiters(String string) {
    final buffer = StringBuffer();

    for (var i = 0; i < string.length; ++i) {
      if (i > 0 && i % tokenConvenienceDelimiterPeriod == 0) {
        buffer.write(tokenConvenienceDelimiter);
      }
      buffer.write(string[i]);
    }

    return buffer.toString();
  }
}
