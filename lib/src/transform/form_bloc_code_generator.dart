import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _evaluateNewMenuFormEvent = """
      if (event is InitialiseNew\${id}FormEvent) {
        \${id}FormLoaded loaded = \${id}FormLoaded(value: \${id}Model(
              \${newModelValue}
        ));
        yield loaded;
        return;

      }

""";

const String _isDocumentIDValid = """
  DocumentID\${id}FormError error(String message, \${id}Model newValue) => DocumentID\${id}FormError(message: message, value: newValue);

  Future<\${id}FormState> _isDocumentIDValid(String value, \${id}Model newValue) async {
    if (value == null) return Future.value(error("Provide value for documentID", newValue));
    if (value.length == 0) return Future.value(error("Provide value for documentID", newValue));
    Future<\${id}Model> findDocument = _\${lid}Repository.get(value);
    return await findDocument.then((documentFound) {
      if (documentFound == null) {
        return Submittable\${id}Form(value: newValue);
      } else {
        return error("Invalid documentID: already exists", newValue);
      }
    });
  }

""";

class FormBlocCodeGenerator extends CodeGenerator {
  FormBlocCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:bloc/bloc.dart';");
    headerBuffer.writeln("import '../shared/rgb.model.dart';");
    headerBuffer.writeln("import 'package:eliud_model/tools/enums.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formEventFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.formStateFileName()) + "';");
    headerBuffer.writeln("import '../tools/string_validator.dart';");
    headerBuffer.writeln("import 'package:flutter/cupertino.dart';");
    headerBuffer.writeln("import '../shared/repository_export.dart';");

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
    if (field.fieldName == "documentID") {
      if (modelSpecifications.generate.generateFirestoreRepository) {
        codeBuffer.writeln(spaces(amountOfSpaces) + "if (formAction == FormAction.AddAction) {");
        codeBuffer.writeln(spaces(amountOfSpaces + 2) +
            "yield* _isDocumentIDValid(event.value, newValue).asStream();");
        codeBuffer.writeln(spaces(amountOfSpaces) + "} else {");
        codeBuffer.writeln(spaces(amountOfSpaces + 2) + "yield Submittable" + modelSpecifications.id + "Form(value: newValue);");
        codeBuffer.writeln(spaces(amountOfSpaces) + "}");
      }
    } else if (field.fieldValidation != null) {
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


    StringBuffer newModelBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.defaultValue != null) {
        newModelBuffer.write(spaces(33) + field.fieldName + ": ");
        if ((field.isInt()) || (field.isDouble())) {
          newModelBuffer.write(field.defaultValue);
        } else if (field.isString()) {
          newModelBuffer.write("\"" + field.defaultValue + "\"");
        } else {
          newModelBuffer.write(field.defaultValue);
        }
        newModelBuffer.writeln(", ");
      } else {
        if (field.array)
          newModelBuffer.writeln(spaces(33) + field.fieldName + ": [],");
        if (field.isInt()) {
          newModelBuffer.writeln(spaces(33) + field.fieldName + ": 0,");
        } else if (field.isDouble()) {
          newModelBuffer.writeln(spaces(33) + field.fieldName + ": 0.0,");
        } else if (field.isString()) {
          newModelBuffer.writeln(spaces(33) + field.fieldName + ": \"\",");
        }
      }
    });

    codeBuffer.writeln(process(_evaluateNewMenuFormEvent, parameters: <String, String> {
      '\${id}': modelSpecifications.id,
      '\${newModelValue}': newModelBuffer.toString()
    }));

    codeBuffer.writeln(spaces(6) + "if (event is Initialise" + modelSpecifications.id + "FormEvent) {");
    if (withRepository())
      codeBuffer.writeln(spaces(8) + "// Need to re-retrieve the document from the repository so that I get all associated types");
    codeBuffer.write(spaces(8) + modelSpecifications.id + "FormLoaded loaded = " + modelSpecifications.id + "FormLoaded(value: ");
    if (withRepository())
      codeBuffer.writeln("await _" + firstLowerCase(modelSpecifications.id) + "Repository.get(event.value.documentID));");
    else
      codeBuffer.writeln("event.value);");
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
      } else if (field.association) {
        codeBuffer.writeln(spaces(8) + "newValue = currentState.value.copyWith(" + field.fieldName + ": await _" + firstLowerCase(field.fieldType) + "Repository.get(event.value));");
        codeBuffer.writeln(_yield(8, field));
      } else {
        codeBuffer.writeln(spaces(8) + "newValue = currentState.value.copyWith(" +
            field.fieldName + ": event.value);");
        codeBuffer.writeln(_yield(8, field));
      }
      codeBuffer.writeln(spaces(8) + "return;");
      codeBuffer.writeln(spaces(6) + "}");
    });

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

  String _memberData() {
    StringBuffer codeBuffer = StringBuffer();
    if (withRepository()) {
      codeBuffer.writeln(
          spaces(2) + "final " + modelSpecifications.id + "Repository _" +
              firstLowerCase(modelSpecifications.id) + "Repository;");
      codeBuffer.writeln(spaces(2) + "final FormAction formAction;");
    }
    modelSpecifications.uniqueAssociationTypes().forEach((field) {
        codeBuffer.writeln(spaces(2) + "final " + field + "Repository _" + firstLowerCase(field) + "Repository;");
    });
    return codeBuffer.toString();
  }

  String _constructor() {
    List<String> uniqueAssociationTypes = modelSpecifications.uniqueAssociationTypes();
    if (!withRepository() && uniqueAssociationTypes.isEmpty) {
      return spaces(2) + modelSpecifications.id + "FormBloc();";
    }

    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.id + "FormBloc({");
    if (withRepository())
      codeBuffer.writeln(spaces(16) + "this.formAction, ");
      codeBuffer.writeln(spaces(16) + "@required " + modelSpecifications.id + "Repository " + firstLowerCase(modelSpecifications.id) + "Repository, ");
    uniqueAssociationTypes.forEach((field) {
        codeBuffer.writeln(spaces(16) + "@required " + field + "Repository " + firstLowerCase(field) + "Repository, ");
    });
    codeBuffer.writeln(spaces(14) + "}): ");
    if (withRepository()) {
      codeBuffer.writeln(
          spaces(10) + "assert(" + firstLowerCase(modelSpecifications.id) +
              "Repository != null),");
      codeBuffer.write(
          spaces(10) + "_" + firstLowerCase(modelSpecifications.id) +
              "Repository" + " = " + firstLowerCase(modelSpecifications.id) +
              "Repository");
      if (uniqueAssociationTypes.isEmpty)
        codeBuffer.writeln();
      else
        codeBuffer.writeln(",");
    }
    int i = 0;
    uniqueAssociationTypes.forEach((field) {
        codeBuffer.writeln(spaces(10) + "assert(" + firstLowerCase(field) + "Repository != null),");
        codeBuffer.write(spaces(10) + "_" + firstLowerCase(field) + "Repository" + " = " + firstLowerCase(field) + "Repository");
        i++;
        if (i < uniqueAssociationTypes.length) codeBuffer.writeln(",");
    });
    codeBuffer.writeln(";");
    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.id + "FormBloc extends Bloc<" + modelSpecifications.formEventClassName() + ", " + modelSpecifications.formStateClassName() + "> {");

    codeBuffer.writeln(_memberData());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_initialState());
    codeBuffer.writeln(_mapEventToState());
    codeBuffer.writeln(_validations());

    if (modelSpecifications.generate.generateFirestoreRepository) {
      codeBuffer.writeln(
          process(_isDocumentIDValid, parameters: <String, String>{
            '\${id}': modelSpecifications.id,
            '\${lid}': firstLowerCase(modelSpecifications.id)
          }));
    }

    codeBuffer.writeln("}");
    codeBuffer.writeln();

    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.formBlocFileName();
  }
}
