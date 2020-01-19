import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

class FormBlocCodeGenerator extends CodeGenerator {
  FormBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formStateFileName()) + "';");
    headerBuffer.writeln("import '../tools/string_validator.dart';");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _initialState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "get initialState => " + modelSpecifications.id + "FormUninitialized();");
    return codeBuffer.toString();
  }

  String _yield(int amountOfSpaces, Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.fieldValidation != null) {
      codeBuffer.writeln(spaces(amountOfSpaces) + "if (!_is" + firstUpperCase(field.fieldName) + "Valid(event.value)) {");
      String errorClassName = firstUpperCase(field.fieldName) + modelSpecifications.id + "FormError(message: \"Invalid value\", value: newValue);";
      codeBuffer.writeln(spaces(amountOfSpaces + 2) + "yield " + errorClassName + "");
      codeBuffer.writeln(spaces(amountOfSpaces) + "} else {");
      codeBuffer.writeln(spaces(amountOfSpaces + 2) + "yield Submittable" + modelSpecifications.id + "Form(value: newValue);");
      codeBuffer.writeln(spaces(amountOfSpaces) + "}");
    } else {
      codeBuffer.writeln(spaces(amountOfSpaces) + "yield Submittable" + modelSpecifications.id + "Form(value: newValue);");
    }
    return codeBuffer.toString();
  }

  String _mapEventToState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "Stream<" + modelSpecifications.formStateClassName() + "> mapEventToState(" + modelSpecifications.formEventClassName() + " event) async* {");
    codeBuffer.writeln(spaces(4) + "final currentState = state;");
    codeBuffer.writeln(spaces(4) + "if (currentState is " + modelSpecifications.id + "FormUninitialized) {");
    codeBuffer.writeln(spaces(6) + "if (event is Initialise" + modelSpecifications.id + "FormEvent) {");
    codeBuffer.writeln(spaces(8) + modelSpecifications.id + "FormLoaded loaded = " + modelSpecifications.id + "FormLoaded(value: event.value);");
    codeBuffer.writeln(spaces(8) + "yield " + "loaded;");
    codeBuffer.writeln(spaces(8) + "return;");
    codeBuffer.writeln(spaces(6) + "}");
    codeBuffer.writeln(spaces(4) + "} else if (currentState is " + modelSpecifications.id + "FormInitialized) {");
    codeBuffer.writeln(spaces(6) + modelSpecifications.modelClassName() + " newValue = null;");
    modelSpecifications.fields.forEach((field) {
      String className = "Changed" + modelSpecifications.id + firstUpperCase(field.fieldName);
      codeBuffer.writeln(spaces(6) + "if (event is " + className + ") {");
      if (field.isInt()) {
        codeBuffer.writeln(spaces(8) + "if (isInt(event.value)) {");
        codeBuffer.writeln(
            spaces(10) + "newValue = currentState.value.copyWith(" +
                field.fieldName + ": int.parse(event.value));");
        codeBuffer.writeln(_yield(10, field));
        codeBuffer.writeln(spaces(8) + "} else {");
        codeBuffer.writeln(
            spaces(10) + "newValue = currentState.value.copyWith(" +
                field.fieldName + ": 0);");
        String errorClassName = firstUpperCase(field.fieldName) + modelSpecifications.id + "FormError(message: \"Value should be a number\", value: newValue);";
        codeBuffer.writeln(spaces(10) + "yield " + errorClassName + "");
        codeBuffer.writeln(spaces(8) + "}");
      } else if (field.isDouble()) {
        codeBuffer.writeln(spaces(8) + "if (isDouble(event.value)) {");
        codeBuffer.writeln(
            spaces(10) + "newValue = currentState.value.copyWith(" +
                field.fieldName + ": double.parse(event.value));");
        codeBuffer.writeln(_yield(10, field));
        codeBuffer.writeln(spaces(8) + "} else {");
        codeBuffer.writeln(
            spaces(10) + "newValue = currentState.value.copyWith(" +
                field.fieldName + ": 0.0);");
        String errorClassName = firstUpperCase(field.fieldName) + modelSpecifications.id + "FormError(message: \"Value should be a number or decimal number\", value: newValue);";
        codeBuffer.writeln(spaces(10) + "yield " + errorClassName + "");
        codeBuffer.writeln(spaces(8) + "}");
      } else {
        codeBuffer.writeln(spaces(8) + "newValue = currentState.value.copyWith(" +
            field.fieldName + ": event.value);");
        codeBuffer.writeln(_yield(8, field));
      }
      codeBuffer.writeln(spaces(8) + "return;");
      codeBuffer.writeln(spaces(6) + "}");
    });

    codeBuffer.writeln(spaces(6) + "if (event is " + modelSpecifications.id + "FormSubmitted) {");
    codeBuffer.writeln(spaces(8) + "newValue = currentState.value;");
    codeBuffer.writeln(spaces(8) + "yield " + modelSpecifications.id + "SuccessfullySubmitted(value: newValue);");
    codeBuffer.writeln(spaces(8) + "return;");
    codeBuffer.writeln(spaces(6) + "}");

    codeBuffer.writeln(spaces(4) + "}");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _validations() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.fieldValidation != null) {
        codeBuffer.writeln(
            spaces(2) + "bool _is" + firstUpperCase(field.fieldName) +
                "Valid(" + field.dartModelType() + " value) {");
        codeBuffer.writeln(field.fieldValidation);
        codeBuffer.writeln(spaces(2) + "}");
      }
    });
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "FormBloc extends Bloc<" + modelSpecifications.formEventClassName() + ", " + modelSpecifications.formStateClassName() + "> {");

    codeBuffer.writeln(_initialState());
    codeBuffer.writeln(_mapEventToState());
    codeBuffer.writeln(_validations());

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formBlocFileName();
  }
}
