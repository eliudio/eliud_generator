String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String camelcaseToUnderscore(String value) {
  RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
  String result = value.replaceAllMapped(exp, (Match m) => ('_' + m.group(0))).toLowerCase();
  return result;
}
