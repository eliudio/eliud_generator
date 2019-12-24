import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ModelCodeGenerator extends CodeGenerator {
  final ModelSpecification modelSpecifications;

  ModelCodeGenerator({this.modelSpecifications});

  String theFileName() {
    return fileName(modelSpecifications.modelClassName());
  }

  bool hasArray() {
    bool returnMe = false;
    modelSpecifications.fields.forEach((field) {
      if (field.array) returnMe = true;
    });
    return returnMe;
  }

  String getCommonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:meta/meta.dart';");
    if (hasArray()) headerBuffer.writeln("import 'package:collection/collection.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + fileName(modelSpecifications.entityClassName()) + "'");
    modelSpecifications.fields.forEach((field) {
      if (!field.isNativeType()) {
        headerBuffer.writeln("import '" + fileName(field.fieldType) + "';");
      }
    });
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String getBody() {
    StringBuffer codeBuffer = StringBuffer();

    codeBuffer.writeln("@immutable");
    String className = modelSpecifications.modelClassName();
    codeBuffer.writeln("class $className {");

    // Field definitions
    modelSpecifications.fields.forEach((field) {
      codeBuffer.writeln(
          "  final " + field.dartType() + " " + field.fieldName);
    });
    codeBuffer.writeln();

    // Constructor
    codeBuffer.write("  " + modelSpecifications.modelClassName() + "({");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(
          "this." + field.fieldName + ", ");
    });
    codeBuffer.writeln("});");
    codeBuffer.writeln();

    // copyWith
    codeBuffer.write("  " + modelSpecifications.modelClassName() + " copyWith({");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(
          field.dartType() + " " + field.fieldName + ", ");
    });
    codeBuffer.writeln("}) {");
    codeBuffer.write("    return " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ": " + field.fieldName + " ?? this." + field.fieldName + ", ");
    });
    codeBuffer.writeln(");");
    codeBuffer.writeln("  }");
    codeBuffer.writeln();

    // hashCode
    codeBuffer.writeln("  @override");
    codeBuffer.write("  int get hashCode => ");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ".hashCode");
      if (modelSpecifications.fields.last != field) {
        codeBuffer.write(" ^ ");
      }
    });
    codeBuffer.writeln(";");
    codeBuffer.writeln();

    // operator ==
    codeBuffer.writeln("  @override");
    codeBuffer.writeln("  bool operator ==(Object other) =>");
    codeBuffer.writeln("      identical(this, other) ||");
    codeBuffer.writeln("      other is " + modelSpecifications.modelClassName() + " &&");
    codeBuffer.writeln("          runtimeType == other.runtimeType && ");
    modelSpecifications.fields.forEach((field) {
      if (field.array) {
        codeBuffer.write(
            "          ListEquality().equals(" + field.fieldName + ", other." + field.fieldName + ")");
      } else {
        codeBuffer.write(
            "          " + field.fieldName + " == other." + field.fieldName);
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.writeln(" &&");
      }
    });
    codeBuffer.writeln(";");
    codeBuffer.writeln();

    // toString
    codeBuffer.writeln("  @override");
    codeBuffer.writeln("  String toString() {");
    modelSpecifications.fields.forEach((field) {
      if (field.array) {
        codeBuffer.write(
            "    String " + field.fieldName + "Csv = " + field.fieldName + ".join(', ');");
      }
    });
    codeBuffer.writeln();
    codeBuffer.write("    return '" + modelSpecifications.modelClassName() + "{");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ": ");
      if (field.array) {
        codeBuffer.write(field.fieldType + "[] { \$" + field.fieldName + "Csv }");
      } else {
        codeBuffer.write("\$" + field.fieldName);
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.write(", ");
      }
    });
    codeBuffer.writeln("}';");
    codeBuffer.writeln("  }");
    codeBuffer.writeln();

    // toEntity
    codeBuffer.writeln("  " + modelSpecifications.entityClassName() + " toEntity() {");
    codeBuffer.writeln("    return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write("          " + field.fieldName + ": " + field.fieldName);
      if (field.array) {
        codeBuffer.writeln();
        codeBuffer.writeln("            .map((item) => item.toEntity())");
        codeBuffer.write("            .toList()");
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.writeln(", ");
      }
    });
    codeBuffer.writeln(");");
    codeBuffer.writeln("  }");
    codeBuffer.writeln();

    // fromEntity
    codeBuffer.writeln("  static " + modelSpecifications.modelClassName() + " fromEntity(" + modelSpecifications.entityClassName() + " entity) {");
    codeBuffer.writeln("    return " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write("          " + field.fieldName + ": entity." + field.fieldName);
      if (field.array) {
        codeBuffer.writeln();
        codeBuffer.writeln("            .map((item) => " + field.fieldType + ".fromEntity(item))");
        codeBuffer.write("            .toList()");
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.writeln(", ");
      }
    });
    codeBuffer.writeln(");");
    codeBuffer.writeln("  }");

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(getHeader());
    codeBuffer.write(getCommonImports());
    codeBuffer.write(getBody());
    return codeBuffer.toString();
  }
}
