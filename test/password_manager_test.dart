import 'package:mpassless/ascii_string.dart';
import 'package:mpassless/password_manager.dart';
import 'package:mpassless/string_integer_bijection.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    final modulus = BigInt.two.pow(521) - BigInt.one;
    final slugCharacters = AsciiString.numbers +
        AsciiString.lowerCaseLetters +
        AsciiString.fromString('.-');
    final slugBijection = StringIntegerBijection(slugCharacters.codeUnits);
    final passwordBijection =
        StringIntegerBijection(AsciiString.unitWidthCharacters.codeUnits);
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
