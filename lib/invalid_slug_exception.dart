import 'ascii_set.dart';

class InvalidSlugException implements Exception {
  final AsciiSet asciiSet;
  final String slug;

  InvalidSlugException(this.asciiSet, this.slug);

  @override
  String toString() => 'Invalid slug: some characters in $slug '
      'are outside the allowed set of $asciiSet';
}
