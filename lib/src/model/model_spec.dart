import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';
import 'gen_spec.dart';
import 'group.dart';
import 'list_fields.dart';

class ModelSpecificationPlus {
  final ModelSpecification modelSpecification;
  final String path;

  ModelSpecificationPlus({ this.modelSpecification, this.path });
}

class View {
  final String title;
  final String buttonLabel;
  final String name;
  final List<String> fields;
  final List<String> groups;

  View({this.name, this.fields, this.groups, this.title, this.buttonLabel});

  Map<String, Object> toJson() {
    return {
      "name": name,
    };
  }

  static View fromJson(Map<String, Object> json) {
    var jsonFields = json["fields"];
    var jsonGroups = json["groups"];
    return View(
      name: json["name"] as String,
      fields: jsonFields != null ? List.from(jsonFields) : null,
      groups: jsonGroups != null ? List.from(jsonGroups) : null,
      title: json["title"] as String,
      buttonLabel: json["buttonLabel"] as String,
    );
  }
}

class ModelSpecification extends Specification {
  final List<Field> fields;
  final List<Group> groups;
  final GenerateSpecification generate;
  final ListFields listFields;
  final String displayOnDelete; // field to be displayed when item is deleted
  // is this a appModel, i.e is this data that's specific to the app and hence will we have seperate specific collection for it?
  final bool isAppModel;

  // inject code
  // BEWARE: TO DO: CHANGE code injects and replace with same mechanism as "extraImports". This mechanism to inject code for extra import (key value pairs) allows to inject code much more efficient than using a specific property per inject type
  final String preToEntityCode;
  final String preMapUpdateCode;  // at start of _mapUpdateXYZListToState in XYZListBloc
  // BEWARE: BEFORE ADDING AN EXTRA, SEE ABOVE

  // views
  final List<View> views;

  static String IMPORT_KEY_FORM_BLOC = "form_bloc";
  static String IMPORT_KEY_MODEL = "model";
  static String IMPORT_KEY_FIRESTORE = "firestore";
  static String IMPORT_KEY_LIST_BLOC = "list_bloc";

  final Map<String, String> extraImports;
  final String where;
  final String whereJs;

  ModelSpecification({ String id, this.generate, this.fields, this.groups, this.listFields, this.displayOnDelete, this.extraImports, this.isAppModel, this.preToEntityCode, this.preMapUpdateCode, this.views, this.where, this.whereJs }) : super(id: id);

  ModelSpecification copyWith({ String id, GenerateSpecification generate, List<Field> fields, List<Group> groups,
    ListFields listFields, String displayOnDelete, Map<String, String> extraImports, bool isAppModel,
    String preToEntityCode, String preMapUpdateCode, List<View> views }) {
    ModelSpecification newModelSpecification = ModelSpecification(
      id: id ?? this.id,
      generate: generate ?? this.generate ,
      fields: fields ?? this.fields,
      groups: groups ?? this.groups,
      listFields: listFields ?? this.listFields,
      displayOnDelete: displayOnDelete ?? this.displayOnDelete,
      extraImports: extraImports ?? this.extraImports,
      isAppModel: isAppModel ?? this.isAppModel,
      preToEntityCode: preToEntityCode ?? this.preToEntityCode,
      preMapUpdateCode: preMapUpdateCode ?? this.preMapUpdateCode,
      views: views ?? this.views,
      where: where ?? this.where,
      whereJs: whereJs ?? this.whereJs,
    );
    return newModelSpecification;
  }


  Map<String, Object> toJson() {
    List<Map<String, dynamic>> jsonFields = fields != null
        ? fields.map((i) => i.toJson()).toList()
        : null;

    List<Map<String, dynamic>> jsonGroups = groups != null
        ? groups.map((i) => i.toJson()).toList()
        : null;

    List<Map<String, Object>> jsonViews = views != null
        ? views.map((view) => view.toJson()).toList()
        :null;

    return <String, dynamic>{
      "id": id,
      "generate": generate.toJson(),
      'fields': jsonFields,
      'groups': jsonGroups,
      'listFields': listFields.toJson(),
      "displayOnDelete": displayOnDelete,
      "extraImports": extraImports,
      "isAppModel": isAppModel,
      "preToEntityCode": preToEntityCode,
      "preMapUpdateCode": preMapUpdateCode,
      "alternativeViews": jsonViews,
      "where": where,
      "whereJs": whereJs
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [id, generate, fields, groups, displayOnDelete, extraImports, preToEntityCode, preMapUpdateCode, views, where, whereJs ];

  @override
  String toString() {
    return 'ModelSpecificationEntity { id: $id, requiresBloc: $generate, listFields: $listFields, displayOnDelete: $displayOnDelete, extraImports: $extraImports, isAppModel: $isAppModel, preToEntityCode: $preToEntityCode, preMapUpdateCode: $preMapUpdateCode views: $views, where: $where, whereJs: $whereJs }';
  }

  static ModelSpecification fromJson(Map<String, Object> json) {
    List<Field> theItems = (json['fields'] as List<dynamic>)
        .map((dynamic item) =>
        Field.fromJson(item as Map<String, dynamic>))
        .toList();

    List<Group> theGroups;
    var jsonGroups = json['groups'];
    if (jsonGroups != null) {
      theGroups = (jsonGroups as List<dynamic>)
          .map((dynamic item) =>
          Group.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<View> theViews;
    var jsonViews = json['alternativeViews'];
    if (jsonViews != null) {
      theViews = (jsonViews as List<dynamic>)
          .map((dynamic item) =>
          View.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    var myIsAppModel = json['isAppModel'];
    bool bIsAppModel = false;
    if (myIsAppModel != null) {
      bIsAppModel = myIsAppModel as bool;
    }

    var theListFields;
    var jsonListFields = json['listFields'];
    if (jsonListFields != null)
      theListFields = ListFields.fromJson(jsonListFields);

    Map<String, String> extraImports = Map();
    if (json['extraImports'] != null) {
      (json['extraImports'] as Map).forEach((k, v) {
        extraImports[k] = v;
      });

    }

    return ModelSpecification(
      id: json["id"] as String,
      generate: GenerateSpecification.fromJson(json["generate"]),
      fields: theItems,
      groups: theGroups,
      listFields: theListFields,
      displayOnDelete: json["displayOnDelete"] as String,
      extraImports: extraImports,
      isAppModel: bIsAppModel,
      preToEntityCode: json["preToEntityCode"] as String,
      preMapUpdateCode: json["preMapUpdateCode"] as String,
      views: theViews,
      where: json["where"] as String,
      whereJs: json["whereJs"] as String,
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
