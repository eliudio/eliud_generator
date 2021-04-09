import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

String _code = """
abstract class \${id}ListState extends Equatable {
  const \${id}ListState();

  @override
  List<Object?> get props => [];
}

class \${id}ListLoading extends \${id}ListState {}

class \${id}ListLoaded extends \${id}ListState {
  final List<\${id}Model?>? values;
  final bool? mightHaveMore;

  const \${id}ListLoaded({this.mightHaveMore, this.values = const []});

  @override
  List<Object?> get props => [ values, mightHaveMore ];

  @override
  String toString() => '\${id}ListLoaded { values: \$values }';
}

class \${id}NotLoaded extends \${id}ListState {}
""";

class ListStateCodeGenerator extends CodeGenerator {
  ListStateCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/" + modelSpecifications.modelFileName()));
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
    return modelSpecifications.listStateFileName();
  }
}
