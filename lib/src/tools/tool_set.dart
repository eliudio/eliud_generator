String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String fileName(String name) {
  RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
  String result = name.replaceAllMapped(exp, (Match m) => ('_' + m.group(0))).toLowerCase() + ".dart";
  return result;
}
