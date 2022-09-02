import 'polynomial.dart';
import 'string_integer_bijection.dart';
import 'ascii_set.dart';

class PasswordManager {
  final StringIntegerBijection _slugBijection;
  final StringIntegerBijection _passwordBijection;
  final BigInt modulus;

  PasswordManager(
      AsciiSet slugCharacters, AsciiSet passwordCharacters, this.modulus)
      : _slugBijection = StringIntegerBijection(slugCharacters.codeUnits),
        _passwordBijection =
            StringIntegerBijection(passwordCharacters.codeUnits);

  Map<String, String> mapSlugsToPasswords(
      Iterable<String> slugs, Map<String, String> slugPasswordMap) {
    final points = {
      for (final slug in slugPasswordMap.keys)
        _slugBijection.mapToInteger(slug):
            _passwordBijection.mapToInteger(slugPasswordMap[slug]!)
    };
    final polynomial = Polynomial(modulus, points);

    return {
      for (final slug in slugs)
        slug: _passwordBijection
            .mapToString(polynomial[_slugBijection.mapToInteger(slug)])
    };
  }
}
