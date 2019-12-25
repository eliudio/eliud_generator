import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class EntityCodeGenerator extends CodeGenerator {
  EntityCodeGenerator({ModelSpecification modelSpecifications}) : super(modelSpecifications: modelSpecifications);

  String theFileName() {
    return modelSpecifications.entityFileName();
  }

  String getCommonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:cloud_firestore/cloud_firestore.dart';");
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");

    headerBuffer.writeln();
    modelSpecifications.fields.forEach((field) {
      if (!field.isNativeType()) {
        headerBuffer.writeln("import '" + camelcaseToUnderscore(field.fieldType) + ".entity.dart" + "';");
      }
    });
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String getBody() {
    StringBuffer codeBuffer = StringBuffer();

    codeBuffer.writeln("@immutable");
    String className = modelSpecifications.entityClassName();
    codeBuffer.writeln("class $className {");


    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(getHeader());
    codeBuffer.write(getCommonImports());
    codeBuffer.write(getBody());
    return codeBuffer.toString();
  }
}
