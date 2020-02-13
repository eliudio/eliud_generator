import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';

class GenerateSpecification {
  final bool generateComponent;       // includes bloc, state and event
  final bool generateRepository;
  final bool generateCache;
  final bool generateFirestoreRepository;
  final bool generateModel;
  final bool generateEntity;
  final bool generateForm;              // includes bloc, state and event
  final bool generateList;              // includes bloc, state and event
  final bool generateDropDownButton;
  final bool generateInternalComponent; // generate an administrative component
  final bool generateEmbeddedComponent; // is this an embedded internal component?
  final bool isExtension;               // is this an extension, is this a component that can be added to a page

  GenerateSpecification({ this.generateComponent, this.generateRepository, this.generateCache,
    this.generateFirestoreRepository, this.generateModel, this.generateEntity,
    this.generateForm, this.generateList, this.generateDropDownButton, this.generateInternalComponent,
    this.generateEmbeddedComponent, this.isExtension
  });

  Map<String, Object> toJson() {
    return <String, dynamic>{
      "generateComponent": generateComponent,
      "generateRepository": generateRepository,
      "generateCache": generateCache,
      "generateFirestoreRepository": generateFirestoreRepository,
      "generateModel": generateModel,
      "generateEntity": generateEntity,
      "generateForm": generateForm,
      "generateList": generateList,
      "generateDropDownButton": generateDropDownButton,
      "generateInternalComponent": generateInternalComponent,
      "generateEmbeddedComponent": generateEmbeddedComponent,
      "isExtension": isExtension,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [generateComponent, generateRepository, generateCache, generateFirestoreRepository, generateModel,
    generateEntity, generateForm, generateList, generateDropDownButton, generateInternalComponent, generateEmbeddedComponent, isExtension];

  @override
  String toString() {
    return 'GenerateSpecification { generateComponent: $generateComponent, generateRepository: $generateCache: generateCache, $generateRepository, generateFirestoreRepository: $generateFirestoreRepository, generateModel: $generateModel, generateEntity: $generateEntity, generateForm: $generateForm, generateList: $generateList, generateDropDownButton: $generateDropDownButton, generateInternalComponent: $generateInternalComponent, generateEmbeddedComponent: $generateEmbeddedComponent, isExtension:$isExtension }';
  }

  static GenerateSpecification fromJson(Map<String, Object> json) {
    return GenerateSpecification(
      generateComponent: json["generateComponent"] as bool ?? false,
      generateRepository: json["generateRepository"] as bool ?? false,
      generateCache: json["generateCache"] as bool ?? false,
      generateFirestoreRepository: json["generateFirestoreRepository"] as bool ?? false,
      generateModel: json["generateModel"] as bool ?? false,
      generateEntity: json["generateEntity"] as bool ?? false,
      generateForm: json["generateForm"] as bool ?? false,
      generateList: json["generateList"] as bool ?? false,
      generateDropDownButton: json["generateDropDownButton"] as bool ?? false,
      generateInternalComponent: json["generateInternalComponent"] as bool ?? false,
      generateEmbeddedComponent: json["generateEmbeddedComponent"] as bool ?? false,
      isExtension: json["isExtension"] as bool ?? false,
    );
  }

  static GenerateSpecification fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
