import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';
import 'invalid_password_exception.dart';
import 'invalid_slug_exception.dart';

class PasswordManager {
  final AsciiSet _slugCharacters;
  final AsciiSet _passwordCharacters;
  final Polynomial _polynomial;
  late final StringIntegerBijection _slugBijection;
  late final StringIntegerBijection _passwordBijection;

  PasswordManager.v1(
      {AsciiSet? slugCharacters, AsciiSet? passwordCharacters, BigInt? modulus})
      : _polynomial =
            Polynomial(modulus ?? BigInt.two.pow(521) - BigInt.one, {}),
        _slugCharacters = slugCharacters ??
            AsciiSet.lowerCaseLetters +
                AsciiSet.numbers +
                AsciiSet.fromString('.-'),
        _passwordCharacters =
            passwordCharacters ?? AsciiSet.unitWidthCharacters {
    _slugBijection = StringIntegerBijection(_slugCharacters.codeUnits);
    _passwordBijection = StringIntegerBijection(_passwordCharacters.codeUnits);
  }

  void addPasswords(Map<String, String> slugPasswordMap) {
    slugPasswordMap.forEach((slug, password) => addPassword(slug, password));
  }

  void addPassword(String slug, String password) {
    if (!_passwordCharacters.enoughFor(password)) {
      throw InvalidPasswordException(_passwordCharacters, password);
    }

    _checkSlug(slug);
    _polynomial.points[_slugBijection.mapToInteger(slug)] =
        _passwordBijection.mapToInteger(password);
  }

  String getPassword(String slug) {
    _checkSlug(slug);

    return _passwordBijection
        .mapToString(_polynomial[_slugBijection.mapToInteger(slug)]);
  }

  void removePassword(String slug) {
    _checkSlug(slug);
    _polynomial.points.remove(_slugBijection.mapToInteger(slug));
  }

  void _checkSlug(String slug) {
    if (!_slugCharacters.enoughFor(slug)) {
      throw InvalidSlugException(_slugCharacters, slug);
    }
  }
}
