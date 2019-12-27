import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

class RepositoryCodeGenerator extends CodeGenerator {
  RepositoryCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String className = modelSpecifications.repositoryClassName();
    String modelClassName = modelSpecifications.modelClassName();
    codeBuffer.writeln("abstract class $className {");

    codeBuffer.writeln(spaces(2) + "Future<void> add(" + modelClassName + " value);");
    codeBuffer.writeln(spaces(2) + "Future<void> delete(" + modelClassName + " value);");
    codeBuffer.writeln(spaces(2) + "Future<" + modelClassName + "> get(String id);");
    codeBuffer.writeln(spaces(2) + "Future<void> update(" + modelClassName + " value);");
    codeBuffer.writeln(spaces(2) + "Stream<List<" + modelClassName + ">> values();");

    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
