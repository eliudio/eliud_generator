import 'dart:convert';

import 'package:eliud_generator/src/tools/tool_set.dart';
import 'package:equatable/equatable.dart';

import 'field.dart';

abstract class Specification extends Equatable {
  final String id;

  Specification({this.id});

  Map<String, Object> toJson();
  String toJsonString();

  String modelClassName() {
    return id + "Model";
  }

  String entityClassName() {
    return id + "Entity";
  }

  String repositoryClassName() {
    return id + "Repository";
  }

  String firestoreClassName() {
    return id + "Firestore";
  }

  String componentClassName() {
    return "Abstract" + id + "Component";
  }

  String formClassName() {
    return id + "Form";
  }

  String formStateClassName() {
    return id + "FormState";
  }

  String formEventClassName() {
    return id + "FormEvent";
  }

  String listClassName() {
    return id + "List";
  }

  String modelFileName() {
    return camelcaseToUnderscore(id) + ".model.dart";
  }

  String entityFileName() {
    return camelcaseToUnderscore(id) + ".entity.dart";
  }

  String repositoryFileName() {
    return camelcaseToUnderscore(id) + ".repository.dart";
  }

  String firestoreFileName() {
    return camelcaseToUnderscore(id) + ".firestore.dart";
  }

  String componentStateFileName() {
    return camelcaseToUnderscore(id) + ".component.state.dart";
  }

  String componentEventFileName() {
    return camelcaseToUnderscore(id) + ".component.event.dart";
  }

  String componentBlocFileName() {
    return camelcaseToUnderscore(id) + ".component.bloc.dart";
  }

  String componentFileName() {
    return camelcaseToUnderscore(id) + ".component.dart";
  }

  String listStateFileName() {
    return camelcaseToUnderscore(id) + ".list.state.dart";
  }

  String listEventFileName() {
    return camelcaseToUnderscore(id) + ".list.event.dart";
  }

  String listBlocFileName() {
    return camelcaseToUnderscore(id) + ".list.bloc.dart";
  }

  String listFileName() {
    return camelcaseToUnderscore(id) + ".list.dart";
  }

  String formStateFileName() {
    return camelcaseToUnderscore(id) + ".form.state.dart";
  }

  String formEventFileName() {
    return camelcaseToUnderscore(id) + ".form.event.dart";
  }

  String formBlocFileName() {
    return camelcaseToUnderscore(id) + ".form.bloc.dart";
  }

  String formFileName() {
    return camelcaseToUnderscore(id) + ".form.dart";
  }
}
