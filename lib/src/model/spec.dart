import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'field.dart';

abstract class Specification extends Equatable {
  final String id;

  Specification({this.id});

  Map<String, Object> toJson();
  String toJsonString();

  String modelClassName() {
    return id;
  }

  String entityClassName() {
    return id + "Entity";
  }
}
