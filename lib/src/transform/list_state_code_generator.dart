import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

class ListStateCodeGenerator extends CodeGenerator {
  ListStateCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "ListState extends Equatable {");

    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "ListState();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ListLoading extends " + modelSpecifications.id + "ListState {}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ListLoaded extends " + modelSpecifications.id + "ListState {");
    codeBuffer.writeln(spaces(2) + "final List<" + modelSpecifications.modelClassName() + "> values;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "ListLoaded({this.values = const []});");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [ values ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() => '" + modelSpecifications.id + "ListLoaded { values: \$values }';");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "NotLoaded extends " + modelSpecifications.id + "ListState {}");
    codeBuffer.writeln();

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listStateFileName();
  }
}
