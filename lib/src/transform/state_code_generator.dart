import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

class StateCodeGenerator extends CodeGenerator {
  StateCodeGenerator ({ModelSpecification modelSpecifications})
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
    String className = modelSpecifications.repositoryClassName();
    String modelClassName = modelSpecifications.modelClassName();
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "State extends Equatable {");

    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "State();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "Uninitialized extends " + modelSpecifications.id + "State {}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "Error extends " + modelSpecifications.id + "State {");
    codeBuffer.writeln(spaces(2) + "final String message;");
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "Error({ this.message });");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class " + modelSpecifications.id + "Loaded extends " + modelSpecifications.id + "State {");
    codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "Loaded({ this.value });");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "Loaded copyWith({ " + modelSpecifications.modelClassName() + " copyThis }) {");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.id + "Loaded(value: copyThis ?? this.value);");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [value];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() => '" + modelSpecifications.modelClassName() + "Loaded { value: \$value }';");

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.stateFileName();
  }
}
