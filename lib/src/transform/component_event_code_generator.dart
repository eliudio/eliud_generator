import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

class ComponentEventCodeGenerator extends CodeGenerator {
  ComponentEventCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "ComponentEvent extends Equatable {");

    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class Fetch" + modelSpecifications.id + "Component extends "+ modelSpecifications.id + "ComponentEvent {");
    codeBuffer.writeln(spaces(2) + "final String id;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "Fetch" + modelSpecifications.id + "Component({ this.id });");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.componentEventFileName();
  }
}
