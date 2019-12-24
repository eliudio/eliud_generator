import 'package:eliud_generator/src/tools/tool_set.dart';
import 'package:json_schema/json_schema.dart';

import 'json_to.dart';

class JsonToModel extends JsonTo {
  final String className;
  final JsonSchema schema;

  JsonToModel({this.className, this.schema});

  String getHeader() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("// This code is generated. Do not touch!");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String getCommonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:meta/meta.dart';");
    return headerBuffer.toString();
  }

  String getImports() {
    StringBuffer headerBuffer = StringBuffer();
    return headerBuffer.toString();
  }

  String getDependantsImports() {
    StringBuffer codeBuffer = StringBuffer();

    schema.definitions.forEach((key, value) {
      JsonToModel jsonToModel = JsonToModel(className: key, schema: value);
      codeBuffer.writeln(jsonToModel.getImports());
    });
    return codeBuffer.toString();
  }

  String getBody() {
    StringBuffer codeBuffer = StringBuffer();

    codeBuffer.writeln("@immutable");
    codeBuffer.writeln("class $className {");
    schema.properties.forEach((key, value) {
      if (JsonTo.isArray(jsonType: value.type)) {
        codeBuffer.writeln(
            "  final List<" + jsonTypeToString(schema: value.items) +
                "> $key;");
      } else {
        codeBuffer.writeln(
            "  final " + jsonTypeToString(schema: value) +
                " $key;");
      }
    });
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String getDependantsBodies() {
    StringBuffer codeBuffer = StringBuffer();

    schema.definitions.forEach((key, value) {
      JsonToModel jsonToModel = JsonToModel(className: capitalize(key), schema: value);
      codeBuffer.writeln(jsonToModel.getBody());
    });
    return codeBuffer.toString();
  }

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(getHeader());
    codeBuffer.write(getCommonImports());
    codeBuffer.write(getImports());
    codeBuffer.write(getDependantsImports());
    codeBuffer.write(getBody());
    codeBuffer.write(getDependantsBodies());
    return codeBuffer.toString();
  }
}
