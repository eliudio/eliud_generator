import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class FormCodeGenerator extends CodeGenerator {
  FormCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formBlocFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.repositoryFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formStateFileName()) + "';");
    headerBuffer.writeln("import '../tools/enums.dart';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String idTag = firstLowerCase(modelSpecifications.id) + "Id";
    String className = modelSpecifications.formClassName();
    codeBuffer.writeln("class " + className + " extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "FormAction formAction;");
    codeBuffer.writeln(spaces(2) + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) + className + "({Key key, @required this.formAction, @required this.value}) : super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return Scaffold(");
    codeBuffer.writeln(spaces(6) + "appBar: formAction == FormAction.UpdateAction ? AppBar(title: Text(\"Update\")) : AppBar(title: Text(\"Add\")),");
    codeBuffer.writeln(spaces(6) + "body: null,");
    codeBuffer.writeln(spaces(6) + "//child: null");
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formFileName();
  }
}
