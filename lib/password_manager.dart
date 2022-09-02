import 'polynomial.dart';
import 'string_integer_bijection.dart';

class PasswordManager {
  final StringIntegerBijection slugBijection;
  final StringIntegerBijection passwordBijection;
  final BigInt modulus;

  PasswordManager(this.slugBijection, this.passwordBijection, this.modulus);

  Map<String, String> mapSlugsToPasswods(
      Iterable<String> slugs, Map<String, String> slugPasswordMap) {
    final points = {
      for (final slug in slugPasswordMap.keys)
        slugBijection.mapToInteger(slug):
            passwordBijection.mapToInteger(slugPasswordMap[slug]!)
    };
    final polynomial = Polynomial(modulus, points);

    return {
      for (final slug in slugs)
        slug: passwordBijection
            .mapToString(polynomial[slugBijection.mapToInteger(slug)])
    };
  }
}
