import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
/*
THE BELOW CODE IS THE BLOC WITHOUT LISTENING TO THE UNDERLYING COMPONENT
LISTENING TO THE UNDERLYING COMPONENT ALLOWS TO MAKE CHANGES AND RECEIVING THOSE CHANGES WITHOUT NEEDING TO REOPEN THE PAGE
const String _codeOld = """
class \${id}ComponentBloc extends Bloc<\${id}ComponentEvent, \${id}ComponentState> {
  final \${id}Repository? \${lid}Repository;

  \${id}ComponentBloc({ this.\${lid}Repository }): super(\${id}ComponentUninitialized());
  @override
  Stream<\${id}ComponentState> mapEventToState(\${id}ComponentEvent event) async* {
    final currentState = state;
    if (event is Fetch\${id}Component) {
      try {
        if (currentState is \${id}ComponentUninitialized) {
          bool permissionDenied = false;
          final model = await \${lid}Repository!.get(event.id, onError: (error) {
            // Unfortunatly the below is currently the only way we know how to identify if a document is read protected
            if ((error is PlatformException) &&  (error.message!.startsWith("PERMISSION_DENIED"))) {
              permissionDenied = true;
            }
          });
          if (permissionDenied) {
            yield \${id}ComponentPermissionDenied();
          } else {
            if (model != null) {
              yield \${id}ComponentLoaded(value: model);
            } else {
              String? id = event.id;
              yield \${id}ComponentError(
                  message: "\${id} with id = '\$id' not found");
            }
          }
          return;
        }
      } catch (_) {
        yield \${id}ComponentError(message: "Unknown error whilst retrieving \${id}");
      }
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }

}
""";

*/

const String _code = """
class \${id}ComponentBloc extends Bloc<\${id}ComponentEvent, \${id}ComponentState> {
  final \${id}Repository? \${lid}Repository;
  StreamSubscription? _\${lid}Subscription;

  Stream<\${id}ComponentState> _mapLoad\${id}ComponentUpdateToState(String documentId) async* {
    _\${lid}Subscription?.cancel();
    _\${lid}Subscription = \${lid}Repository!.listenTo(documentId, (value) {
      if (value != null) add(\${id}ComponentUpdated(value: value));
    });
  }

  \${id}ComponentBloc({ this.\${lid}Repository }): super(\${id}ComponentUninitialized());

  @override
  Stream<\${id}ComponentState> mapEventToState(\${id}ComponentEvent event) async* {
    final currentState = state;
    if (event is Fetch\${id}Component) {
      yield* _mapLoad\${id}ComponentUpdateToState(event.id!);
    } else if (event is \${id}ComponentUpdated) {
      yield \${id}ComponentLoaded(value: event.value);
    }
  }

  @override
  Future<void> close() {
    _\${lid}Subscription?.cancel();
    return super.close();
  }

}
""";

class ComponentBlocCodeGenerator extends CodeGenerator {
  ComponentBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentEventFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.componentStateFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.writeln("import 'package:flutter/services.dart';");
    headerBuffer.writeln();
    if (uniqueAssociationTypes.isNotEmpty) headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(process(_code,
        parameters: <String, String> {
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
