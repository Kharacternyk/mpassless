import 'package:mpassless/src/password_manager.dart';
import 'package:mpassless/src/slow_integer_mapping.dart';
import 'package:glados/glados.dart';

void main() {
  test('passwords can be restored from the other ones and generated secrets',
      () {
    final manager =
        PasswordManager.v1(slowIntegerMapping: SlowIntegerMapping(2, 1));
    final rememberedPasswords = {
      'github.com': 'OctoCat42(~.~)',
      'archlinux.org': 'correct horse battery staple',
    };
    final forgottenPasswords = {
      'tutanota.com': 'yEuH5nstN2ufXudJDCtEYWmD',
      'laptop': '',
    };
    final tokens = manager.generateTokens({
      ...manager.parsePasswords(rememberedPasswords),
      ...manager.parsePasswords(forgottenPasswords)
    }, forgottenPasswords.length * 2).map(manager.parseToken);

    for (final forgottenPasswordSlug in forgottenPasswords.keys) {
      expect(
          manager.restorePassword(manager.parseSlug(forgottenPasswordSlug),
              manager.parsePasswords(rememberedPasswords), tokens),
          forgottenPasswords[forgottenPasswordSlug]);
    }
  });
}
