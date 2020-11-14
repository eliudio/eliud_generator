import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

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
    String className = modelSpecifications.repositoryClassName();
    String modelClassName = modelSpecifications.modelClassName();
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "ComponentState extends Equatable {");

    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "ComponentState();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ComponentUninitialized extends " + modelSpecifications.id + "ComponentState {}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ComponentError extends " + modelSpecifications.id + "ComponentState {");
    codeBuffer.writeln(spaces(2) + "final String message;");
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ComponentError({ this.message });");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "ComponentLoaded extends " + modelSpecifications.id + "ComponentState {");
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "ComponentLoaded({ this.value });");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "ComponentLoaded copyWith({ " + modelSpecifications.modelClassName() + " copyThis }) {");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.id + "ComponentLoaded(value: copyThis ?? this.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [value];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() => '" + modelSpecifications.id + "ComponentLoaded { value: \$value }';");

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentStateFileName();
  }
}
