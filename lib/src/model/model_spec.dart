import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';
import 'gen_spec.dart';
import 'group.dart';
import 'list_fields.dart';

class ModelSpecificationPlus {
  final ModelSpecification modelSpecification;
  final String path;

  ModelSpecificationPlus({required this.modelSpecification, required this.path});
}

class View {
  final String? title;
  final String? buttonLabel;
  final String name;
  final List<String>? fields;
  final List<String>? groups;

  View({required this.name, this.fields, this.groups, required this.title, required this.buttonLabel});

  static View fromJson(Map<String, dynamic> json) {
    var jsonFields = json["fields"];
    var jsonGroups = json["groups"];
    return View(
      name: json["name"] as String,
      fields: jsonFields != null ? List.from(jsonFields as Iterable) : null,
      groups: jsonGroups != null ? List.from(jsonGroups as Iterable) : null,
      title: json["title"] as String?,
      buttonLabel: json["buttonLabel"] as String?,
    );
  }
}

class ModelSpecification extends Specification {
  final String packageName;
  final String packageFriendlyName;
  final List<Field> fields;
  final List<Group>? groups;
  final GenerateSpecification generate;
  final ListFields? listFields;
  final String? displayOnDelete; // field to be displayed when item is deleted
  // is this a appModel, i.e is this data that's specific to the app and hence will we have seperate specific collection for it?
  final bool? isAppModel;
  final String? memberIdentifier;  // This field serves 2 purpose: a) to identify this is member data, which is required to know for gdpr to be able to send member data or delete (right to be forgotten) on request  b) to know which field to use to filter that data

  // inject code
  // BEWARE: TO DO: CHANGE code injects and replace with same mechanism as "extraImports". This mechanism to inject code for extra import (key value pairs) allows to inject code much more efficient than using a specific property per inject type
  final String? preToEntityCode;
  final String? preMapUpdateCode; // at start of _mapUpdateXYZListToState in XYZListBloc
  // BEWARE: BEFORE ADDING AN EXTRA, SEE ABOVE

  // views
  final List<View>? views;

  // depending plugins
  final List<String>? depends;

  final String? codeToExtractData; // extra code to extra data, for example to extract the image. This is used to fully serialise the document, including the image
  final String? codeForNewAppId;   // extra code to adjust entity with new appId
  final String? codeToCollectReferences; // extra code to extract extra references, e.g. if that relationship isn't defined in the spec

  bool getIsAppModel() {
    if (isAppModel == null) return false;
    return isAppModel!;
  }

  List<Group> getGroups() {
    if (groups == null) return [];
    return groups!;
  }

  String getDisplayOnDelete() {
    if (displayOnDelete == null) return "documentID";
    return displayOnDelete!;
  }

  String getMemberIdentifier() {
    if (memberIdentifier == null) return "";
    return memberIdentifier!;
  }

  String getPreToEntityCode() {
    if (preToEntityCode == null) return "";
    return preToEntityCode!;
  }

  String getPreMapUpdateCode() {
    if (preMapUpdateCode == null) return "";
    return preMapUpdateCode!;
  }

  static String IMPORT_KEY_FORM_BLOC = "form_bloc";
  static String IMPORT_KEY_MODEL = "model";
  static String IMPORT_KEY_ENTITY = "entity";
  static String IMPORT_KEY_FIRESTORE = "firestore";
  static String IMPORT_KEY_JS_FIRESTORE = "js_firestore";
  static String IMPORT_KEY_REPOSITORY = "repository";
  static String IMPORT_KEY_LIST_BLOC = "list_bloc";
  static String IMPORT_KEY_FORM = "form";

  final Map<String, String> extraImports;
  final String? where;
  final String? whereJs;

  ModelSpecification(
      {required String id,
        required this.generate,
        required this.packageName,
        required this.packageFriendlyName,
        required this.fields,
        required this.groups,
        required this.listFields,
        required this.displayOnDelete,
        required this.extraImports,
        required this.isAppModel,
        required this.preToEntityCode,
        required this.preMapUpdateCode,
        required this.views,
        required this.where,
        required this.whereJs,
        required this.depends,
        required this.memberIdentifier,
        required this.codeToExtractData,
        required this.codeForNewAppId,
        required this.codeToCollectReferences})
      : super(id: id, );

  ModelSpecification copyWith(
      {String? id,
        String ? friendlyName,
      GenerateSpecification? generate,
      List<Field>? fields,
      List<Group>? groups,
      ListFields? listFields,
      String? displayOnDelete,
      Map<String, String>? extraImports,
      bool? isAppModel,
      String? preToEntityCode,
      String? preMapUpdateCode,
      List<View>? views,
      List<View>? listWidgets,
      List<String>? depends,
      bool? isMemberModel,
      String? memberIdentifier,
      String ? codeToExtractData,
      String? codeToCollectReferences,}) {
    ModelSpecification newModelSpecification = ModelSpecification(
      id: id ?? this.id,
      generate: generate ?? this.generate,
      packageName: packageName,
      packageFriendlyName: packageFriendlyName,
      fields: fields ?? this.fields,
      groups: groups ?? this.groups,
      listFields: listFields ?? this.listFields,
      displayOnDelete: displayOnDelete ?? this.displayOnDelete,
      extraImports: extraImports ?? this.extraImports,
      isAppModel: isAppModel ?? this.isAppModel,
      preToEntityCode: preToEntityCode ?? this.preToEntityCode,
      preMapUpdateCode: preMapUpdateCode ?? this.preMapUpdateCode,
      views: views ?? this.views,
      where: where,
      whereJs: whereJs,
      depends: depends ?? this.depends,
      memberIdentifier: memberIdentifier ?? this.memberIdentifier,
      codeToExtractData: codeToExtractData ?? this.codeToExtractData,
      codeForNewAppId: codeForNewAppId ?? this.codeForNewAppId,
      codeToCollectReferences: codeToCollectReferences ?? this.codeToCollectReferences,
    );
    return newModelSpecification;
  }

  @override
  String toString() {
    return 'ModelSpecificationEntity { id: $id, requiresBloc: $generate, packageName: $packageName, listFields: $listFields, displayOnDelete: $displayOnDelete, extraImports: $extraImports, isAppModel: $isAppModel, preToEntityCode: $preToEntityCode, preMapUpdateCode: $preMapUpdateCode views: $views,  where: $where, whereJs: $whereJs, depends: $depends,  memberIdentifier: $memberIdentifier }';
  }

  static ModelSpecification fromJson(Map<String, dynamic> json) {
    print("fromJson Step 1");
    List<Field> theItems = (json['fields'] as List<dynamic>)
        .map((dynamic item) => Field.fromJson(item as Map<String, dynamic>))
        .toList();

    print("fromJson Step 2");
    List<Group>? theGroups;
    var jsonGroups = json['groups'];
    if (jsonGroups != null) {
      theGroups = (jsonGroups as List<dynamic>)
          .map((dynamic item) => Group.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    print("fromJson Step 3");
    List<View>? theViews;
    var jsonViews = json['alternativeViews'];
    if (jsonViews != null) {
      theViews = (jsonViews as List<dynamic>)
          .map((dynamic item) => View.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    print("fromJson Step 4");
    var myIsAppModel = json['isAppModel'];
    bool bIsAppModel = false;
    if (myIsAppModel != null) {
      bIsAppModel = myIsAppModel as bool;
    }

    print("fromJson Step 5");
    ListFields? theListFields;
    var jsonListFields = json['listFields'];
    if (jsonListFields != null)
      theListFields = ListFields.fromJson(jsonListFields as Map<String, dynamic>);

    print("fromJson Step 6");
    Map<String, String> extraImports = Map();
    if (json['extraImports'] != null) {
      (json['extraImports'] as Map).forEach((k, v) {
        extraImports[k] = v;
      });
    }

    var dependsFields = json["depends"];

    print("fromJson Step 7");

    id: json["id"] as String;
    print("fromJson Step 7 b");
    packageName: json["packageName"] as String;
    print("fromJson Step 7 c");
    packageFriendlyName: json["packageFriendlyName"] as String;
    print("fromJson Step 7 j");

    var modelSpecification = ModelSpecification(
      id: json["id"] as String,
      generate: GenerateSpecification.fromJson(json["generate"] as Map<String, dynamic> ),
      packageName: json["packageName"] as String,
      packageFriendlyName: json["packageFriendlyName"] as String,
      fields: theItems,
      groups: theGroups,
      listFields: theListFields,
      displayOnDelete: json["displayOnDelete"] as String?,
      extraImports: extraImports,
      isAppModel: bIsAppModel,
      preToEntityCode: json["preToEntityCode"] as String?,
      preMapUpdateCode: json["preMapUpdateCode"] as String?,
      views: theViews,
      where: json["where"] as String?,
      whereJs: json["whereJs"] as String?,
      depends: dependsFields != null ? List.from(dependsFields  as Iterable) : null,
      memberIdentifier: json["memberIdentifier"] as String?,
      codeToExtractData: json["codeToExtractData"] as String?,
      codeForNewAppId: json["codeForNewAppId"] as String?,
      codeToCollectReferences: json["codeToCollectReferences"] as String?,
    );
    print("fromJson Step 8");
    return modelSpecification;
  }

  static ModelSpecification fromJsonString(String json) {
    print("fromJsonString 1");
    Map<String, dynamic> modelSpecificationMap = jsonDecode(json);
    print("fromJsonString 2");
    return fromJson(modelSpecificationMap);
  }

  List<String> uniqueAssociationTypes() {
    List<String> uniqueAssociationTypes = [];
    fields.forEach((field) {
      if (field.isAssociation()) {
        String typeName = field.fieldType;
        if (!uniqueAssociationTypes.contains(typeName)) {
          uniqueAssociationTypes.add(typeName);
        }
      }
    });
    return uniqueAssociationTypes;
  }

  List<Field> fieldsForGroups(Group group) {
    final List<Field> thoseFields = [];
    fields.forEach((field) {
      if (field.group == group.group) thoseFields.add(field);
    });
    return thoseFields;
  }

  bool _exists(String groupId) {
    if (groups == null) return false;
    for (var group in groups!) {
      if (group.group == groupId) return true;
    }
    return false;
  }

  bool hasUngroupedFields() {
    return (unGroupedFields().length > 0);
  }

  List<Field> unGroupedFields() {
    final List<Field> thoseFields = [];
    fields.forEach((field) {
      if (field.group == null)
        thoseFields.add(field);
      else if (!_exists(field.getGroup())) thoseFields.add(field);
    });
    return thoseFields;
  }

  bool isMemberSpecific() {
    if (id == "Member") return true;
    if (id == "Post") return true;
    return false;
  }
}
