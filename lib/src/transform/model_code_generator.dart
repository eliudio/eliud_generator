import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

String _imports(String packageName, List<String>? depends) =>
    """import 'package:eliud_core_helpers/helpers/common_tools.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eliud_core_helpers/base/model_base.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:eliud_core_main/model/app_model.dart';

${base_imports(packageName, repo: true, model: true, entity: true, depends: depends)}""";

String _arrayImageExtract = """
    if (\${var} != null) {
      final List<List<int>> values = [];
      for (var value in \${var}!) {
        var \${var2} = value.\${var2}!;
        var uri\${var2} = Uri.parse(\${var2});
        final response = await http.get(uri\${var2});
        List<int> bytes = response.bodyBytes.toList();
        values.add(bytes);
      }
      document['\${var}-extract'] = values;
    }
""";

String _imageExtract = """
    if ((\${var} != null) && (\${var}!.\${var2} != null)) {
      var \${var2} = \${var}!.\${var2}!;
      var uri\${var2} = Uri.parse(\${var2});
      final response = await http.get(uri\${var2});
      var bytes = response.bodyBytes.toList();
      document['\${var}-extract'] = bytes.toList();
    }
""";

class ModelCodeGenerator extends DataCodeGenerator {
  ModelCodeGenerator({required super.modelSpecifications});

  @override
  String fieldName(Field field) {
    return field.fieldName;
  }

  @override
  String theFileName() {
    return modelSpecifications.modelFileName();
  }

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    if (hasArray()) {
      headerBuffer.writeln("import 'package:collection/collection.dart';");
    }
    headerBuffer.writeln(
        _imports(modelSpecifications.packageName, modelSpecifications.depends));
    headerBuffer.writeln();
    headerBuffer.writeln(importString(modelSpecifications.packageName,
        'model/${modelSpecifications.entityFileName()}'));

    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_MODEL);
    headerBuffer
        .writeln("import 'package:eliud_core_helpers/etc/random.dart';");

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _enums() {
    StringBuffer codeBuffer = StringBuffer();
    for (var field in modelSpecifications.fields) {
      if (field.isEnum()) {
        codeBuffer.writeln("enum ${field.getEnumName()} {");
        codeBuffer.write(spaces(2));
        if (field.enumValues != null) {
          for (var value in field.enumValues!) {
            codeBuffer.write("${firstLowerCase(value)}, ");
          }
        }
        codeBuffer.writeln("unknown");
        codeBuffer.writeln("}");
        codeBuffer.writeln();
      }
    }
    return codeBuffer.toString();
  }

  String _enumMethods() {
    StringBuffer codeBuffer = StringBuffer();
    for (var field in modelSpecifications.fields) {
      if (field.isEnum()) {
        codeBuffer.writeln(
            "${field.getEnumName()} to${field.getEnumName()}(int? index) {");
        codeBuffer.writeln("${spaces(2)}switch (index) {");
        int index = 0;
        if (field.enumValues != null) {
          for (var value in field.enumValues!) {
            codeBuffer.writeln(
                "${spaces(4)}case $index: return ${field.getEnumName()}.${firstLowerCase(value)};");
            index++;
          }
        }
        codeBuffer.writeln("${spaces(2)}}");
        codeBuffer
            .writeln("${spaces(2)}return ${field.getEnumName()}.unknown;");
        codeBuffer.writeln("}");
        codeBuffer.writeln();
      }
    }
    return codeBuffer.toString();
  }

  String _fieldDefinitions() {
    StringBuffer codeBuffer = StringBuffer();
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if ((field.remark != null) && (field.getRemark().isNotEmpty)) {
          codeBuffer.writeln();
          codeBuffer.writeln("${spaces(2)}// ${field.getRemark()}");
        }
        codeBuffer.write(spaces(2));
        codeBuffer.writeln(
            "${field.dartModelType()}${field.isRequired ?? false ? ' ' : "? "}${field.fieldName};");
      }
    }
    return codeBuffer.toString();
  }

  String _constructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(getConstructor(
        removeDocumentID: false,
        name: modelSpecifications.modelClassName(),
        terminate: false));
    codeBuffer.writeln("${spaces(2)}{");
    if (hasDocumentID()) {
      codeBuffer.writeln("${spaces(4)}assert(documentID != null);");
    }
    codeBuffer.writeln("${spaces(2)}}");

    return codeBuffer.toString();
  }

  String _copyWith() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(
        "${spaces(2)}${modelSpecifications.modelClassName()} copyWith({");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.write("${field.dartModelType()}? ${field.fieldName}, ");
      }
    }
    codeBuffer.writeln("}) {");
    codeBuffer
        .write("${spaces(4)}return ${modelSpecifications.modelClassName()}(");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.write(
            "${field.fieldName}: ${field.fieldName} ?? this.${field.fieldName}, ");
      }
    }
    codeBuffer.writeln(");");
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _hashCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.write("${spaces(2)}int get hashCode => ");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.write("${field.fieldName}.hashCode");
        if (modelSpecifications.fields.last != field) {
          codeBuffer.write(" ^ ");
        }
      }
    }
    codeBuffer.writeln(";");
    return codeBuffer.toString();
  }

  String _equalsOperator() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.writeln("${spaces(2)}bool operator ==(Object other) =>");
    codeBuffer.writeln("${spaces(10)}identical(this, other) ||");
    codeBuffer.writeln(
        "${spaces(10)}other is ${modelSpecifications.modelClassName()} &&");
    codeBuffer.writeln("${spaces(10)}runtimeType == other.runtimeType && ");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.isArray()) {
          codeBuffer.write(
              "${spaces(10)}ListEquality().equals(${field.fieldName}, other.${field.fieldName})");
        } else {
          codeBuffer.write(
              "${spaces(10)}${field.fieldName} == other.${field.fieldName}");
        }
        if (modelSpecifications.fields.last != field) {
          codeBuffer.writeln(" &&");
        }
      }
    }
    codeBuffer.writeln(";");
    return codeBuffer.toString();
  }

  String _toEntity() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        "${spaces(2)}${modelSpecifications.entityClassName()} toEntity({String? appId}) {");
    if (modelSpecifications.preToEntityCode != null) {
      codeBuffer.writeln(spaces(4) + modelSpecifications.getPreToEntityCode());
    }

    codeBuffer.writeln(
        "${spaces(4)}return ${modelSpecifications.entityClassName()}(");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldName != "documentID") {
          codeBuffer.write(spaces(10) + field.fieldName);
          if (field.isServerTimestamp()) {
            codeBuffer.writeln(
                ": (${field.fieldName} == null) ? null : ${field.fieldName}!.millisecondsSinceEpoch, ");
          } else if (field.isBespoke()) {
            codeBuffer.writeln(": ${field.fieldName}, ");
          } else {
            if (field.isAssociation()) codeBuffer.write("Id");
            if (!field.isDartRequired()) {
              codeBuffer
                  .write(": (${field.fieldName} != null) ? ${field.fieldName}");
            } else {
              codeBuffer.write(": ${field.fieldName}");
            }
            if (field.isEnum()) {
              if (field.isMap()) {
                codeBuffer.write(
                    "!.map((key, value) => MapEntry(key, value!.index))");
              } else {
                codeBuffer.write("!.index");
              }
            } else if (field.isAssociation()) {
              codeBuffer.write("!.documentID");
            } else {
              if (!field.isNativeType()) {
                if (field.isArray()) {
                  if (field.arrayType != ArrayType.CollectionArrayType) {
                    codeBuffer.writeln();
                    codeBuffer.writeln(
                        "${spaces(12)}!.map((item) => item.toEntity(appId: appId))");
                    codeBuffer.write("${spaces(12)}.toList()");
                  } else {
                    codeBuffer.write("${spaces(12)}what to do here?");
                  }
                } else {
                  codeBuffer.write("!.toEntity(appId: appId)");
                }
              }
            }
            if (!field.isDartRequired()) {
              codeBuffer.writeln(" : null, ");
            } else {
              codeBuffer.writeln(", ");
            }
          }
        }
      }
    }
    codeBuffer.writeln("${spaces(4)});");
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _collectReferences() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        "${spaces(2)}Future<List<ModelReference>> collectReferences({String? appId}) async {");
    codeBuffer
        .writeln("${spaces(4)}List<ModelReference> referencesCollector = [];");

    if (modelSpecifications.codeToCollectReferences != null) {
      codeBuffer.writeln(modelSpecifications.codeToCollectReferences);
    }

    for (var field in modelSpecifications.fields) {
      if (field.isAssociation()) {
        codeBuffer.writeln("${spaces(4)}if (${field.fieldName} != null) {");
        codeBuffer.writeln(
            "${spaces(6)}referencesCollector.add(ModelReference(${field.fieldType}Model.packageName, ${field.fieldType}Model.id, ${field.fieldName}!));");
        codeBuffer.writeln("${spaces(4)}}");
      } else if (field.refCode != null) {
        codeBuffer.writeln(spaces(4) + field.refCode!);
      }
    }

    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if ((!field.isNativeType()) &&
            (!field.isEnum()) && /*(!field.isAssociation()) && */
            (!field.isServerTimestamp()) &&
            (!field.isBespoke())) {
          if (field.isArray()) {
            if (field.arrayType != ArrayType.CollectionArrayType) {
              codeBuffer
                  .writeln("${spaces(4)}if (${field.fieldName} != null) {");
              codeBuffer.writeln(
                  "${spaces(6)}for (var item in ${field.fieldName}!) {");
              codeBuffer.writeln(
                  "${spaces(8)}referencesCollector.addAll(await item.collectReferences(appId: appId));");
              codeBuffer.writeln("${spaces(6)}}");
              codeBuffer.writeln("${spaces(4)}}");
            }
          } else {
            codeBuffer.writeln(
                "${spaces(4)}if (${field.fieldName} != null) { referencesCollector.addAll(await ${field.fieldName}!.collectReferences(appId: appId)); }");
          }
        }
      }
    }
    codeBuffer.writeln("${spaces(4)}return referencesCollector;");
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  bool needsCounterForFromEntity() {
    bool returnMe = false;
    for (var field in modelSpecifications.fields) {
      if (field.isServerTimestamp()) {
      } else if (field.isBespoke()) {
      } else {
        if (field.arrayType != ArrayType.CollectionArrayType) {
          if (!field.isAssociation()) {
            if (field.isEnum()) {
            } else if (!field.isNativeType()) {
              if (field.isArray()) {
                returnMe = true;
              }
            }
          }
        }
      }
    }
    return returnMe;
  }

  bool needsCounterForFromEntityPlus() {
    bool returnMe = false;
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.isServerTimestamp()) {
        } else if (field.isBespoke()) {
        } else {
          if (field.isEnum()) {
          } else if (field.isAssociation()) {
          } else {
            if (!field.isNativeType()) {
              if (field.isArray()) {
                if (field.arrayType != ArrayType.CollectionArrayType) {
                  returnMe = true;
                }
              }
            }
          }
        }
      }
    }
    return returnMe;
  }

  String _fromEntity() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(
        "${spaces(2)}static Future<${modelSpecifications.modelClassName()}?> fromEntity(");
    if (modelSpecifications.fields[0].fieldName == "documentID") {
      codeBuffer.write("String documentID, ");
    }
    codeBuffer
        .writeln("${modelSpecifications.entityClassName()}? entity) async {");
    codeBuffer.writeln("${spaces(4)}if (entity == null) return null;");
    if (needsCounterForFromEntity()) {
      codeBuffer.writeln("${spaces(4)}var counter = 0;");
    }
    codeBuffer
        .writeln("${spaces(4)}return ${modelSpecifications.modelClassName()}(");
    for (var field in modelSpecifications.fields) {
      if (field.isServerTimestamp()) {
        codeBuffer.writeln(
            "${spaces(10)}${field.fieldName}: entity.${field.fieldName} == null ? null : DateTime.fromMillisecondsSinceEpoch((entity.${field.fieldName} as int)), ");
      } else if (field.isBespoke()) {
        codeBuffer.writeln(
            "${spaces(10)}${field.fieldName}: entity.${field.fieldName}, ");
      } else {
        if (field.arrayType != ArrayType.CollectionArrayType) {
          if (!field.isAssociation()) {
            codeBuffer.write("${spaces(10)}${field.fieldName}: ");
            if (field.isEnum()) {
              if (field.isMap()) {
                codeBuffer.write(
                    "entity.${field.fieldName}!.map((key, value) => MapEntry(key, to${field.getEnumName()}(value)))");
              } else {
                codeBuffer.write(
                    "to${field.getEnumName()}(entity.${field.fieldName})");
              }
            } else if (!field.isNativeType()) {
              if (field.isArray()) {
                codeBuffer.writeln();
                codeBuffer.writeln(
                    "${spaces(12)}entity.${field.fieldName} == null ? null : List<${field.fieldType}Model>.from(await Future.wait(entity. ${field.fieldName}");
                codeBuffer.writeln("${spaces(12)}!.map((item) {");
                codeBuffer.writeln("${spaces(12)}counter++;");
                codeBuffer.writeln(
                    "${spaces(14)}return ${field.fieldType}Model.fromEntity(counter.toString(), item);");
                codeBuffer.writeln("${spaces(12)}})");
                codeBuffer.write("${spaces(12)}.toList()))");
              } else {
                codeBuffer.writeln();
                codeBuffer.write(
                    "${spaces(12)}await ${field.fieldType}Model.fromEntity(entity.${field.fieldName})");
              }
            } else {
              if (field.fieldName == "documentID") {
                codeBuffer.write(field.fieldName);
              } else {
                codeBuffer.write(
                    "entity.${field.fieldName}${field.isRequired ?? false ? " ?? ''" : ''}");
              }
            }
            codeBuffer.writeln(", ");
          }
        }
      }
    }
    codeBuffer.writeln("${spaces(4)});");
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _fromEntityPlus() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(
        "${spaces(2)}static Future<${modelSpecifications.modelClassName()}?> fromEntityPlus(");
    if (modelSpecifications.fields[0].fieldName == "documentID") {
      codeBuffer.write("String documentID, ");
    }
    codeBuffer.writeln(
        "${modelSpecifications.entityClassName()}? entity, { String? appId}) async {");
    codeBuffer.writeln("${spaces(4)}if (entity == null) return null;");
    codeBuffer.writeln();
    for (var field in modelSpecifications.fields) {
      if (field.isAssociation()) {
        codeBuffer.writeln(
            "${spaces(4)}${field.fieldType}Model? ${field.fieldName}Holder;");
        codeBuffer
            .writeln("${spaces(4)}if (entity.${field.fieldName}Id != null) {");

        codeBuffer.writeln("${spaces(6)}try {");
        codeBuffer.writeln(
            "${spaces(8)}  ${field.fieldName}Holder = await ${firstLowerCase(field.fieldType)}Repository(appId: appId)!.get(entity.${field.fieldName}Id);");
        codeBuffer.writeln("${spaces(6)}} on Exception catch(e) {");
        codeBuffer.writeln(
            "${spaces(8)}print('Error whilst trying to initialise ${field.fieldName}');");
        codeBuffer.writeln(
            "${spaces(8)}print('Error whilst retrieving ${firstLowerCase(field.fieldType)} with id \${entity.${field.fieldName}Id}');");
        codeBuffer.writeln("${spaces(8)}print('Exception: \$e');");
        codeBuffer.writeln("${spaces(6)}}");

        codeBuffer.writeln("${spaces(4)}}");
        codeBuffer.writeln();
      }
    }
    if (needsCounterForFromEntityPlus()) {
      codeBuffer.writeln("${spaces(4)}var counter = 0;");
    }
    codeBuffer
        .writeln("${spaces(4)}return ${modelSpecifications.modelClassName()}(");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        codeBuffer.write("${spaces(10)}${field.fieldName}: ");
        if (field.isServerTimestamp()) {
          codeBuffer.write(
              "entity.${field.fieldName} == null ? null : DateTime.fromMillisecondsSinceEpoch((entity.${field.fieldName} as int))");
        } else if (field.isBespoke()) {
          codeBuffer.write("entity.${field.fieldName}");
        } else {
          if (field.isEnum()) {
            if (field.isMap()) {
              codeBuffer.write(
                  "entity.${field.fieldName}!.map((key, value) => MapEntry(key, to${field.getEnumName()}(value)))");
            } else {
              codeBuffer
                  .write("to${field.getEnumName()}(entity.${field.fieldName})");
            }
          } else if (field.isAssociation()) {
            codeBuffer.write("${field.fieldName}Holder");
          } else {
            if (!field.isNativeType()) {
              if (field.isArray()) {
                if (field.arrayType != ArrayType.CollectionArrayType) {
                  codeBuffer.writeln();
                  // this construct of creating a list from a list is to make a dynamic list from a fixed sized list.
                  // The reason for requiring a non fixed sized list is because we need to be able to use replaceRange in XyzInMemoryRepository
                  codeBuffer.writeln(
                      "${spaces(12)}entity. ${field.fieldName} == null ? null : List<${field.fieldType}Model>.from(await Future.wait(entity. ${field.fieldName}");
                  codeBuffer.writeln("${spaces(12)}!.map((item) {");
                  codeBuffer.writeln("${spaces(12)}counter++;");
                  codeBuffer.writeln(
                      "${spaces(12)}return ${field.fieldType}Model.fromEntityPlus(counter.toString(), item, appId: appId);})");
                  codeBuffer.write("${spaces(12)}.toList()))");
                } else {
                  codeBuffer.write(
                      "await ${firstLowerCase(field.fieldType)}Repository(documentID).valuesList()");
                }
              } else {
                codeBuffer.writeln();
                codeBuffer.write(
                    "${spaces(12)}await ${field.fieldType}Model.fromEntityPlus(entity.${field.fieldName}, appId: appId)");
              }
            } else {
              if (field.fieldName == "documentID") {
                codeBuffer.write(field.fieldName);
              } else {
                codeBuffer.write(
                    "entity.${field.fieldName}${field.isRequired ?? false ? " ?? ''" : ''}");
              }
            }
          }
        }
        codeBuffer.writeln(", ");
      }
    }
    codeBuffer.writeln("${spaces(4)});");
    codeBuffer.writeln("${spaces(2)}}");
    return codeBuffer.toString();
  }

  String _statics() {
    StringBuffer codeBuffer = StringBuffer();
//    modelSpecifications.packageName + ", " + modelSpecifications.id
    codeBuffer.writeln(
        "${spaces(2)}static const String packageName = '${modelSpecifications.packageName}';");
    codeBuffer.writeln(
        "${spaces(2)}static const String id = '${firstLowerCase(modelSpecifications.id)}s';");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();

    codeBuffer.writeln(_enums());
    codeBuffer.writeln(_enumMethods());

    String className = modelSpecifications.modelClassName();
    List<String> implements = [];

    for (var field in modelSpecifications.fields) {
      if (field.fieldName == 'documentID') {
        implements.add('ModelBase');
      }
      if (field.fieldName == 'appId') {
        implements.add('WithAppId');
      }
    }
    codeBuffer.write("class $className");
    if (implements.isNotEmpty) {
      codeBuffer.write(" implements ");
      int i = 0;
      for (var implement in implements) {
        codeBuffer.write(implement);
        if (i <= implements.length - 2) {
          codeBuffer.write(", ");
        }
        i++;
      }
    }
    codeBuffer.writeln(" {");

    codeBuffer.writeln(_statics());
    codeBuffer.writeln(_fieldDefinitions());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_copyWith());
    codeBuffer.writeln(_hashCode());
    codeBuffer.writeln(_equalsOperator());
/*
    codeBuffer.write(toRichMap());
    codeBuffer.write(processRichMap());
*/
    codeBuffer
        .writeln(toStringCode(false, modelSpecifications.modelClassName()));
    codeBuffer.writeln(_collectReferences());
    codeBuffer.writeln(_toEntity());
    codeBuffer.writeln(_fromEntity());
    codeBuffer.writeln(_fromEntityPlus());

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }
}
