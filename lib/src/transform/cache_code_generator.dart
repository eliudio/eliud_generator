import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _imports(String packageName, List<String>? depends) => """
import 'dart:async';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';
import 'package:$packageName/model/\${filename}_model.dart';
import 'package:$packageName/model/\${filename}_repository.dart';

""" + base_imports(packageName, repo: true, model: true, entity: true, cache:true, depends: depends);

const String _header = """
class \${id}Cache implements \${id}Repository {
""";

const String _footer= """
}
""";

const String _code = """
  final \${id}Repository reference;
  final Map<String?, \${id}Model?> fullCache = Map();

  \${id}Cache(this.reference);

  Future<\${id}Model> add(\${id}Model value) {
    return reference.add(value).then((newValue) {
      fullCache[value.documentID] = newValue;
      return newValue;
    });
  }

  Future<\${id}Entity> addEntity(String documentID, \${id}Entity value) {
    return reference.addEntity(documentID, value);
  }

  Future<\${id}Entity> updateEntity(String documentID, \${id}Entity value) {
    return reference.updateEntity(documentID, value);
  }

  Future<void> delete(\${id}Model value){
    fullCache.remove(value.documentID);
    reference.delete(value);
    return Future.value();
  }

  Future<\${id}Model?> get(String? id, {Function(Exception)? onError}) async {
    var value = fullCache[id];
    if (value != null) return refreshRelations(value);
    value = await reference.get(id, onError: onError);
    fullCache[id] = value;
    return value;
  }

  Future<\${id}Model> update(\${id}Model value) {
    return reference.update(value).then((newValue) {
      fullCache[value.documentID] = newValue;
      return newValue;
    });
  }

  @override
  Stream<List<\${id}Model?>> values({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    return reference.values(orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, setLastDoc: setLastDoc, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }

  @override
  Stream<List<\${id}Model?>> valuesWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    return reference.valuesWithDetails(orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, setLastDoc: setLastDoc, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }

  @override
  Future<List<\${id}Model?>> valuesList({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    return await reference.valuesList(orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, setLastDoc: setLastDoc, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }
  
  @override
  Future<List<\${id}Model?>> valuesListWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    return await reference.valuesListWithDetails(orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, setLastDoc: setLastDoc, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }

  void flush() {
    fullCache.clear();
  }
  
  String? timeStampToString(dynamic timeStamp) {
    return reference.timeStampToString(timeStamp);
  } 

  dynamic getSubCollection(String documentId, String name) {
    return reference.getSubCollection(documentId, name);
  }

  Future<\${id}Model> changeValue(String documentId, String fieldName, num changeByThisValue) {
    return reference.changeValue(documentId, fieldName, changeByThisValue).then((newValue) {
      fullCache[documentId] = newValue;
      return newValue!;
    });
  }

  @override
  Future<\${id}Entity?> getEntity(String? id, {Function(Exception p1)? onError}) {
    return reference.getEntity(id, onError: onError);
  }

  @override
  \${id}Entity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    return reference.fromMap(o, newDocumentIds: newDocumentIds);
  }
""";

const String _deleteAll = """
  Future<void> deleteAll() {
    return reference.deleteAll();
  }
""";

const String _listen = """
  @override
  StreamSubscription<List<\${id}Model?>> listen(trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    return reference.listen(trigger, orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }

  @override
  StreamSubscription<List<\${id}Model?>> listenWithDetails(trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    return reference.listenWithDetails(trigger, orderBy: orderBy, descending: descending, startAfter: startAfter, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: eliudQuery);
  }

  @override
  StreamSubscription<\${id}Model?> listenTo(String documentId, \${id}Changed changed, {\${id}ErrorHandler? errorHandler}) {
    return reference.listenTo(documentId, ((value) {
      if (value != null) {
        fullCache[value.documentID] = value;
      }
      changed(value);
    }), errorHandler: errorHandler);
  }
""";

const String _refreshRelationsHeader = """
  static Future<\${id}Model> refreshRelations(\${id}Model model) async {
""";

const String _refreshRelationsModel = """
    \${fieldType}Model? \${fieldName}Holder;
    if (model.\${fieldName} != null) {
      try {
        await \${lfieldType}Repository(\${appIdVar})!.get(model.\${fieldName}!.documentID).then((val) {
          \${fieldName}Holder = val;
        }).catchError((error) {});
      } catch (_) {}
    }
""";

const String _refreshRelationsEmbeddedArray = """
    List<\${fieldType}Model>? \${fieldName}Holder;
    if (model.\${fieldName} != null) {
      \${fieldName}Holder = List<\${fieldType}Model>.from(await Future.wait(await model.\${fieldName}!.map((element) async {
        return await \${fieldType}Cache.refreshRelations(element);
      }))).toList();
    }
""";

const String _refreshRelationsAssignField = """
        \${fieldName}: \${fieldName}Holder,
""";

const String _refreshRelationsFooter = """
    return model.copyWith(
\${copyArguments}
    );
  }
""";

/*
const String _collectionCode = """
    \${collectionFieldType}Repository app_\${lCollectionFieldType}Repository(String documentID) => reference.app_\${lCollectionFieldType}Repository(documentID);
  
""";
*/

/*
 * This class generates the cache repositories. Why a cache repository, when flutter comes with
 * a cache of its own? The reason is because we want to control this ourselves:
 * plenty of the data is app config data, which means it's fairly static. This does never really
 * NOT need a cache, except when we want the data to be forcefully refreshed. So we always have the
 * cache, i.e. not just when no network is available. However, we have a mechanism to force the
 * apps to refresh the cache: as an admin, update the app and press the "refresh cache" button. Don't
 * forget to submit. At this point, all devices connected will have their cache flushed.
 */
class CacheCodeGenerator extends CodeGenerator {
  CacheCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports(modelSpecifications.packageName, modelSpecifications.depends), parameters: <String, String> { '\${filename}': camelcaseToUnderscore(modelSpecifications.id) }));
    return headerBuffer.toString();
  }

  @override
  String body() {

    var parameters = <String, String> {
      '\${id}': modelSpecifications.id,
    };
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_header, parameters: parameters));
    codeBuffer.writeln(process(_code, parameters: parameters));

    codeBuffer.writeln(process(_deleteAll, parameters: parameters));

    if (modelSpecifications.generate.generateCache) {
      codeBuffer.writeln(process(_listen, parameters: parameters));
    }

    /*
     * Relationships need a refresh: It AppModel has an image, then the image
     * needs to be refreshed. It might be that the image has been updated in the
     * database. When it is updated in the database, the ImageCache will reflect this.
     * However, if the page has been cached, then the related image will be part of that cache.
     * Hence this needs to be "refreshed".
     */
    codeBuffer.writeln(process(_refreshRelationsHeader, parameters: parameters));
    StringBuffer assignParametersBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.isAssociation()) {
          String appVar;
/*
          if ((field.fieldType != "App") &&
              (field.fieldType != "Member") && (field.fieldType != "Country") &&
              (field.fieldType != "MemberPublicInfo")) {
            appVar = "appId: model." + field.fieldName + "!.appId";
          } else {
            appVar = '';
          }
*/
          if (modelSpecifications.getIsAppModel()) {
            appVar = "appId: model.appId";
          } else {
            appVar = '';
          }

          codeBuffer.writeln(process(_refreshRelationsModel,
              parameters: <String, String>{
                '\${fieldName}': field.fieldName,
                '\${fieldType}': field.fieldType,
                '\${lfieldType}': firstLowerCase(field.fieldType),
                '\${appIdVar}': appVar
              }));
          assignParametersBuffer.writeln(process(_refreshRelationsAssignField,
              parameters: <String, String>{
                '\${fieldName}': field.fieldName
              }));
        }
      }
    });
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (!field.isEnum()) {
          if (!field.isNativeType()) {
            if (field.isArray()) {
              codeBuffer.writeln(process(_refreshRelationsEmbeddedArray,
                  parameters: <String, String>{
                    '\${fieldName}': field.fieldName,
                    '\${fieldType}': field.fieldType,
                    '\${lfieldType}': firstLowerCase(field.fieldType)
                  }));
              assignParametersBuffer.writeln(
                  process(_refreshRelationsAssignField,
                      parameters: <String, String>{
                        '\${fieldName}': field.fieldName
                      }));
            }
          }
        }
      }
    });

    codeBuffer.writeln(process(_refreshRelationsFooter,
        parameters: <String, String>{
          '\${copyArguments}': assignParametersBuffer.toString()
        }));

/*
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType == ArrayType.CollectionArrayType) {
        codeBuffer.writeln(process(_collectionCode,
            parameters: <String, String>{
              '\${collectionFieldType}': field.fieldType,
              '\${lCollectionFieldType}': firstLowerCase(field.fieldType)
            }));
      }
    });
*/

    codeBuffer.writeln(process(_footer, parameters: parameters));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
