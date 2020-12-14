import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _code = """
\${typeDef}

abstract class \${id}Repository {
  Future<\${id}Model> add(\${id}Model value);
  Future<void> delete(\${id}Model value);
  Future<\${id}Model> get(String id);
  Future<\${id}Model> update(\${id}Model value);
  \${values}
  \${listen}
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
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();

    String typeDef = "typedef " + modelClassName + "Trigger(List<" + modelClassName + "> list);";

    String values;
    String listen;

    if (modelSpecifications.isMemberSpecific()) {
      values = "Stream<List<$modelClassName>> values(String currentMember, {String orderBy, bool descending });\n"
          + "  Stream<List<$modelClassName>> valuesWithDetails(String currentMember, {String orderBy, bool descending });\n"
          + "  Future<List<$modelClassName>> valuesList(String currentMember, {String orderBy, bool descending });\n"
          + "  Future<List<$modelClassName>> valuesListWithDetails(String currentMember, {String orderBy, bool descending });";
      listen = "StreamSubscription<List<$modelClassName" +
          ">> listen(String currentMember, $modelClassName" +
          "Trigger trigger, { String orderBy, bool descending });\n"
          + "  StreamSubscription<List<$modelClassName" +
          ">> listenWithDetails(String currentMember, $modelClassName" + "Trigger trigger, { String orderBy, bool descending });";
    } else {
      values = "Stream<List<$modelClassName>> values({String orderBy, bool descending });\n"
          + "  Stream<List<$modelClassName>> valuesWithDetails({String orderBy, bool descending });"
          + "  Future<List<$modelClassName>> valuesList({String orderBy, bool descending });\n"
          + "  Future<List<$modelClassName>> valuesListWithDetails({String orderBy, bool descending });";
      listen = "StreamSubscription<List<$modelClassName" +
          ">> listen($modelClassName" +
          "Trigger trigger, { String orderBy, bool descending });\n"
          + "  StreamSubscription<List<$modelClassName" +
          ">> listenWithDetails($modelClassName" + "Trigger trigger, { String orderBy, bool descending });";
    }

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${values}': values,
      '\${listen}': listen,
      '\${typeDef}': typeDef
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
