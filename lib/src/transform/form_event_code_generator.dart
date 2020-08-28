import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _initialiseNewMenuFormEvent = """
class InitialiseNew\${id}FormEvent extends \${id}FormEvent {
}

""";

class FormEventCodeGenerator extends CodeGenerator {
  FormEventCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.writeln("import 'package:meta/meta.dart';");
    headerBuffer.writeln(base_imports(repo: true, model: true, entity: true));

    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _eventWithModel(String name, String modelClassName) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + name + " extends " + modelSpecifications.id + "FormEvent {");
    codeBuffer.writeln(spaces(2) + "final " + modelClassName + " value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [ value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + name + "({this.value});");
    codeBuffer.writeln("}");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();
    String formClassName = modelSpecifications.id + "FormEvent";
    codeBuffer.writeln("@immutable");
    codeBuffer.writeln("abstract class " + formClassName + " extends Equatable {");
    codeBuffer.writeln(spaces(2) + "const " + formClassName + "();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object> get props => [];");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln(process(_initialiseNewMenuFormEvent, parameters: <String, String> { '\${id}': modelSpecifications.id }));

    codeBuffer.writeln(_eventWithModel("Initialise" + modelSpecifications.id + "FormEvent", modelClassName));
    codeBuffer.writeln(_eventWithModel("Initialise" + modelSpecifications.id + "FormNoLoadEvent", modelClassName));

    modelSpecifications.fields.forEach((field) {
      String className = "Changed" + modelSpecifications.id + firstUpperCase(field.fieldName);
      codeBuffer.writeln("class " + className + " extends " + formClassName + " {");
      if (field.isInt() || field.isDouble() || field.isString() || (field.association))
        codeBuffer.writeln(spaces(2) + "final String value;");
      else
        codeBuffer.writeln(spaces(2) + "final " + field.dartModelType() + " value;");
      codeBuffer.writeln();
      codeBuffer.writeln(spaces(2) + className + "({this.value});");
      codeBuffer.writeln();
      codeBuffer.writeln(spaces(2) + "@override");
      codeBuffer.writeln(spaces(2) + "List<Object> get props => [ value ];");
      codeBuffer.writeln();
      codeBuffer.writeln(spaces(2) + "@override");
      codeBuffer.writeln(spaces(2) + "String toString() => '" + className + "{ value: \$value }';");
      codeBuffer.writeln("}");
      codeBuffer.writeln();
    });

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formEventFileName();
  }
}
