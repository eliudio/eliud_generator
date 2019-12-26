import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';

class ModelSpecification extends Specification {
  final List<Field> fields;

  ModelSpecification({ String id, this.fields }) : super(id: id);

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

  List<String> uniqueAssociationTypes() {
    List<String> uniqueAssociationTypes = List();
    fields.forEach((field) {
      if (field.association) {
        String typeName = field.fieldType;
        if (!uniqueAssociationTypes.contains(typeName)) {
          uniqueAssociationTypes.add(typeName);
        }
      }
    });
    return uniqueAssociationTypes;
  }

}
