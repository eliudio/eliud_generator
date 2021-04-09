import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
abstract class \${id}ComponentState extends Equatable {
  const \${id}ComponentState();

  @override
  List<Object?> get props => [];
}

class \${id}ComponentUninitialized extends \${id}ComponentState {}

class \${id}ComponentError extends \${id}ComponentState {
  final String? message;
  \${id}ComponentError({ this.message });
}

class \${id}ComponentPermissionDenied extends \${id}ComponentState {
  \${id}ComponentPermissionDenied();
}

class \${id}ComponentLoaded extends \${id}ComponentState {
  final \${id}Model? value;

  const \${id}ComponentLoaded({ this.value });

  \${id}ComponentLoaded copyWith({ \${id}Model? copyThis }) {
    return \${id}ComponentLoaded(value: copyThis ?? this.value);
  }

  @override
  List<Object?> get props => [value];

  @override
  String toString() => '\${id}ComponentLoaded { value: \$value }';
}
""";

class ComponentStateCodeGenerator extends CodeGenerator {
  ComponentStateCodeGenerator({ModelSpecification modelSpecifications})
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
    return modelSpecifications.componentStateFileName();
  }
}
