import 'package:mpassless/ascii_set.dart';
import 'package:mpassless/password_manager.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    final modulus = BigInt.two.pow(521) - BigInt.one;
    final slugCharacters = AsciiSet.numbers +
        AsciiSet.lowerCaseLetters +
        AsciiSet.fromString('.-');
    final passwordManager =
        PasswordManager(slugCharacters, AsciiSet.unitWidthCharacters, modulus);
    final rememberedPasswords = {
      'github.com': 'OctoCat42(~.~)',
      'archlinux.org': 'correct horse battery staple',
    };
    final forgottenPasswords = {
      'tutanota.com': 'yEuH5nstN2ufXudJDCtEYWmD',
      'laptop': '',
    };
    final generatedPasswords = passwordManager.mapSlugsToPasswords(
        ['g1', 'g2'], {...rememberedPasswords, ...forgottenPasswords});

    expect(
        passwordManager.mapSlugsToPasswords(forgottenPasswords.keys,
            {...rememberedPasswords, ...generatedPasswords}),
        forgottenPasswords);
  });
}
