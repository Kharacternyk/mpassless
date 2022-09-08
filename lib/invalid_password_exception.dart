import 'ascii_set.dart';

class InvalidPasswordException implements Exception {
  final AsciiSet asciiSet;
  final String password;

  InvalidPasswordException(this.asciiSet, this.password);

  @override
  String toString() => 'Invalid password: some characters in $password '
      'are outside the allowed set of $asciiSet';
}
