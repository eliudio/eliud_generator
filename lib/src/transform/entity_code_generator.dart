import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'data_code_generator.dart';

const String _jsonMethods = """
  static \${id}Entity fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromMap(generationSpecificationMap);
  }

  String toJsonString() {
    return jsonEncode(toDocument());
  }
""";

class EntityCodeGenerator extends DataCodeGenerator {
  EntityCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  String fieldName(Field field) {
    if (field.association) return field.fieldName + "Id";
    return field.fieldName;
  }

  String theFileName() {
    return modelSpecifications.entityFileName();
  }

  String dartEntityType(Field field) {
    if (field.association) return "String";
    return field.dartEntityType();
  }

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:collection';");
    headerBuffer.writeln("import 'dart:convert';");

    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if ((!field.isEnum()) && (!field.isNativeType())) {
        headerBuffer.writeln("import '" +
            resolveImport(
                importThis:
                    camelcaseToUnderscore(field.fieldType) + "_entity.dart") +
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
      if (field.fieldName != "documentID")
        codeBuffer.writeln(
            "  final " + dartEntityType(field) + " " + fieldName(field) + ";");
    });
    return codeBuffer.toString();
  }

  String _getProps() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + "List<Object> get props => [");
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName != "documentID")
        codeBuffer.write(fieldName(field) + ", ");
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
    codeBuffer.writeln(spaces(4) + "if (map == null) return null;");
    codeBuffer.writeln();
    modelSpecifications.fields.forEach((field) {
      if ((!field.isEnum()) &&
          (!field.association) &&
          (!field.isNativeType())) {
        extraLine = true;
        if (field.array) {
          codeBuffer.writeln(spaces(4) +
              "final " +
              fieldName(field) +
              "List = (map['" +
              fieldName(field) +
              "'] as List<dynamic>)");
          codeBuffer.writeln(spaces(8) + ".map((dynamic item) =>");
          codeBuffer.writeln(
              spaces(8) + field.fieldType + "Entity.fromMap(item as Map))");
          codeBuffer.writeln(spaces(8) + ".toList();");
        } else {
          codeBuffer
              .writeln(spaces(4) + "var " + fieldName(field) + "FromMap;");
          codeBuffer.writeln(spaces(4) +
              fieldName(field) +
              "FromMap = map['" +
              fieldName(field) +
              "'];");
          codeBuffer.writeln(
              spaces(4) + "if (" + fieldName(field) + "FromMap != null)");
          codeBuffer.writeln(spaces(6) +
              fieldName(field) +
              "FromMap = " +
              field.fieldType +
              "Entity.fromMap(" +
              fieldName(field) +
              "FromMap);");
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.writeln(
        spaces(4) + "return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName != "documentID") {
        codeBuffer.write(spaces(6) + fieldName(field) + ": ");
        if ((field.association) || (field.isEnum())) {
          codeBuffer.writeln("map['" + fieldName(field) + "'], ");
        } else {
          if (!field.isNativeType()) {
            if (field.array) {
              codeBuffer.writeln(fieldName(field) + "List, ");
            } else {
              codeBuffer.writeln(fieldName(field) + "FromMap, ");
            }
          } else {
            if (field.array) {
              codeBuffer
                  .writeln("List.from(map['" + fieldName(field) + "']), ");
            } else {
              if (field.isDouble())
                codeBuffer.writeln("double.tryParse(map['" + fieldName(field) + "'].toString()), ");
              else if (field.isInt())
                codeBuffer.writeln("int.tryParse(map['" + fieldName(field) + "'].toString()), ");
              else
                codeBuffer.writeln("map['" + fieldName(field) + "'], ");

            }
          }
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
      if ((!field.isEnum()) &&
          (!field.association) &&
          (!field.isNativeType())) {
        extraLine = true;
        if (field.array) {
          codeBuffer.writeln(spaces(4) +
              "final List<Map<String, dynamic>> " +
              fieldName(field) +
              "ListMap" +
              " = " +
              fieldName(field) +
              " != null ");
          codeBuffer.writeln(spaces(8) +
              "? " +
              fieldName(field) +
              ".map((item) => item.toDocument()).toList()");
          codeBuffer.writeln(spaces(8) + ": null;");
        } else {
          codeBuffer.writeln(spaces(4) +
              "final Map<String, dynamic> " +
              fieldName(field) +
              "Map"
                  " = " +
              fieldName(field) +
              " != null ");
          codeBuffer
              .writeln(spaces(8) + "? " + fieldName(field) + ".toDocument()");
          codeBuffer.writeln(spaces(8) + ": null;");
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer
        .writeln(spaces(4) + "Map<String, Object> theDocument = HashMap();");
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName != "documentID") {
        codeBuffer.write(spaces(4) +
            "if (" +
            fieldName(field) +
            " != null) " +
            "theDocument[\"" +
            fieldName(field) +
            "\"] = ");
        if ((field.association) || (field.isEnum())) {
          codeBuffer.writeln(fieldName(field) + ";");
        } else {
          if (!field.isNativeType()) {
            if (field.array) {
              codeBuffer.writeln(fieldName(field) + "ListMap;");
            } else {
              codeBuffer.writeln(fieldName(field) + "Map;");
            }
          } else {
            if (field.array) {
              codeBuffer.writeln(fieldName(field) + ".toList();");
            } else {
              codeBuffer.writeln(fieldName(field) + ";");
            }
          }
        }
        codeBuffer.writeln(spaces(6) +
            "else theDocument[\"" +
            fieldName(field) +
            "\"] = null;");
      }
    });
    codeBuffer.writeln(spaces(4) + "return theDocument;");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();

    String className = modelSpecifications.entityClassName();
    codeBuffer.writeln("class $className {");

    codeBuffer.writeln(_fieldDefinitions());
    codeBuffer.write(getConstructor(
        removeDocumentID: true,
        name: modelSpecifications.entityClassName(),
        terminate: true));
    codeBuffer.writeln(_getProps());
    codeBuffer
        .writeln(toStringCode(true, modelSpecifications.entityClassName()));
    codeBuffer.writeln(_fromMap());
    codeBuffer.writeln(_toDocument());

    codeBuffer.writeln(process(_jsonMethods, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
    }));

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }
}
