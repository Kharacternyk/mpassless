import 'ascii_set.dart';

class InvalidCharactersException implements Exception {
  final AsciiSet asciiSet;

  InvalidCharactersException(this.asciiSet);
}
