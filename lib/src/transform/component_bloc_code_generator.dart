import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _code = """
class \${id}ComponentBloc extends Bloc<\${id}ComponentEvent, \${id}ComponentState> {
  final \${id}Repository? \${lid}Repository;
  StreamSubscription? _\${lid}Subscription;

  void _mapLoad\${id}ComponentUpdateToState(String documentId) {
    _\${lid}Subscription?.cancel();
    _\${lid}Subscription = \${lid}Repository!.listenTo(documentId, (value) {
      if (value != null) {
        add(\${id}ComponentUpdated(value: value));
      }
    });
  }

  /*
   * Construct \${id}ComponentBloc
   */
  \${id}ComponentBloc({ this.\${lid}Repository }): super(\${id}ComponentUninitialized()) {
    on <Fetch\${id}Component> ((event, emit) {
      _mapLoad\${id}ComponentUpdateToState(event.id!);
    });
    on <\${id}ComponentUpdated> ((event, emit) {
      emit(\${id}ComponentLoaded(value: event.value));
    });
  }

  /*
   * Close the \${id}ComponentBloc
   */
  @override
  Future<void> close() {
    _\${lid}Subscription?.cancel();
    return super.close();
  }

}
""";

class ComponentBlocCodeGenerator extends CodeGenerator {
  ComponentBlocCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.modelFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.componentEventFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.componentStateFileName()}"));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.repositoryFileName()}"));
    headerBuffer.writeln("import 'package:flutter/services.dart';");
    headerBuffer.writeln();
    if (uniqueAssociationTypes.isNotEmpty) headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
    }));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentBlocFileName();
  }
}
