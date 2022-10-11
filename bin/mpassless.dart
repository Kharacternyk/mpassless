import 'dart:io';
import 'package:mpassless/password_manager.dart';

void main(List<String> arguments) {
  final mode = arguments[0];
  final argument = arguments[1];

  if (mode == 'generate') {
    generateTokens(int.parse(argument));
  } else {
    restorePassword(argument);
  }
}

void generateTokens(int number) {
  final manager = PasswordManager.v1();
  final passwords = <Slug, Password>{};

  for (;;) {
    final slug = stdin.readLineSync();

    if (slug == null) {
      return;
    }
    if (slug.isEmpty) {
      break;
    }

    if (stdin.hasTerminal) {
      stdin.echoMode = false;
    }

    final password = stdin.readLineSync();

    if (password == null) {
      break;
    }
    if (stdin.hasTerminal) {
      stdin.echoMode = true;
    }

    passwords[manager.parseSlug(slug)] = manager.parsePassword(password);
  }

  for (final secret in manager.generateTokens(passwords, number)) {
    stdout.writeln(secret);
  }
}

void restorePassword(String slug) {
  final manager = PasswordManager.v1();
  final passwords = <Slug, Password>{};
  final tokens = <Token>{};

  for (;;) {
    final slug = stdin.readLineSync();

    if (slug == null) {
      return;
    }
    if (slug.isEmpty) {
      break;
    }

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

    passwords[manager.parseSlug(slug)] = manager.parsePassword(password);
  }

  for (;;) {
    final token = stdin.readLineSync();

    if (token == null || token.isEmpty) {
      break;
    }

    tokens.add(manager.parseToken(token));
  }

  stdout.writeln(
      manager.restorePassword(manager.parseSlug(slug), passwords, tokens));
}
