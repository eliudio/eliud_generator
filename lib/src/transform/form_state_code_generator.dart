import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class FormStateCodeGenerator extends CodeGenerator {
  FormStateCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");

    headerBuffer.writeln("import 'package:equatable/equatable.dart';");
    headerBuffer.writeln("import 'package:meta/meta.dart';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _generateClass({required String className, required String extendsThis}) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + className + " extends " + extendsThis + " { ");
    codeBuffer.writeln(spaces(2) + "const " + className + "({ String? message, " + modelSpecifications.modelClassName() + "? value }): super(message: message, value: value);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [ message, value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    codeBuffer.writeln(spaces(4) + "return '''" + className + " {");
    codeBuffer.writeln(spaces(6) + "value: \$value,");
    codeBuffer.writeln(spaces(6) + "message: \$message,");
    codeBuffer.writeln(spaces(4) + "}''';");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String _generateClass2({required String className, required String extendsThis}) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + className + " extends " + extendsThis + " { ");
    codeBuffer.writeln(spaces(2) + "const " + className + "({ " + modelSpecifications.modelClassName() + "? value }): super(value: value);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [ value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    codeBuffer.writeln(spaces(4) + "return '''" + className + " {");
    codeBuffer.writeln(spaces(6) + "value: \$value,");
    codeBuffer.writeln(spaces(4) + "}''';");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String modelClassName = modelSpecifications.modelClassName();
    codeBuffer.writeln("@immutable");
    codeBuffer.writeln("abstract class " + modelSpecifications.formStateClassName() + " extends Equatable {");
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.formStateClassName() + "();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [];");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("// Startup: menu has not been initialised yet and so we should show a \"loading indicator\" or something");
    codeBuffer.writeln("class " + modelSpecifications.id + "FormUninitialized extends " + modelSpecifications.formStateClassName() + " {");
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    codeBuffer.writeln(spaces(4) + "return '''" + modelSpecifications.formStateClassName() + "()''';");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("// " + modelClassName + " has been initialised and hence " + modelClassName + " is available");
    codeBuffer.writeln("class " + modelSpecifications.id + "FormInitialized extends " + modelSpecifications.formStateClassName() + " {");
    codeBuffer.writeln(spaces(2) + "final " + modelClassName + "? value;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [ value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "FormInitialized({ this.value });");
    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln("// Menu has been initialised and hence a menu is available");
    codeBuffer.writeln("abstract class " + modelSpecifications.id + "FormError extends " + modelSpecifications.id + "FormInitialized" + " {");
    codeBuffer.writeln(spaces(2) + "final String? message;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "List<Object?> get props => [ message, value ];");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "const " + modelSpecifications.id + "FormError({this.message, " + modelClassName + "? value }) : super(value: value);");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    codeBuffer.writeln(spaces(4) + "return '''" + modelSpecifications.id + "FormError {");
    codeBuffer.writeln(spaces(6) + "value: \$value,");
    codeBuffer.writeln(spaces(6) + "message: \$message,");
    codeBuffer.writeln(spaces(4) + "}''';");
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");

    modelSpecifications.fields.forEach((field) {
      String className = firstUpperCase(field.fieldName) + modelSpecifications.id + "FormError";
      String extendsThis = modelSpecifications.id + "FormError";
      codeBuffer.writeln(_generateClass(className: className, extendsThis: extendsThis));
    });

    codeBuffer.writeln(_generateClass2(className: modelSpecifications.id + "FormLoaded", extendsThis: modelSpecifications.id + "FormInitialized"));
    codeBuffer.writeln(_generateClass2(className: "Submittable" + modelSpecifications.id + "Form", extendsThis: modelSpecifications.id + "FormInitialized"));

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formStateFileName();
  }
}
