import 'package:mpassless/password_manager.dart';
import 'package:mpassless/string_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    final modulus = BigInt.two.pow(521) - BigInt.one;
    final slugBijection = StringIntegerBijection([
      45,
      46,
      for (var i = 48; i < 58; ++i) i,
      for (var i = 97; i < 123; ++i) i,
    ]);
    final passwordBijection =
        StringIntegerBijection([for (var i = 20; i < 127; ++i) i]);
    final passwordManager =
        PasswordManager(slugBijection, passwordBijection, modulus);
    final rememberedPasswords = {
      'github.com': 'OctoCat42(~.~)',
      'archlinux.org': 'correct horse battery staple',
    };
    final forgottenPasswords = {
      'tutanota.com': 'yEuH5nstN2ufXudJDCtEYWmD',
      'laptop': '',
    };
    final generatedPasswords = passwordManager.mapSlugsToPasswods(
        ['g1', 'g2'], {...rememberedPasswords, ...forgottenPasswords});

    expect(
        passwordManager.mapSlugsToPasswods(forgottenPasswords.keys,
            {...rememberedPasswords, ...generatedPasswords}),
        forgottenPasswords);
  });
}
