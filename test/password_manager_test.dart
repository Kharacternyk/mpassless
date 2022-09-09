import 'package:mpassless/src/password_manager.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    var passwordManager = PasswordManager.v1();
    final rememberedPasswords = {
      'github.com': 'OctoCat42(~.~)',
      'archlinux.org': 'correct horse battery staple',
    };
    final forgottenPasswords = {
      'tutanota.com': 'yEuH5nstN2ufXudJDCtEYWmD',
      'laptop': '',
    };

    passwordManager.addPasswords(rememberedPasswords);
    passwordManager.addPasswords(forgottenPasswords);

    final generatedPasswords = {
      for (final generatedPasswordName in ['g1', 'g2'])
        generatedPasswordName:
            passwordManager.getPassword(generatedPasswordName)
    };

    passwordManager = PasswordManager.v1();
    passwordManager.addPasswords(rememberedPasswords);
    passwordManager.addPasswords(generatedPasswords);

    for (final forgottenPasswordSlug in forgottenPasswords.keys) {
      expect(passwordManager.getPassword(forgottenPasswordSlug),
          forgottenPasswords[forgottenPasswordSlug]);
    }
  });
}
