String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String camelcaseToUnderscore(String value) {
  RegExp exp = RegExp(r'(?<=[a-z])[A-Z]');
  String result = value.replaceAllMapped(exp, (Match m) => ('_' + m.group(0))).toLowerCase();
  return result;
}

String firstLowerCase(String s) => s[0].toLowerCase() + s.substring(1);

String firstUpperCase(String s) => s[0].toUpperCase() + s.substring(1);

String allUpperCase(String s) => s.toUpperCase();

String process(String template, { Map<String, String> parameters }) {
  if (parameters != null) {
    String processed = template;
    parameters.forEach((key, value) {
      processed = processed.replaceAll(key, value);
    });
    return processed;
  } else {
    return template;
  }
}

