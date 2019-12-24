import 'dart:convert';

import 'package:equatable/equatable.dart';

import 'field.dart';

class ModelSpecification extends Equatable {
  final String id;
  final List<Field> fields;

  ModelSpecification({ this.id, this.fields });

  Map<String, Object> toJson() {
    List<Map<String, dynamic>> jsonFields = fields != null
        ? fields.map((i) => i.toJson()).toList()
        : null;

    return <String, dynamic>{
      "id": id,
      'fields': jsonFields,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [id, fields];

  @override
  String toString() {
    return 'ModelSpecificationEntity { id: $id }';
  }

  String modelClassName() {
    return id;
  }

  String entityClassName() {
    return id + "Entity";
  }

  static ModelSpecification fromJson(Map<String, Object> json) {
    final menuItems = (json['fields'] as List<dynamic>)
        .map((dynamic item) =>
        Field.fromJson(item as Map<String, dynamic>))
        .toList();

    return ModelSpecification(
        id: json["id"] as String,
        fields: menuItems
    );
  }

  static ModelSpecification fromJsonString(String json) {
    Map<String, dynamic> modelSpecificationMap = jsonDecode(json);
    return fromJson(modelSpecificationMap);
  }

}
