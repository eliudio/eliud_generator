import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _evaluateNewMenuFormEvent = """
      on <InitialiseNew\${id}FormEvent> ((event, emit) {
        \${id}FormLoaded loaded = \${id}FormLoaded(value: \${id}Model(
              \${newModelValue}
        ));
        emit(loaded);
      });

""";

const String _isDocumentIDValid = """
  DocumentID\${id}FormError error(String message, \${id}Model newValue) => DocumentID\${id}FormError(message: message, value: newValue);

  Future<\${id}FormState> _isDocumentIDValid(String? value, \${id}Model newValue) async {
    if (value == null) return Future.value(error("Provide value for documentID", newValue));
    if (value.length == 0) return Future.value(error("Provide value for documentID", newValue));
    Future<\${id}Model?> findDocument = \${lid}Repository(appId: appId)!.get(value);
    return await findDocument.then((documentFound) {
      if (documentFound == null) {
        return Submittable\${id}Form(value: newValue);
      } else {
        return error("Invalid documentID: already exists", newValue);
      }
    });
  }

""";

String _imports(String packageName, List<String>? depends) =>
    """
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:eliud_core/tools/firestore/firestore_tools.dart';
import 'package:flutter/cupertino.dart';

import 'package:eliud_core/tools/enums.dart';
import 'package:eliud_core/tools/common_tools.dart';

import 'package:eliud_core/model/rgb_model.dart';

import 'package:eliud_core/tools/string_validator.dart';

""" +
    base_imports(packageName,
        repo: true, model: true, entity: true, depends: depends);

class FormBlocCodeGenerator extends CodeGenerator {
  FormBlocCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_FORM_BLOC);
    headerBuffer.writeln(
        _imports(modelSpecifications.packageName, modelSpecifications.depends));

    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/" + modelSpecifications.formEventFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/" + modelSpecifications.formStateFileName()));
    headerBuffer.write(importString(modelSpecifications.packageName,
        "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.writeln();

    return headerBuffer.toString();
  }

  String _emit(int amountOfSpaces, Field field) {
    StringBuffer codeBuffer = StringBuffer();
    if (field.fieldName == "documentID") {
      if (modelSpecifications.generate.generateFirestoreRepository) {
        codeBuffer.writeln(spaces(amountOfSpaces) +
            "if (formAction == FormAction.AddAction) {");
        codeBuffer.writeln(spaces(amountOfSpaces + 2) +
            "emit(await _isDocumentIDValid(event.value, newValue!));");
        codeBuffer.writeln(spaces(amountOfSpaces) + "} else {");
        codeBuffer.writeln(spaces(amountOfSpaces + 2) +
            "emit(Submittable" +
            modelSpecifications.id +
            "Form(value: newValue));");
        codeBuffer.writeln(spaces(amountOfSpaces) + "}");
      } else {
        codeBuffer.writeln(spaces(amountOfSpaces) +
            "emit(Submittable" +
            modelSpecifications.id +
            "Form(value: newValue));");
      }
    } else if (field.fieldValidation != null) {
      codeBuffer.writeln(spaces(amountOfSpaces) +
          "if (!_is" +
          firstUpperCase(field.fieldName) +
          "Valid(event.value)) {");
      String errorClassName = firstUpperCase(field.fieldName) +
          modelSpecifications.id +
          "FormError(message: \"Invalid value\", value: newValue)";
      codeBuffer.writeln(
          spaces(amountOfSpaces + 2) + "emit(" + errorClassName + ");");
      codeBuffer.writeln(spaces(amountOfSpaces) + "} else {");
      codeBuffer.writeln(spaces(amountOfSpaces + 2) +
          "emit(Submittable" +
          modelSpecifications.id +
          "Form(value: newValue));");
      codeBuffer.writeln(spaces(amountOfSpaces) + "}");
    } else {
      codeBuffer.writeln(spaces(amountOfSpaces) +
          "emit(Submittable" +
          modelSpecifications.id +
          "Form(value: newValue));");
    }
    return codeBuffer.toString();
  }

  String _mapEventToState() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) +
        "Stream<" +
        modelSpecifications.formStateClassName() +
        "> mapEventToState(" +
        modelSpecifications.formEventClassName() +
        " event) async* {");
    codeBuffer.writeln(spaces(4) + "final currentState = state;");
    codeBuffer.writeln(spaces(4) +
        "if (currentState is " +
        modelSpecifications.id +
        "FormUninitialized) {");

    StringBuffer newModelBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.defaultValue != null) {
          newModelBuffer.write(spaces(33) + field.fieldName + ": ");
          if ((field.isInt()) || (field.isDouble())) {
            newModelBuffer.write(field.defaultValue);
          } else if (field.isString()) {
            newModelBuffer.write("\"" + field.getDefaultValue() + "\"");
          } else {
            newModelBuffer.write(field.defaultValue);
          }
          newModelBuffer.writeln(", ");
        } else {
          if (field.isArray()) {
            newModelBuffer.writeln(spaces(33) + field.fieldName + ": [],");
          } else if (field.isInt()) {
            newModelBuffer.writeln(spaces(33) + field.fieldName + ": 0,");
          } else if (field.isDouble()) {
            newModelBuffer.writeln(spaces(33) + field.fieldName + ": 0.0,");
          } else if (field.isString()) {
            newModelBuffer.writeln(spaces(33) + field.fieldName + ": \"\",");
          }
        }
      }
    });

    codeBuffer.writeln(process(_evaluateNewMenuFormEvent,
        parameters: <String, String>{
          '\${id}': modelSpecifications.id,
          '\${newModelValue}': newModelBuffer.toString()
        }));

    codeBuffer.writeln(spaces(6) +
        "if (event is Initialise" +
        modelSpecifications.id +
        "FormEvent) {");
    if (withRepository())
      codeBuffer.writeln(spaces(8) +
          "// Need to re-retrieve the document from the repository so that I get all associated types");
    codeBuffer.write(spaces(8) +
        modelSpecifications.id +
        "FormLoaded loaded = " +
        modelSpecifications.id +
        "FormLoaded(value: ");
    if (withRepository())
      codeBuffer.writeln("await " +
          firstLowerCase(modelSpecifications.id) +
          "Repository(appId: appId)!.get(event.value!.documentID));");
    else
      codeBuffer.writeln("event.value);");
    codeBuffer.writeln(spaces(8) + "emit(" + "loaded);");
    codeBuffer.writeln(spaces(6) +
        "} else if (event is Initialise" +
        modelSpecifications.id +
        "FormNoLoadEvent) {");
    codeBuffer.writeln(spaces(8) +
        modelSpecifications.id +
        "FormLoaded loaded = " +
        modelSpecifications.id +
        "FormLoaded(value: event.value);");
    codeBuffer.writeln(spaces(8) + "emit(" + "loaded);");
    codeBuffer.writeln(spaces(6) + "}");

    codeBuffer.writeln(spaces(4) +
        "} else if (currentState is " +
        modelSpecifications.id +
        "FormInitialized) {");
    codeBuffer.writeln(spaces(6) +
        modelSpecifications.modelClassName() +
        "? newValue = null;");
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (!field.isHidden()) {
          String className = "Changed" +
              modelSpecifications.id +
              firstUpperCase(field.fieldName);
          codeBuffer.writeln(
              spaces(6) + "on <" + className + "> ((event, emit) async {");
          if (field.isInt()) {
            codeBuffer.writeln(spaces(8) + "if (isInt(event.value)) {");
            codeBuffer.writeln(spaces(10) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": int.parse(event.value!));");
            codeBuffer.writeln(_emit(10, field));
            codeBuffer.writeln(spaces(8) + "} else {");
            codeBuffer.writeln(spaces(10) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": 0);");
            String errorClassName = firstUpperCase(field.fieldName) +
                modelSpecifications.id +
                "FormError(message: \"Value should be a number\", value: newValue)";
            codeBuffer.writeln(spaces(10) + "emit(" + errorClassName + ");");
            codeBuffer.writeln(spaces(8) + "}");
          } else if (field.isDouble()) {
            codeBuffer.writeln(spaces(8) + "if (isDouble(event.value!)) {");
            codeBuffer.writeln(spaces(10) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": double.parse(event.value!));");
            codeBuffer.writeln(_emit(10, field));
            codeBuffer.writeln(spaces(8) + "} else {");
            codeBuffer.writeln(spaces(10) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": 0.0);");
            String errorClassName = firstUpperCase(field.fieldName) +
                modelSpecifications.id +
                "FormError(message: \"Value should be a number or decimal number\", value: newValue)";
            codeBuffer.writeln(spaces(10) + "emit(" + errorClassName + ");");
            codeBuffer.writeln(spaces(8) + "}");
          } else if (field.isAssociation()) {
            codeBuffer.writeln(spaces(8) + "if (event.value != null)");
            codeBuffer.writeln(spaces(10) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": await " +
                firstLowerCase(field.fieldType) +
                "Repository(appId: appId)!.get(event.value));");
            codeBuffer.writeln(_emit(8, field));
          } else if (field.isServerTimestamp()) {
            codeBuffer.writeln(spaces(8) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": dateTimeFromTimestampString(event.value!));");
            codeBuffer.writeln(_emit(8, field));
          } else {
            codeBuffer.writeln(spaces(8) +
                "newValue = currentState.value!.copyWith(" +
                field.fieldName +
                ": event.value);");
            codeBuffer.writeln(_emit(8, field));
          }
          codeBuffer.writeln(spaces(6) + "});");
        }
      }
    });

    codeBuffer.writeln(spaces(4) + "}");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _validations() {
    StringBuffer codeBuffer = StringBuffer();
    modelSpecifications.fields.forEach((field) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldValidation != null) {
          codeBuffer.writeln(spaces(2) +
              "bool _is" +
              firstUpperCase(field.fieldName) +
              "Valid(" +
              field.dartModelType() +
              "? value) {");
          codeBuffer.writeln(field.fieldValidation);
          codeBuffer.writeln(spaces(2) + "}");
        }
      }
    });
    return codeBuffer.toString();
  }

  String _memberData() {
    StringBuffer codeBuffer = StringBuffer();
    if (withRepository()) {
      codeBuffer.writeln(spaces(2) + "final FormAction? formAction;");
    }
    codeBuffer.writeln(spaces(2) + "final String? appId;");

    return codeBuffer.toString();
  }

  String _constructor() {
    if (withRepository()) {
      return spaces(2) +
          modelSpecifications.id +
          "FormBloc(this.appId, { this.formAction }): super(" +
          modelSpecifications.id +
          "FormUninitialized());";
    } else {
      return spaces(2) +
          modelSpecifications.id +
          "FormBloc(this.appId, ): super(" +
          modelSpecifications.id +
          "FormUninitialized());";
    }
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " +
        modelSpecifications.id +
        "FormBloc extends Bloc<" +
        modelSpecifications.formEventClassName() +
        ", " +
        modelSpecifications.formStateClassName() +
        "> {");

    codeBuffer.writeln(_memberData());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_mapEventToState());
    codeBuffer.writeln(_validations());

    if (modelSpecifications.generate.generateFirestoreRepository) {
      codeBuffer
          .writeln(process(_isDocumentIDValid, parameters: <String, String>{
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
