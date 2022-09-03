import 'dart:io';
import 'package:mpassless/password_manager.dart';
import 'package:mpassless/ascii_set.dart';

final modulus = BigInt.two.pow(521) - BigInt.one;
final slugCharacters =
    AsciiSet.numbers + AsciiSet.lowerCaseLetters + AsciiSet.fromString('.-');
final passwordCharacters = AsciiSet.unitWidthCharacters;

void interact([String message = '\n']) {
  if (stdin.hasTerminal && stderr.hasTerminal) {
    stderr.write(message);
  }
}

void checkSlug(String slug) {
  if (!slugCharacters.enoughFor(slug)) {
    stderr.writeln('$slug is not a valid slug—'
        'slugs must contain only lower case ASCII letters, numbers, dashes and periods.');
    exit(1);
  }
}

void main(List<String> arguments) {
  final passwordManager =
      PasswordManager(slugCharacters, passwordCharacters, modulus);
  final slugPasswordMap = <String, String>{};

  interact('Enter known slugs and passwords.\n');
  interact('Enter empty slug wnen done.\n');

  for (var i = 1; /**/; ++i) {
    interact('slug [$i]: ');

    final slug = stdin.readLineSync();

    if (slug == null) {
      return;
    }
    if (slug.isEmpty) {
      break;
    }

    checkSlug(slug);
    interact('password [$slug]: ');

    if (stdin.hasTerminal) {
      stdin.echoMode = false;
    }

    final password = stdin.readLineSync();

    if (password == null) {
      return;
    }
    if (!passwordCharacters.enoughFor(password)) {
      stderr.writeln('$password is not a valid password—'
          'passwords must contain only unit-width ASCII characters (ASCII 32-126 inclusive)');
      exit(1);
    }

    if (stdin.hasTerminal) {
      stdin.echoMode = true;
    }

    interact();
    slugPasswordMap[slug] = password;
  }

  interact();
  interact('Enter slugs of unknown passwords that you wish to get.\n');
  interact('Enter empty slug when done.\n');

  for (var i = 1; /**/; ++i) {
    interact('slug [$i]: ');

    final slug = stdin.readLineSync();

    if (slug == null) {
      return;
    }
    if (slug.isEmpty) {
      break;
    }

    checkSlug(slug);
    stdout.writeln(
        passwordManager.mapSlugsToPasswords([slug], slugPasswordMap)[slug]!);
  }
}
