import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """

/*
 * \${id}ComponentEvent is the base class for events to be used with constructing a \${id}ComponentBloc 
 */
abstract class \${id}ComponentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

/*
 * Fetch\${id}Component is the event to instruct the bloc to fetch the component
 */
class Fetch\${id}Component extends \${id}ComponentEvent {
  final String? id;

  /*
   * Construct the Fetch\${id}Component
   */
  Fetch\${id}Component({ this.id });
}

/*
 * \${id}ComponentUpdated is the event to inform the bloc that a component has been updated
 */
class \${id}ComponentUpdated extends \${id}ComponentEvent {
  final \${id}Model value;

  /*
   * Construct the \${id}ComponentUpdated
   */
  \${id}ComponentUpdated({ required this.value });
}

""";

class ComponentEventCodeGenerator extends CodeGenerator {
  ComponentEventCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.modelFileName()}"));
    headerBuffer.writeln();
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
    return modelSpecifications.componentEventFileName();
  }
}
