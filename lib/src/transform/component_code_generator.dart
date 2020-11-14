import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ComponentCodeGenerator extends CodeGenerator {
  ComponentCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln("import 'package:eliud_core/core/app/app_bloc.dart';");

    headerBuffer.writeln();
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentBlocFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentEventFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentStateFileName()));

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String idTag = firstLowerCase(modelSpecifications.id) + "ID";
    String className = modelSpecifications.componentClassName();
    codeBuffer.writeln("abstract class " + className + " extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + "static String componentName = \"" + firstLowerCase(modelSpecifications.id) + "s\";");
    codeBuffer.writeln(spaces(2) + "final String " + idTag + ";");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + className + "({this." + idTag + "});");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return BlocProvider<" + modelSpecifications.id + "ComponentBloc> (");
    codeBuffer.writeln(spaces(10) + "create: (context) => " + modelSpecifications.id + "ComponentBloc(");
    codeBuffer.writeln(spaces(12) + firstLowerCase(modelSpecifications.id) + "Repository: get" + modelSpecifications.id + "Repository(context))");
    codeBuffer.writeln(spaces(8) + "..add(Fetch" + modelSpecifications.id + "Component(id: " + firstLowerCase(modelSpecifications.id) + "ID)),");
    codeBuffer.writeln(spaces(6) + "child: _" + firstLowerCase(modelSpecifications.id) + "BlockBuilder(context),");
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Widget _" + firstLowerCase(modelSpecifications.id) + "BlockBuilder(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return BlocBuilder<" + modelSpecifications.id + "ComponentBloc, " + modelSpecifications.id + "ComponentState>(builder: (context, state) {");
    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "ComponentLoaded) {");
    codeBuffer.writeln(spaces(8) + "if (state.value == null) {");
    codeBuffer.writeln(spaces(10) + "return alertWidget(title: 'Error', content: 'No " + firstLowerCase(modelSpecifications.id) + " defined');");
    codeBuffer.writeln(spaces(8) + "} else {");
    codeBuffer.writeln(spaces(10) + "return yourWidget(context, state.value);");
    codeBuffer.writeln(spaces(8) + "}");
    codeBuffer.writeln(spaces(6) + "} else if (state is " + modelSpecifications.id + "ComponentError) {");
    codeBuffer.writeln(spaces(8) + "return alertWidget(title: 'Error', content: state.message);");
    codeBuffer.writeln(spaces(6) + "} else {");
    codeBuffer.writeln(spaces(8) + "return Center(");
    codeBuffer.writeln(spaces(10) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(8) + ");");
    codeBuffer.writeln(spaces(6) + "}");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Widget yourWidget(BuildContext context, " + modelSpecifications.id + "Model value);");
    codeBuffer.writeln(spaces(2) + "Widget alertWidget({ title: String, content: String});");
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "Repository get" + modelSpecifications.id + "Repository(BuildContext context);");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentFileName();
  }
}
