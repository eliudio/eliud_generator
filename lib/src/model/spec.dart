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

  String modelFileName() {
    return camelcaseToUnderscore(id) + ".model.dart";
  }

  String entityFileName() {
    return camelcaseToUnderscore(id) + ".entity.dart";
  }
}
