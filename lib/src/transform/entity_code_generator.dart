import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

const String _jsonMethods = """
  static \${id}Entity? fromJsonString(String json, {Map<String, String>? newDocumentIds}) {
    Map<String, dynamic>? generationSpecificationMap = jsonDecode(json);
    return fromMap(generationSpecificationMap, newDocumentIds: newDocumentIds);
  }

  String toJsonString() {
    return jsonEncode(toDocument());
  }
""";

const String _convertToMap = """
    final \${fieldType} \${fieldId} = Map();
    if (map['\${fieldId}'] != null) {
      map['\${fieldId}'].forEach((k, v) {
        \${fieldId}[k] = v;
      });
    }
""";

class EntityCodeGenerator extends DataCodeGenerator {
  EntityCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  String fieldName(Field field) {
    if (field.isAssociation()) return field.fieldName + "Id";
    return field.fieldName;
  }

  String theFileName() {
    return modelSpecifications.entityFileName();
  }

  String dartEntityType(Field field) {
    if (field.isAssociation()) return "String";
    return field.dartEntityType();
  }

  String _copyWith() {
    var hasServerTimeStamp = false;
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(
        spaces(2) + modelSpecifications.entityClassName() + " copyWith({");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(dartEntityType(field) + "? " + fieldName(field) + ", ");
      hasServerTimeStamp = true;
    });
    codeBuffer.writeln("}) {");
    codeBuffer.write(spaces(4) + "return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName != "documentID") {
        codeBuffer.write(fieldName(field) + " : " + fieldName(field) + " ?? this." + fieldName(field) + ", ");
      }
    });
    codeBuffer.writeln(");");
    codeBuffer.write(spaces(2) + "}");
    return codeBuffer.toString();
/*
    if (hasServerTimeStamp) {
    } else {
      return "";
    }
*/
  }

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:collection';");
    headerBuffer.writeln("import 'dart:convert';");
    headerBuffer.writeln("import 'package:eliud_core/tools/random.dart';");

    headerBuffer.writeln("import 'abstract_repository_singleton.dart';");
    headerBuffer.writeln("import 'package:cloud_firestore/cloud_firestore.dart';");
    headerBuffer.writeln("import 'package:eliud_core/core/base/entity_base.dart';");

    headerBuffer.writeln(base_imports(modelSpecifications.packageName, entity:true, depends: modelSpecifications.depends));
    headerBuffer.writeln("import 'package:eliud_core/tools/common_tools.dart';");

    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_ENTITY);

    return headerBuffer.toString();
  }

  String _fieldDefinitions() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldName != "documentID")
          codeBuffer.writeln(
              "  final " + dartEntityType(field) + "? " + fieldName(field) +
                  ";");
      }
    });
    return codeBuffer.toString();
  }

  String _getProps() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + "List<Object?> get props => [");
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldName != "documentID")
          codeBuffer.write(fieldName(field) + ", ");
      }
    });
    codeBuffer.writeln("];");
    return codeBuffer.toString();
  }

  String _fromMap() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) +
        "static " +
        modelSpecifications.entityClassName() +
        "? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {");
    bool extraLine = false;
    codeBuffer.writeln(spaces(4) + "if (o == null) return null;");
    codeBuffer.writeln(spaces(4) + "var map = o as Map<String, dynamic>;");
    codeBuffer.writeln();
    modelSpecifications.fields.forEach((field) {
      if (field.isMedium() && !field.isArray()) {
        codeBuffer
            .writeln(spaces(4) + "var " + fieldName(field) + "NewDocmentId = map['" + fieldName(field) + "'];");

        codeBuffer
            .writeln(spaces(4) + "if ((newDocumentIds != null) && (" + fieldName(field) + "NewDocmentId != null)) {");
        codeBuffer
            .writeln(spaces(6) + "var " + fieldName(field) + "OldDocmentId = " + fieldName(field) + "NewDocmentId;");
        codeBuffer
            .writeln(spaces(6) + "" + fieldName(field) + "NewDocmentId = newRandomKey();");
        codeBuffer
            .writeln(spaces(6) + "newDocumentIds[" + fieldName(field) + "OldDocmentId] = " + fieldName(field) + "NewDocmentId;");
        codeBuffer
            .writeln(spaces(4) + "}");
      } else if (field.isBespoke()) {
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
            field.getBespokeEntityMapping() + ";");

      } else {
        if (field.arrayType != ArrayType.CollectionArrayType) {
          if ((!field.isEnum()) &&
              (!field.isServerTimestamp()) &&
              (!field.isAssociation()) &&
              (!field.isNativeType())) {
            extraLine = true;
            if (field.isArray()) {
              if (field.arrayType != ArrayType.CollectionArrayType) {
                codeBuffer
                    .writeln(spaces(4) + "var " + fieldName(field) + "FromMap;");
                codeBuffer.writeln(spaces(4) +
                    fieldName(field) +
                    "FromMap = map['" +
                    fieldName(field) +
                    "'];");
                codeBuffer.writeln(spaces(4) + "var " + fieldName(field) + "List;");
                codeBuffer.writeln(
                    spaces(4) + "if (" + fieldName(field) + "FromMap != null)");
                codeBuffer.writeln(spaces(6) +
                    fieldName(field) +
                    "List = (map['" +
                    fieldName(field) +
                    "'] as List<dynamic>)");
                codeBuffer.writeln(spaces(8) + ".map((dynamic item) =>");
                codeBuffer.writeln(
                    spaces(8) + field.fieldType +
                        "Entity.fromMap(item as Map, newDocumentIds: newDocumentIds)!)");
                codeBuffer.writeln(spaces(8) + ".toList();");
              } else {
                // the collection is maintained by it's own collection / repository
              }
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
                  "FromMap, newDocumentIds: newDocumentIds);");
            }
          } else if (field.isMap()) {
            codeBuffer.writeln(
                process(_convertToMap, parameters: <String, String>{
                  '\${fieldId}': fieldName(field),
                  '\${fieldType}': field.dartEntityType(),
                }));
          }
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.writeln(
        spaces(4) + "return " + modelSpecifications.entityClassName() + "(");
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldName != "documentID") {
          codeBuffer.write(spaces(6) + fieldName(field) + ": ");
          if (field.isServerTimestamp()) {
            if (field.isServerTimestampInitialized()) {
              var repoArgs;
              var documentSubCollectionOf = modelSpecifications.generate
                  .documentSubCollectionOf;
              if (documentSubCollectionOf != null) {
                if (modelSpecifications.generate.isAppSubCollection()) {
                  repoArgs = "appId: map['appId']";
                } else {
                  var lowerCase = documentSubCollectionOf.toLowerCase();
                  repoArgs = "appId: map['appId'], " + lowerCase + "Id: map['" +
                      lowerCase + "Id']";
                }
              } else {
                repoArgs = '';
              }
              codeBuffer.writeln("map['" + fieldName(field) + "'] == null ? null : (map['" + fieldName(field) + "']  as Timestamp).millisecondsSinceEpoch,");
            } else {
              codeBuffer.writeln("map['" +
                  fieldName(field) + "'],");
            }
          } else if ((field.isAssociation()) || (field.isEnum())) {
            if (field.isMap()) {
              codeBuffer.writeln(fieldName(field) + ", ");
            } else {
              if (field.isMedium()) {
                codeBuffer.writeln(fieldName(field) + "NewDocmentId, ");
              } else {
                codeBuffer.writeln("map['" + fieldName(field) + "'], ");
              }
            }
          } else {
            if (!field.isNativeType()) {
              if (field.isArray()) {
                codeBuffer.writeln(fieldName(field) + "List, ");
              } else {
                codeBuffer.writeln(fieldName(field) + "FromMap, ");
              }
            } else {
              if (field.isArray()) {
                codeBuffer
                    .writeln(
                    "map['" + fieldName(field) + "'] == null ? null : " +
                        "List.from(map['" + fieldName(field) + "']), ");
              } else {
                if (field.isDouble())
                  codeBuffer.writeln(
                      "double.tryParse(map['" + fieldName(field) +
                          "'].toString()), ");
                else if (field.isInt())
                  codeBuffer.writeln("int.tryParse(map['" + fieldName(field) +
                      "'].toString()), ");
                else
                  codeBuffer.writeln("map['" + fieldName(field) + "'], ");
              }
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
    codeBuffer.writeln(spaces(2) + "Map<String, Object?> toDocument() {");
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (!field.isBespoke()) {
        if (field.arrayType != ArrayType.CollectionArrayType) {
          if ((!field.isEnum()) &&
              (!field.isServerTimestamp()) &&
              (!field.isAssociation()) &&
              (!field.isNativeType())) {
            extraLine = true;
            if (field.isArray()) {
              if (field.arrayType != ArrayType.CollectionArrayType) {
                codeBuffer.writeln(spaces(4) +
                    "final List<Map<String?, dynamic>>? " +
                    fieldName(field) +
                    "ListMap" +
                    " = " +
                    fieldName(field) +
                    " != null ");
                codeBuffer.writeln(spaces(8) +
                    "? " +
                    fieldName(field) +
                    "!.map((item) => item.toDocument()).toList()");
                codeBuffer.writeln(spaces(8) + ": null;");
              } else {
                // the collection is maintained by it's own collection / repository
              }
            } else {
              codeBuffer.writeln(spaces(4) +
                  "final Map<String, dynamic>? " +
                  fieldName(field) +
                  "Map"
                      " = " +
                  fieldName(field) +
                  " != null ");
              codeBuffer
                  .writeln(
                  spaces(8) + "? " + fieldName(field) + "!.toDocument()");
              codeBuffer.writeln(spaces(8) + ": null;");
            }
          }
        }
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer
        .writeln(spaces(4) + "Map<String, Object?> theDocument = HashMap();");
    modelSpecifications.fields.forEach((field) {
      if (field.isServerTimestamp()) {
        codeBuffer.writeln(spaces(4) +'theDocument["'+
            fieldName(field) +
            '"] = ' + fieldName(field) + ';');
      } else if (field.isBespoke()) {
        codeBuffer.writeln(field.bespokeEntityToDocument);
      } else {
        if (field.arrayType != ArrayType.CollectionArrayType) {
          if (field.fieldName != "documentID") {
            codeBuffer.write(spaces(4) +
                "if (" +
                fieldName(field) +
                " != null) " +
                "theDocument[\"" +
                fieldName(field) +
                "\"] = ");
            if ((field.isAssociation()) || (field.isEnum())) {
              codeBuffer.writeln(fieldName(field) + ";");
            } else {
              if (!field.isNativeType()) {
                if (field.isArray()) {
                  if (field.arrayType != ArrayType.CollectionArrayType) {
                    codeBuffer.writeln(fieldName(field) + "ListMap;");
                  }
                } else {
                  codeBuffer.writeln(fieldName(field) + "Map;");
                }
              } else {
                if (field.isArray()) {
                  if (field.arrayType != ArrayType.CollectionArrayType) {
                    codeBuffer.writeln(fieldName(field) + "!.toList();");
                  }
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
        }
      }
    });
    codeBuffer.writeln(spaces(4) + "return theDocument;");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _switchAppId() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        spaces(2) + "@override");
    codeBuffer.writeln(
        spaces(2) + modelSpecifications.entityClassName() + " switchAppId({required String newAppId}) {");
    if (modelSpecifications.fields.where((element) => element.fieldName == "appId").isNotEmpty) {
      codeBuffer.writeln(spaces(4) + "var newEntity = copyWith(appId: newAppId);");
    } else {
      codeBuffer.writeln(spaces(4) + "var newEntity = copyWith();");
    }
    if (modelSpecifications.codeForNewAppId != null) {
      codeBuffer.writeln(spaces(4) + modelSpecifications.codeForNewAppId!);
    }
    codeBuffer.writeln(spaces(4) + "return newEntity;");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _enrichedDocument() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(
        spaces(2) + "Future<Map<String, Object?>> enrichedDocument(Map<String, Object?> theDocument) async {");
    if (modelSpecifications.codeToExtractData != null) {
      codeBuffer.writeln(modelSpecifications.codeToExtractData);
    }
    codeBuffer.writeln(spaces(4) + "return theDocument;");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();

    String className = modelSpecifications.entityClassName();
    codeBuffer.writeln("class $className implements EntityBase {");

    codeBuffer.writeln(_fieldDefinitions());
    codeBuffer.write(getConstructor(
        removeDocumentID: true,
        name: modelSpecifications.entityClassName(),
        terminate: true,
        ));
    codeBuffer.writeln(_copyWith());
    codeBuffer.writeln(_getProps());
    codeBuffer
        .writeln(toStringCode(true, modelSpecifications.entityClassName()));
    codeBuffer.writeln(_fromMap());
    codeBuffer.writeln(_toDocument());
    codeBuffer.writeln(_switchAppId());

    codeBuffer.writeln(process(_jsonMethods, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
    }));

    codeBuffer.writeln(_enrichedDocument());
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }
}
