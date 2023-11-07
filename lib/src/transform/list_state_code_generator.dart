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

  @override
  bool operator ==(Object other) => 
          other is \${id}ListLoaded &&
              runtimeType == other.runtimeType &&
              ListEquality().equals(values, other.values) &&
              mightHaveMore == other.mightHaveMore;

  @override
  int get hashCode => values.hashCode ^ mightHaveMore.hashCode;
}

class \${id}NotLoaded extends \${id}ListState {}
""";

class ListStateCodeGenerator extends CodeGenerator {
  ListStateCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer
        .writeln("import 'package:cloud_firestore/cloud_firestore.dart';");
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
    return modelSpecifications.listStateFileName();
  }
}
