import 'package:eliud_generator/builder.dart';
import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

class ListEventCodeGenerator extends CodeGenerator {
  ListEventCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _generateClass(String className, bool isList) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + className + " extends "+ modelSpecifications.id + "ListEvent {");
    if (isList)
      codeBuffer.writeln(spaces(2) + "final List<" + modelSpecifications.modelClassName() + "> value;");
    else
      codeBuffer.writeln(spaces(2) + "final " + modelSpecifications.modelClassName() + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + className + "({ this.value });");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [ value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() => '" + className + "{ value: \$value }';");
    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "ListEvent extends Equatable {");
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "ListEvent();");

    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("class Load" + modelSpecifications.id + "List extends "+ modelSpecifications.id + "ListEvent {}");
    codeBuffer.writeln("class Load" + modelSpecifications.id + "ListWithDetails extends "+ modelSpecifications.id + "ListEvent {}");
    codeBuffer.writeln();

    codeBuffer.writeln(_generateClass("Add" + modelSpecifications.id + "List", false));
    codeBuffer.writeln(_generateClass("Update" + modelSpecifications.id + "List", false));
    codeBuffer.writeln(_generateClass("Delete" + modelSpecifications.id + "List", false));
    codeBuffer.writeln(_generateClass(modelSpecifications.id + "ListUpdated", true));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.listEventFileName();
  }
}
