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
}
