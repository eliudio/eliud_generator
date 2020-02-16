import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

const String _code = """
\${typeDef}

abstract class \${id}Repository {
  Future<void> add(\${id}Model value);
  Future<void> delete(\${id}Model value);
  Future<\${id}Model> get(String id);
  Future<void> update(\${id}Model value);
  Stream<List<\${id}Model>> values();
  \${listen}
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
    headerBuffer.writeln("import '" +
        resolveImport(importThis: modelSpecifications.modelFileName()) +
        "';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();

    String typeDef = "";
    if (modelSpecifications.generate.generateCache)
      typeDef = "typedef " + modelClassName + "Trigger();";

    String listen = "";
    if (modelSpecifications.generate.generateCache)
      listen = "void listen(" + modelClassName + "Trigger trigger);";

    codeBuffer.writeln(process(_code, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
      '\${listen}': listen,
      '\${typeDef}': typeDef
    }));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
