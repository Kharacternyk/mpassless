import 'dart:io';
import 'package:mpassless/password_manager.dart';
import 'package:mpassless/ascii_set.dart';

final modulus = BigInt.two.pow(521) - BigInt.one;
final slugCharacters =
    AsciiSet.numbers + AsciiSet.lowerCaseLetters + AsciiSet.fromString('.-');
final passwordCharacters = AsciiSet.unitWidthCharacters;

void main(List<String> arguments) {
  final passwordManager =
      PasswordManager(slugCharacters, passwordCharacters, modulus);
  final slugPasswordMap = <String, String>{};

  stdout.writeln('Enter known slugs and passwords.');
  stdout.writeln('Press <Ctrl+D> when done.');

  for (;;) {
    stdout.write('Password slug: ');

    final slug = stdin.readLineSync();

    if (slug == null) {
      break;
    }

    stdout.write('Password for $slug: ');
    stdin.echoMode = false;

    final password = stdin.readLineSync() ?? '';

    stdin.echoMode = true;
    stdout.writeln();
    slugPasswordMap[slug] = password;
  }

  stdout.writeln();
  stdout.writeln('Enter slugs of unknown passwords that you wish to get');
  stdout.writeln('Press <Ctrl+D> when done.');

  for (;;) {
    stdout.write('Password slug: ');

    final slug = stdin.readLineSync();

    if (slug == null) {
      break;
    }

    stdout.writeln(
        passwordManager.mapSlugsToPasswords([slug], slugPasswordMap)[slug]!);
  }

  stdout.writeln();
}
