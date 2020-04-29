import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class ListBlocCodeGenerator extends CodeGenerator {
  ListBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln("import 'package:meta/meta.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.repositoryFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.listStateFileName()) + "';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _dataMembers() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.id + "Repository _" + firstLowerCase(modelSpecifications.id) + "Repository;");
    codeBuffer.writeln(spaces(2) + "// I've made this a static so that we have access to this variable the next time we open this bloc and want to unsubscribe.");
    codeBuffer.writeln(spaces(2) + "// The close is never called, given there's no widget dispose implemented. I don't know how to cause the dispose / deactivate / ...");
    codeBuffer.writeln(spaces(2) + "// of the widget to be called. So, because that's not called, the bloc close() is never called, and the cancel on the subscription is never");
    codeBuffer.writeln(spaces(2) + "// called. The best way out of this pickle is to fix it so that the close / cancel is called. However, until then, I made it static");
    codeBuffer.writeln(spaces(2) + "// and the cancel is called at the point where the second subscription is called, preventing that to fail.");
    codeBuffer.writeln(spaces(2) + "static StreamSubscription _" + firstLowerCase(modelSpecifications.id) + "sListSubscription;");
    return codeBuffer.toString();
  }

  String _constructor() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ListBloc({ @required " + modelSpecifications.id + "Repository " + firstLowerCase(modelSpecifications.id) + "Repository })");
    codeBuffer.writeln(spaces(6) + ": assert(" + firstLowerCase(modelSpecifications.id) + "Repository != null),");
    codeBuffer.writeln(spaces(6) + "_" + firstLowerCase(modelSpecifications.id) + "Repository = " + firstLowerCase(modelSpecifications.id) + "Repository;");
    return codeBuffer.toString();
  }

  String _initialState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "get initialState => " + modelSpecifications.id + "ListLoading();");
    return codeBuffer.toString();
  }

  String _mapEventToState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> mapEventToState(" + modelSpecifications.id + "ListEvent event) async* {");
    codeBuffer.writeln(spaces(4) + "final currentState = state;");
    codeBuffer.writeln(spaces(4) + "if (event is Load" + modelSpecifications.id + "List) {");
    codeBuffer.writeln(spaces(6) + "yield* _mapLoad" + modelSpecifications.id + "ListToState();");
    codeBuffer.writeln(spaces(4) + "} else if (event is Add" + modelSpecifications.id + "List) {");
    codeBuffer.writeln(spaces(6) + "yield* _mapAdd" + modelSpecifications.id + "ListToState(event);");
    codeBuffer.writeln(spaces(4) + "} else if (event is Update" + modelSpecifications.id + "List) {");
    codeBuffer.writeln(spaces(6) + "yield* _mapUpdate" + modelSpecifications.id + "ListToState(event);");
    codeBuffer.writeln(spaces(4) + "} else if (event is Delete" + modelSpecifications.id + "List) {");
    codeBuffer.writeln(spaces(6) + "yield* _mapDelete" + modelSpecifications.id + "ListToState(event);");
    codeBuffer.writeln(spaces(4) + "} else if (event is " + modelSpecifications.id + "ListUpdated) {");
    codeBuffer.writeln(spaces(6) + "yield* _map" + modelSpecifications.id + "ListUpdatedToState(event);");
    codeBuffer.writeln(spaces(4) + "}");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _mappers() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> _mapLoad" + modelSpecifications.id + "ListToState() async* {");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "sListSubscription?.cancel();");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "sListSubscription = _" + firstLowerCase(modelSpecifications.id) + "Repository.values().listen(");
    codeBuffer.writeln(spaces(6) + "(value) => add(" + modelSpecifications.id + "ListUpdated(value: value)),");
    codeBuffer.writeln(spaces(4) + ");");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> _mapAdd" + modelSpecifications.id + "ListToState(Add" + modelSpecifications.id + "List event) async* {");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "Repository.add(event.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> _mapUpdate" + modelSpecifications.id + "ListToState(Update" + modelSpecifications.id + "List event) async* {");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "Repository.update(event.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> _mapDelete" + modelSpecifications.id + "ListToState(Delete" + modelSpecifications.id + "List event) async* {");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "Repository.delete(event.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.id + "ListState> _map" + modelSpecifications.id + "ListUpdatedToState(" + modelSpecifications.id + "ListUpdated event) async* {");
    codeBuffer.writeln(spaces(4) + "yield " + modelSpecifications.id + "ListLoaded(values: event.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _close() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Future<void> close() {");
    codeBuffer.writeln(spaces(4) + "_" + firstLowerCase(modelSpecifications.id) + "sListSubscription?.cancel();");
    codeBuffer.writeln(spaces(4) + "return super.close();");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "ListBloc extends Bloc<" + modelSpecifications.id + "ListEvent, " + modelSpecifications.id + "ListState> {");

    codeBuffer.writeln(_dataMembers());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_initialState());
    codeBuffer.writeln(_mappers());
    codeBuffer.writeln(_mapEventToState());
    codeBuffer.writeln(_close());

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listBlocFileName();
  }
}
