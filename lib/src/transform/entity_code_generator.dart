import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'data_code_generator.dart';

class EntityCodeGenerator extends DataCodeGenerator {
  EntityCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  String theFileName() {
    return modelSpecifications.entityFileName();
  }

  String _commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln();
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (!field.isNativeType()) {
        headerBuffer.writeln("import '" +
            camelcaseToUnderscore(field.fieldType) +
            ".entity.dart" +
            "';");
        extraLine = true;
      }
    });
    if (extraLine) headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _fieldDefinitions() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(
          "  final " + field.dartEntityType() + " " + field.fieldName + ";");
    });
    return codeBuffer.toString();
  }

  String _getProps() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + "List<Object> get props => [");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ", ");
    });
    codeBuffer.writeln("];");
    return codeBuffer.toString();
  }

  String _fromMap() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) +
        "static " +
        modelSpecifications.entityClassName() +
        " fromMap(Map map) {");
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (!field.isNativeType()) {
        extraLine = true;
        if (field.array) {
          codeBuffer.writeln(spaces(4) +
              "final " +
              field.fieldName +
              "List = (map['" +
              field.fieldName +
              "'] as List<dynamic>)");
          codeBuffer.writeln(spaces(8) + ".map((dynamic item) =>");
          codeBuffer.writeln(spaces(8) +
              field.fieldType +
              "Entity.fromMap(item as Map))");
          codeBuffer.writeln(spaces(8) + ".toList();");
        } else {
          codeBuffer.writeln(spaces(4) +
              "final " +
              field.fieldName +
              "FromMap = " +
              field.fieldType +
              "Entity.fromMap(map['" +
              field.fieldName +
              "']);");
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.writeln(
        spaces(4) + "return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(spaces(6) + field.fieldName + ": ");
      if (!field.isNativeType()) {
        if (field.array) {
          codeBuffer.writeln(field.fieldName + "List, ");
        } else {
          codeBuffer.writeln(field.fieldName + "FromMap, ");
        }
      } else {
        if (field.array) {
          codeBuffer.writeln("List.from(map['" + field.fieldName + "']), ");
        } else {
          codeBuffer.writeln("map['" + field.fieldName + "'], ");
        }
      }
    });
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _toDocument() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Map<String, Object> toDocument() {");
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (!field.isNativeType()) {
        extraLine = true;
        if (field.array) {
          codeBuffer.writeln(spaces(4) +
              "final List<Map<String, dynamic>> " +
              field.fieldName +
              "ListMap" +
              " = " +
              field.fieldName +
              " != null ");
          codeBuffer.writeln(spaces(8) +
              "? " +
              field.fieldName +
              ".map((item) => item.toDocument()).toList()");
          codeBuffer.writeln(spaces(8) + ": null;");
        } else {
          codeBuffer.writeln(spaces(4) +
              "final Map<String, dynamic> " +
              field.fieldName +
              "Map"
                  " = " +
              field.fieldName +
              " != null ");
          codeBuffer
              .writeln(spaces(8) + "? " + field.fieldName + ".toDocument()");
          codeBuffer.writeln(spaces(8) + ": null;");
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.writeln(spaces(4) + "return {");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(spaces(6) + "\"" + field.fieldName + "\": ");
      if (!field.isNativeType()) {
        if (field.array) {
          codeBuffer.writeln(field.fieldName + "ListMap, ");
        } else {
          codeBuffer.writeln(field.fieldName + "Map, ");
        }
      } else {
        if (field.array) {
          codeBuffer.writeln(field.fieldName + ".toList(), ");
        } else {
          codeBuffer.writeln(field.fieldName + ", ");
        }
      }
    });
    codeBuffer.writeln(spaces(4) + "};");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _body() {
    StringBuffer codeBuffer = StringBuffer();

    String className = modelSpecifications.entityClassName();
    codeBuffer.writeln("class $className {");

    codeBuffer.writeln(_fieldDefinitions());
    codeBuffer.write(getConstructor(modelSpecifications.entityClassName()));
    codeBuffer.writeln(_getProps());
    codeBuffer.writeln(toStringCode(modelSpecifications.entityClassName()));
    codeBuffer.writeln(_fromMap());
    codeBuffer.writeln(_toDocument());

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.write(_commonImports());
    codeBuffer.write(_body());
    return codeBuffer.toString();
  }
}
