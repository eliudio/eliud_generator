import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'data_code_generator.dart';

class ModelCodeGenerator extends DataCodeGenerator {
  ModelCodeGenerator({ModelSpecification modelSpecifications}) : super(modelSpecifications: modelSpecifications);

  String fieldName(Field field) {
    return field.fieldName;
  }

  String theFileName() {
    return modelSpecifications.modelFileName();
  }

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    if (hasArray()) headerBuffer.writeln("import 'package:collection/collection.dart';");
    headerBuffer.writeln("import 'package:eliud_model/shared/abstract_repository_singleton.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + modelSpecifications.entityFileName() + "';");
    modelSpecifications.fields.forEach((field) {
      if ((!field.isEnum()) && (!field.isNativeType())) {
        headerBuffer.writeln("import '" + resolveImport(importThis: camelcaseToUnderscore(field.fieldType) + "_model.dart") + "';");
      }
    });

    uniqueAssociationTypes.forEach((type) {
      headerBuffer.writeln("import '" + resolveImport(importThis: camelcaseToUnderscore(type) + "_repository.dart") + "';");
    });

    headerBuffer.writeln("import '../tools/random.dart';");

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _enums() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.isEnum()) {
        codeBuffer.writeln("enum " + field.enumName + " {");
        codeBuffer.write(spaces(2));
        field.enumValues.forEach((value) {
          codeBuffer.write(value + ", ");
        });
        codeBuffer.writeln("Unknown");
        codeBuffer.writeln("}");
        codeBuffer.writeln();
      }
    });
    return codeBuffer.toString();
  }

  String _enumMethods() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.isEnum()) {
        codeBuffer.writeln(field.enumName + " to" + field.enumName + "(int index) {");
        codeBuffer.writeln(spaces(2) + "switch (index) {");
        int index = 0;
        field.enumValues.forEach((value) {
          codeBuffer.writeln(spaces(4) + "case $index: return " + field.enumName + "." + value + ";");
          index++;
        });
        codeBuffer.writeln(spaces(2) + "}");
        codeBuffer.writeln(spaces(2) + "return " + field.enumName + ".Unknown;");
        codeBuffer.writeln("}");
        codeBuffer.writeln();
      }
    });
    return codeBuffer.toString();
  }

  String _fieldDefinitions() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if ((field.remark != null) && (field.remark.length > 0)) {
        codeBuffer.writeln();
        codeBuffer.writeln(spaces(2) + "// " + field.remark);
      }
      codeBuffer.write(spaces(2));
      if (!field.association)
        codeBuffer.write("final ");
      codeBuffer.writeln(field.dartModelType() + " " + field.fieldName + ";");
    });
    return codeBuffer.toString();
  }

  String _constructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(getConstructor(removeDocumentID: false, name: modelSpecifications.modelClassName(), terminate: false));
    codeBuffer.writeln(spaces(2) + "{");
    if (hasDocumentID())
      codeBuffer.writeln(spaces(4) + "assert(documentID != null);");
    codeBuffer.writeln(spaces(2) + "}");

    return codeBuffer.toString();
  }

  String _copyWith() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + modelSpecifications.modelClassName() + " copyWith({");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(
          field.dartModelType() + " " + field.fieldName + ", ");
    });
    codeBuffer.writeln("}) {");
    codeBuffer.write(spaces(4) + "return " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ": " + field.fieldName + " ?? this." + field.fieldName + ", ");
    });
    codeBuffer.writeln(");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _hashCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.write(spaces(2) + "int get hashCode => ");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ".hashCode");
      if (modelSpecifications.fields.last != field) {
        codeBuffer.write(" ^ ");
      }
    });
    codeBuffer.writeln(";");
    return codeBuffer.toString();
  }

  String _equalsOperator() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "bool operator ==(Object other) =>");
    codeBuffer.writeln(spaces(10) + "identical(this, other) ||");
    codeBuffer.writeln(spaces(10) + "other is " + modelSpecifications.modelClassName() + " &&");
    codeBuffer.writeln(spaces(10) + "runtimeType == other.runtimeType && ");
    modelSpecifications.fields.forEach((field) {
      if (field.array) {
        codeBuffer.write(
            spaces(10) + "ListEquality().equals(" + field.fieldName + ", other." + field.fieldName + ")");
      } else {
        codeBuffer.write(
            spaces(10) + field.fieldName + " == other." + field.fieldName);
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.writeln(" &&");
      }
    });
    codeBuffer.writeln(";");
    return codeBuffer.toString();
  }

  String _toEntity() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.entityClassName() + " toEntity() {");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName != "documentID") {
        codeBuffer.write(spaces(10) + field.fieldName);
        if (field.association) codeBuffer.write("Id");
        codeBuffer.write(
            ": (" + field.fieldName + " != null) ? " + field.fieldName);
        if (field.isEnum()) {
          codeBuffer.write(".index");
        } else if (field.association) {
          codeBuffer.write(".documentID");
        } else {
          if (!field.isNativeType()) {
            if (field.array) {
              codeBuffer.writeln();
              codeBuffer.writeln(
                  spaces(12) + ".map((item) => item.toEntity())");
              codeBuffer.write(spaces(12) + ".toList()");
            } else {
              codeBuffer.write(".toEntity()");
            }
          }
        }
        codeBuffer.writeln(" : null, ");
      }
    });
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _fromEntity() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + "static " + modelSpecifications.modelClassName() + " fromEntity(");
    if (modelSpecifications.fields[0].fieldName == "documentID") {
      codeBuffer.write("String documentID, ");
    }
    codeBuffer.writeln(modelSpecifications.entityClassName() + " entity) {");
    codeBuffer.writeln(spaces(4) + "if (entity == null) return null;");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (!field.association) {
        codeBuffer.write(spaces(10) + field.fieldName + ": ");
        if (field.isEnum()) {
          codeBuffer.write("to" + field.enumName + "(entity." + field.fieldName + ")");
        } else if (!field.isNativeType()) {
          if (field.array) {
            codeBuffer.writeln();
            codeBuffer.writeln(spaces(12) + "entity. " + field.fieldName);
            codeBuffer.writeln(
                spaces(12) + ".map((item) => " + field.fieldType +
                    "Model.fromEntity(newRandomKey(), item))");
            codeBuffer.write(spaces(12) + ".toList()");
          } else {
            codeBuffer.writeln();
            codeBuffer.write(
                spaces(12) + field.fieldType + "Model.fromEntity(entity." +
                    field.fieldName + ")");
          }
        } else {
          if (field.fieldName == "documentID") {
            codeBuffer.write(field.fieldName);
          } else {
            codeBuffer.write("entity." + field.fieldName);
          }
        }
        codeBuffer.writeln(", ");
      }
    });
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _fromEntityPlus() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + "static Future<" + modelSpecifications.modelClassName() + "> fromEntityPlus(");
    if (modelSpecifications.fields[0].fieldName == "documentID") {
      codeBuffer.write("String documentID, ");
    }
    codeBuffer.writeln(modelSpecifications.entityClassName() + " entity) async {");
    codeBuffer.writeln(spaces(4) + "if (entity == null) return null;");
    codeBuffer.writeln();
    modelSpecifications.fields.forEach((field) {
      if (field.association) {
        codeBuffer.writeln(spaces(4) + field.fieldType + "Model " + field.fieldName + "Holder;");
        codeBuffer.writeln(spaces(4) + "if (entity." + field.fieldName + "Id != null) {");
        codeBuffer.writeln(spaces(6) + "try {");
        codeBuffer.writeln(spaces(8) + "await AbstractRepositorySingleton.singleton." + firstLowerCase(field.fieldType) + "Repository().get(entity." + field.fieldName + "Id" + ").then((val) {");
        codeBuffer.writeln(spaces(10) + field.fieldName + "Holder" + " = val;");
        codeBuffer.writeln(spaces(8) + "}).catchError((error) {});");
        codeBuffer.writeln(spaces(6) + "} catch (_) {}");
        codeBuffer.writeln(spaces(4) + "}");
        codeBuffer.writeln();
      }
    });
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.modelClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(spaces(10) + field.fieldName + ": ");
      if (field.isEnum()) {
        codeBuffer.write(
            "to" + field.enumName + "(entity." + field.fieldName + ")");
      } else if (field.association) {
        codeBuffer.write(field.fieldName + "Holder");
      } else {
        if (!field.isNativeType()) {
          if (field.array) {
            codeBuffer.writeln();
            // this construct of creating a list from a list is to make a dynamic list from a fixed sized list.
            // The reason for requiring a non fixed sized list is because we need to be able to use replaceRange in XyzInMemoryRepository
            codeBuffer.writeln(spaces(12) + "new List<" + field.fieldType +
                "Model>.from(await Future.wait(entity. " + field.fieldName);
            codeBuffer.writeln(
                spaces(12) + ".map((item) => " + field.fieldType +
                    "Model.fromEntityPlus(newRandomKey(), item))");
            codeBuffer.write(spaces(12) + ".toList()))");
          } else {
            codeBuffer.writeln();
            codeBuffer.write(
                spaces(12) + "await " + field.fieldType + "Model.fromEntityPlus(entity." +
                    field.fieldName + ")");
          }
        } else {
          if (field.fieldName == "documentID") {
            codeBuffer.write(field.fieldName);
          } else {
            codeBuffer.write("entity." + field.fieldName);
          }
        }
      }
      codeBuffer.writeln(", ");
    });
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();

    codeBuffer.writeln(_enums());
    codeBuffer.writeln(_enumMethods());

    String className = modelSpecifications.modelClassName();
    codeBuffer.writeln("class $className {");

    codeBuffer.writeln(_fieldDefinitions());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_copyWith());
    codeBuffer.writeln(_hashCode());
    codeBuffer.writeln(_equalsOperator());
    codeBuffer.writeln(toStringCode(false, modelSpecifications.modelClassName()));
    codeBuffer.writeln(_toEntity());
    codeBuffer.writeln(_fromEntity());
    codeBuffer.writeln(_fromEntityPlus());

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }
}
