import 'package:mpassless/src/password_manager.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    final manager = PasswordManager.v1();
    final rememberedPasswords = {
      manager.parseSlug('github.com'): manager.parsePassword('OctoCat42(~.~)'),
      manager.parseSlug('archlinux.org'):
          manager.parsePassword('correct horse battery staple'),
    };
    final forgottenPasswords = {
      manager.parseSlug('tutanota.com'):
          manager.parsePassword('yEuH5nstN2ufXudJDCtEYWmD'),
      manager.parseSlug('laptop'): manager.parsePassword(''),
    };
    final secrets = manager.generateSecrets(
        {...rememberedPasswords, ...forgottenPasswords},
        forgottenPasswords.length);

    for (final forgottenPasswordSlug in forgottenPasswords.keys) {
      expect(
          manager.restorePassword(
              forgottenPasswordSlug, rememberedPasswords, secrets),
          forgottenPasswords[forgottenPasswordSlug]!.value);
    }
  });
}
