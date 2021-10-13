import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
abstract class \${id}ComponentEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class Fetch\${id}Component extends \${id}ComponentEvent {
  final String? id;

  Fetch\${id}Component({ this.id });
}

class \${id}ComponentUpdated extends \${id}ComponentEvent {
  final \${id}Model value;

  \${id}ComponentUpdated({ required this.value });
}

""";

class ComponentEventCodeGenerator extends CodeGenerator {
  ComponentEventCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.modelFileName()));
    headerBuffer.writeln();
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
    return modelSpecifications.componentEventFileName();
  }
}
