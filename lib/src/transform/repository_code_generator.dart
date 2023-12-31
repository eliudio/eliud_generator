import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'firestore_helper.dart';

const String _code = """
import 'dart:async';
import 'package:eliud_core_helpers/query/query_tools.dart';
import 'package:eliud_core_helpers/helpers/common_tools.dart';
import 'package:eliud_core_helpers/repository/repository_base.dart';

typedef \${id}ModelTrigger(List<\${id}Model?> list);
typedef \${id}Changed(\${id}Model? value);
typedef \${id}ErrorHandler = Function(dynamic o, dynamic e);

abstract class \${id}Repository extends RepositoryBase<\${id}Model, \${id}Entity> {
  Future<\${id}Entity> addEntity(String documentID, \${id}Entity value);
  Future<\${id}Entity> updateEntity(String documentID, \${id}Entity value);
  Future<\${id}Model> add(\${id}Model value);
  Future<void> delete(\${id}Model value);
  Future<\${id}Model?> get(String? id, { Function(Exception)? onError });
  Future<\${id}Model> update(\${id}Model value);

  Stream<List<\${id}Model?>> values({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery });
  Stream<List<\${id}Model?>> valuesWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery });
  Future<List<\${id}Model?>> valuesList({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery });
  Future<List<\${id}Model?>> valuesListWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery });

  StreamSubscription<List<\${id}Model?>> listen(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery });
  StreamSubscription<List<\${id}Model?>> listenWithDetails(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery });
  StreamSubscription<\${id}Model?> listenTo(String documentId, \${id}Changed changed, {\${id}ErrorHandler? errorHandler});
  void flush();
  
  String? timeStampToString(dynamic timeStamp);

  dynamic getSubCollection(String documentId, String name);
  Future<\${id}Model?> changeValue(String documentId, String fieldName, num changeByThisValue);
""";

/*
const String _collectionCode = """
    \${collectionFieldType}Repository app_\${lCollectionFieldType}Repository(String documentID);
  
""";
*/

const String _codeWithArgNoAppID = """
  Future<void> deleteAll();
}

""";

class RepositoryCodeGenerator extends CodeGenerator {
  RepositoryCodeGenerator({required super.modelSpecifications});

/*
  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_REPOSITORY);
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

*/
  @override
  String commonImports() {
    return FirestoreHelper.commonImports(
        extraImports2(ModelSpecification.IMPORT_KEY_REPOSITORY),
        modelSpecifications,
        "repository");
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
    };
    codeBuffer.writeln(process(_code, parameters: parameters));

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

    codeBuffer.writeln(process(_codeWithArgNoAppID, parameters: parameters));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
