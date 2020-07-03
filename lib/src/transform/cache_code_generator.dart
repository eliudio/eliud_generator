import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _imports = """
import 'dart:async';
import '\${filename}_model.dart';
import '\${filename}_repository.dart';
import 'package:eliud_model/shared/abstract_repository_singleton.dart';

""";

const String _header = """
class \${id}Cache implements \${id}Repository {
""";

const String _footer= """
}
""";

const String _code = """
  final \${id}Repository reference;
  final Map<String, \${id}Model> fullCache = Map();

  \${id}Cache(this.reference);

  Future<\${id}Model> add(\${id}Model value) {
    return reference.add(value).then((newValue) {
      fullCache[value.documentID] = newValue;
      return newValue;
    });
  }

  Future<void> delete(\${id}Model value){
    fullCache.remove(value.documentID);
    reference.delete(value);
    return Future.value();
  }

  Future<\${id}Model> get(String id){
    \${id}Model value = fullCache[id];
    if (value != null) return refreshRelations(value);
    return reference.get(id).then((value) {
      fullCache[id] = value;
      return value;
    });
  }

  Future<\${id}Model> update(\${id}Model value) {
    return reference.update(value).then((newValue) {
      fullCache[value.documentID] = newValue;
      return newValue;
    });
  }

  @override
  Stream<List<\${id}Model>> values() {
    return reference.values();
  }

  @override
  Stream<List<\${id}Model>> valuesWithDetails() {
    return reference.valuesWithDetails();
  }

  @override
  Future<List<\${id}Model>> valuesList() async {
    return await reference.valuesList();
  }
  
  @override
  Future<List<\${id}Model>> valuesListWithDetails() async {
    return await reference.valuesListWithDetails();
  }

  void flush() {
    fullCache.clear();
  }
  
""";

const String _deleteAll = """
  Future<void> deleteAll() {
    return reference.deleteAll();
  }
""";

const String _listen = """
  @override
  StreamSubscription<List<\${id}Model>> listen(trigger) {
    return reference.listen(trigger);
  }

  @override
  StreamSubscription<List<\${id}Model>> listenWithDetails(trigger) {
    return reference.listenWithDetails(trigger);
  }

""";

const String _refreshRelationsHeader = """
  static Future<\${id}Model> refreshRelations(\${id}Model model) async {
""";

const String _refreshRelationsModel = """
    \${fieldType}Model \${fieldName}Holder;
    if (model.\${fieldName} != null) {
      try {
        await AbstractRepositorySingleton.singleton.\${lfieldType}Repository().get(model.\${fieldName}.documentID).then((val) {
          \${fieldName}Holder = val;
        }).catchError((error) {});
      } catch (_) {}
    }
""";

const String _refreshRelationsEmbeddedArray = """
    List<\${fieldType}Model> \${fieldName}Holder = List<\${fieldType}Model>.from(await Future.wait(await model.\${fieldName}.map((element) async {
      return await \${fieldType}Cache.refreshRelations(element);
    }))).toList();
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

const String _collectionCode = """
    \${collectionFieldType}Repository \${lCollectionFieldType}Repository(String documentID) => reference.\${lCollectionFieldType}Repository(documentID);
  
""";

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
  CacheCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports, parameters: <String, String> { '\${filename}': camelcaseToUnderscore(modelSpecifications.id) }));

    modelSpecifications.fields.forEach((field) {
      if ((!field.isEnum()) && (!field.isNativeType())) {
        headerBuffer.writeln("import '" + resolveImport(importThis: camelcaseToUnderscore(field.fieldType) + "_model.dart") + "';");
      }
    });
    modelSpecifications.fields.forEach((field) {
      if (!field.isEnum()) {
        if (!field.isNativeType()) {
          if (field.isArray()) {
            headerBuffer.writeln("import '" + resolveImport(importThis: camelcaseToUnderscore(field.fieldType) + "_cache.dart") + "';");
            if (field.arrayType == ArrayType.CollectionArrayType) {
              headerBuffer.writeln("import '" + resolveImport(importThis: camelcaseToUnderscore(field.fieldType) + "_repository.dart") + "';");
            }
          } else {
            // This might be or become a case to handle as well
          }
        }
      }
    });

    return headerBuffer.toString();
  }

  @override
  String body() {
    var parameters = <String, String> { '\${id}': modelSpecifications.id };
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
      if (field.association) {
        codeBuffer.writeln(process(_refreshRelationsModel,
            parameters: <String, String>{
              '\${fieldName}': field.fieldName,
              '\${fieldType}': field.fieldType,
              '\${lfieldType}': firstLowerCase(field.fieldType)
            }));
        assignParametersBuffer.writeln(process(_refreshRelationsAssignField,
            parameters: <String, String>{
              '\${fieldName}': field.fieldName
            }));
      }
    });
    modelSpecifications.fields.forEach((field) {
      if (!field.isEnum()) {
        if (!field.isNativeType()) {
          if (field.isArray()) {
//            if (field.arrayType != ArrayType.CollectionArrayType) {
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
/*
            } else {
              assignParametersBuffer.writeln("what to do here to refresh the relationship for " + field.fieldName);
            }
*/
          } else {
            // This might be or become a case to handle as well
          }
        }
      }
    });

    codeBuffer.writeln(process(_refreshRelationsFooter,
        parameters: <String, String>{
          '\${copyArguments}': assignParametersBuffer.toString()
        }));

    modelSpecifications.fields.forEach((field) {
      if (field.arrayType == ArrayType.CollectionArrayType) {
        codeBuffer.writeln(process(_collectionCode,
            parameters: <String, String>{
              '\${collectionFieldType}': field.fieldType,
              '\${lCollectionFieldType}': firstLowerCase(field.fieldType)
            }));
      }
    });

    codeBuffer.writeln(process(_footer, parameters: parameters));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
