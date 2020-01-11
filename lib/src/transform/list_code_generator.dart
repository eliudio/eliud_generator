import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ListCodeGenerator extends CodeGenerator {
  ListCodeGenerator ({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listBlocFileName()) + "';");
    headerBuffer.writeln("import '../tools/delete_snackbar.dart';");
    headerBuffer.writeln("import 'package:flutter/material.dart';");
    headerBuffer.writeln("import 'package:flutter/foundation.dart';");
    headerBuffer.writeln("import 'package:flutter/widgets.dart';");
    headerBuffer.writeln("import 'package:flutter_bloc/flutter_bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listStateFileName()) + "';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    return "";
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "ListWidget extends StatelessWidget {");
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ListWidget({ Key key }): super(key: key);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Widget build(BuildContext context) {");
    codeBuffer.writeln(spaces(4) + "return BlocBuilder<" + modelSpecifications.id + "ListBloc, " + modelSpecifications.id + "ListState>(builder: (context, state) {");
    codeBuffer.writeln(spaces(6) + "if (state is " + modelSpecifications.id + "ListLoading) {");
    codeBuffer.writeln(spaces(8) + "return Center(");
    codeBuffer.writeln(spaces(10) + "child: CircularProgressIndicator(),");
    codeBuffer.writeln(spaces(8) + ");");
    codeBuffer.writeln(spaces(6) + "} else if (state is " + modelSpecifications.id + "ListLoaded) {");
    codeBuffer.writeln(spaces(8) + "final values = state.values;");
    codeBuffer.writeln(spaces(8) + "return new Scaffold(");
    codeBuffer.writeln(spaces(10) + "floatingActionButton: FloatingActionButton(");
    codeBuffer.writeln(spaces(12) + "foregroundColor: Colors.white,");
    codeBuffer.writeln(spaces(12) + "backgroundColor: Colors.black,");
    codeBuffer.writeln(spaces(12) + "child: Icon(Icons.Add),");
    codeBuffer.writeln(spaces(14) + "onPressed: () {");
    codeBuffer.writeln(spaces(14) + "Navigator.of(context).push(");
    codeBuffer.writeln(spaces(16) + "MaterialPageRout(builder: (_) {");
    codeBuffer.writeln(spaces(18) + "return BlocProvider.value(");
    codeBuffer.writeln(spaces(22) + "value: BlocProver.of<" + modelSpecifications.id + "ListBloc" + ">(context),");
    codeBuffer.writeln(spaces(22) + "child: ");
    codeBuffer.writeln(spaces(8) + ");");
    codeBuffer.writeln(spaces(6) + "}");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listFileName();
  }
}
