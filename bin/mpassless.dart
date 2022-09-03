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

    interact('password [$slug]: ');

    if (stdin.hasTerminal) {
      stdin.echoMode = false;
    }

    final password = stdin.readLineSync();

    if (password == null) {
      return;
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

    try {
      stdout.writeln(
          passwordManager.mapSlugsToPasswords([slug], slugPasswordMap)[slug]!);
    } catch (error) {
      stderr.writeln(error);
      break;
    }
  }
}
