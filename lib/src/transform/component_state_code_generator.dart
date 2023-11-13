import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
/* 
 * \${id}ComponentState is the base class for state for \${id}ComponentBloc
 */
abstract class \${id}ComponentState extends Equatable {
  const \${id}ComponentState();

  @override
  List<Object?> get props => [];
}

/* 
 * \${id}ComponentUninitialized is the uninitialized state of the \${id}ComponentBloc 
 */
class \${id}ComponentUninitialized extends \${id}ComponentState {}

/* 
 * \${id}ComponentError is the error state of the \${id}ComponentBloc 
 */
class \${id}ComponentError extends \${id}ComponentState {
  final String? message;
  \${id}ComponentError({ this.message });
}

/* 
 * \${id}ComponentPermissionDenied is to indicate permission denied state of the \${id}ComponentBloc 
 */
class \${id}ComponentPermissionDenied extends \${id}ComponentState {
  \${id}ComponentPermissionDenied();
}

/* 
 * \${id}ComponentLoaded is used to set the state of the \${id}ComponentBloc to the loaded state
 */
class \${id}ComponentLoaded extends \${id}ComponentState {
  final \${id}Model value;

  /* 
   * construct \${id}ComponentLoaded
   */
  const \${id}ComponentLoaded({ required this.value });

  /* 
   * copy method
   */
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
  ComponentStateCodeGenerator({required super.modelSpecifications});

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
    return modelSpecifications.componentStateFileName();
  }
}
