import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _code = """
import 'dart:async';
import 'package:eliud_core/tools/firestore_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';

typedef \${id}ModelTrigger(List<\${id}Model> list);

abstract class \${id}Repository {
  Future<\${id}Model> add(\${id}Model value);
  Future<void> delete(\${id}Model value);
  Future<\${id}Model> get(String id);
  Future<\${id}Model> update(\${id}Model value);

  Stream<List<\${id}Model>> values({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, bool isLoggedIn, int privilegeLevel});
  Stream<List<\${id}Model>> valuesWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, bool isLoggedIn, int privilegeLevel});
  Future<List<\${id}Model>> valuesList({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, bool isLoggedIn, int privilegeLevel});
  Future<List<\${id}Model>> valuesListWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, bool isLoggedIn, int privilegeLevel});

  StreamSubscription<List<\${id}Model>> listen(\${id}ModelTrigger trigger, {String currentMember, String orderBy, bool descending, bool isLoggedIn, int privilegeLevel});
  StreamSubscription<List<\${id}Model>> listenWithDetails(\${id}ModelTrigger trigger, {String currentMember, String orderBy, bool descending, bool isLoggedIn, int privilegeLevel});
  void flush();
""";

const String _collectionCode = """
    \${collectionFieldType}Repository \${lCollectionFieldType}Repository(String documentID);
  
""";

const String _codeWithArgNoAppID = """
  Future<void> deleteAll();
}

""";

class RepositoryCodeGenerator extends CodeGenerator {
  RepositoryCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_REPOSITORY);
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
    };
    codeBuffer.writeln(process(_code, parameters: parameters));

    modelSpecifications.fields.forEach((field) {
      if (field.arrayType == ArrayType.CollectionArrayType) {
        codeBuffer.writeln(process(_collectionCode,
            parameters: <String, String>{
              '\${collectionFieldType}': field.fieldType,
              '\${lCollectionFieldType}': firstLowerCase(field.fieldType)
            }));
      }
    });

    codeBuffer.writeln(process(_codeWithArgNoAppID, parameters: parameters));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
