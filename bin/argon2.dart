import 'package:mpassless/slow_integer_mapping.dart';
import 'package:mpassless/string_integer_bijection.dart';
import 'package:mpassless/ascii_set.dart';

void main(List<String> arguments) {
  final derivator = SlowIntegerMapping();
  final bijection =
      StringIntegerBijection(AsciiSet.unitWidthCharacters.codeUnits);
  final salt = bijection.mapToInteger(arguments[0]);
  final integer = bijection.mapToInteger(arguments[1]);
  final key =
      derivator.deriveKey(integer, salt, BigInt.two.pow(521) - BigInt.one);

  print(bijection.mapToString(key));
}
