import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';
import 'gen_spec.dart';
import 'group.dart';

class ModelSpecification extends Specification {
  final List<Field> fields;
  final List<Group> groups;
  final GenerateSpecification generate;

  ModelSpecification({ String id, this.generate, this.fields, this.groups }) : super(id: id);

  Map<String, Object> toJson() {
    List<Map<String, dynamic>> jsonFields = fields != null
        ? fields.map((i) => i.toJson()).toList()
        : null;

    List<Map<String, dynamic>> jsonGroups = groups != null
        ? groups.map((i) => i.toJson()).toList()
        : null;

    return <String, dynamic>{
      "id": id,
      "generate": generate.toJson(),
      'fields': jsonFields,
      'groups': jsonGroups,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [id, generate, fields, groups];

  @override
  String toString() {
    return 'ModelSpecificationEntity { id: $id, requiresBloc: $generate }';
  }

  static ModelSpecification fromJson(Map<String, Object> json) {
    final theItems = (json['fields'] as List<dynamic>)
        .map((dynamic item) =>
        Field.fromJson(item as Map<String, dynamic>))
        .toList();

    var theGroups;
    var jsonGroups = json['groups'];
    if (jsonGroups != null) {
      theGroups = (json['groups'] as List<dynamic>)
          .map((dynamic item) =>
          Group.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ModelSpecification(
        id: json["id"] as String,
        generate: GenerateSpecification.fromJson(json["generate"]),
        fields: theItems,
        groups: theGroups
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

  List<Field> fieldsForGroups(Group group) {
    final List<Field> thoseFields = new List();
    fields.forEach((field) {
       if (field.group == group.group) thoseFields.add(field);
    });
    return thoseFields;
  }

  bool _exists(String groupId) {
    if (groups == null) return false;
    for (var group in groups) {
      if (group.group == groupId)
        return true;
    }
    return false;
  }

  bool hasUngroupedFields() {
    return (unGroupedFields().length > 0);
  }

  List<Field> unGroupedFields() {
    final List<Field> thoseFields = new List();
    fields.forEach((field) {
      if (field.group == null) thoseFields.add(field);
      else if (!_exists(field.group)) thoseFields.add(field);
    });
    return thoseFields;
  }
}
