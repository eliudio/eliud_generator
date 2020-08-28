import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ComponentBlocCodeGenerator extends CodeGenerator {
  ComponentBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");
    headerBuffer.writeln("import '" + modelSpecifications.componentEventFileName() + "';");
    headerBuffer.writeln("import '" + modelSpecifications.componentStateFileName() + "';");
    headerBuffer.writeln("import '" + modelSpecifications.repositoryFileName() + "';");

    if (uniqueAssociationTypes.isNotEmpty) headerBuffer.writeln();

    return headerBuffer.toString();
  }

  String _dataMembers() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.id + "Repository " + firstLowerCase(modelSpecifications.id) + "Repository;");
    return codeBuffer.toString();
  }

  String _constructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + modelSpecifications.id + "Bloc({ this." + firstLowerCase(modelSpecifications.id) + "Repository }): super("  + modelSpecifications.id + "Uninitialized());");
    return codeBuffer.toString();
  }

  String _mapEventToState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "State> mapEventToState(" + modelSpecifications.id + "Event event) async* {");
    codeBuffer.writeln(spaces(4) + "final currentState = state;");
    codeBuffer.writeln(spaces(4) + "if (event is Fetch" + modelSpecifications.id + ") {");
    codeBuffer.writeln(spaces(6) + "try {");
    codeBuffer.writeln(spaces(8) + "if (currentState is " + modelSpecifications.id + "Uninitialized) {");
    codeBuffer.writeln(spaces(10) + "final " + modelSpecifications.id + "Model model = await _fetch" + modelSpecifications.id + "(event.id);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(10) + "if (model != null) {");
    codeBuffer.writeln(spaces(12) + "yield " + modelSpecifications.id + "Loaded(value: model);");
    codeBuffer.writeln(spaces(10) + "} else {");
    codeBuffer.writeln(spaces(12) + "String id = event.id;");
    codeBuffer.writeln(spaces(12) + "yield " + modelSpecifications.id + "Error(message: \"" + modelSpecifications.id + " with id = '\$id' not found\");");
    codeBuffer.writeln(spaces(10) + "}");
    codeBuffer.writeln(spaces(10) + "return;");
    codeBuffer.writeln(spaces(8) + "}");
    codeBuffer.writeln(spaces(6) + "} catch (_) {");
    codeBuffer.writeln(spaces(8) + "yield " + modelSpecifications.id + "Error(message: \"Unknown error whilst retrieving " + modelSpecifications.id + "\");");
    codeBuffer.writeln(spaces(6) + "}");
    codeBuffer.writeln(spaces(4) + "}");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _fetch() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> _fetch" + modelSpecifications.id + "(String id) async {");
    codeBuffer.writeln(spaces(4) + "return " + firstLowerCase(modelSpecifications.id) + "Repository.get(id);");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _close() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Future<void> close() {");
    codeBuffer.writeln(spaces(4) + "return super.close();");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "Bloc extends Bloc<" + modelSpecifications.id + "Event, " + modelSpecifications.id + "State> {");

    codeBuffer.writeln(_dataMembers());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_mapEventToState());
    codeBuffer.writeln(_fetch());
    codeBuffer.writeln(_close());

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentBlocFileName();
  }
}
