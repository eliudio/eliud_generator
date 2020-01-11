import 'dart:convert';

import 'package:eliud_generator/src/model/spec.dart';

import 'field.dart';

class GenerateSpecification {
  final bool generateComponent;
  final bool generateBloc;
  final bool generateRepository;
  final bool generateModel;
  final bool generateEntity;
  final bool generateForm;
  final bool generateList;

  GenerateSpecification({ this.generateComponent, this.generateBloc, this.generateRepository, this.generateModel, this.generateEntity, this.generateForm, this.generateList});

  Map<String, Object> toJson() {
    return <String, dynamic>{
      "generateComponent": generateComponent,
      "generateBloc": generateBloc,
      "generateRepository": generateRepository,
      "generateModel": generateModel,
      "generateEntity": generateEntity,
      "generateForm": generateForm,
      "generateList": generateList,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [generateComponent, generateBloc, generateRepository, generateModel, generateEntity, generateForm, generateList];

  @override
  String toString() {
    return 'GenerateSpecification { generateComponent: $generateComponent, generateBloc: $generateBloc, generateRepository: $generateRepository, generateModel: $generateModel, generateEntity: $generateEntity, generateForm: $generateForm, generateList: $generateList }';
  }

  static GenerateSpecification fromJson(Map<String, Object> json) {
    return GenerateSpecification(
      generateComponent: json["generateComponent"] as bool,
      generateBloc: json["generateBloc"] as bool,
      generateRepository: json["generateRepository"] as bool,
      generateModel: json["generateModel"] as bool,
      generateEntity: json["generateEntity"] as bool,
      generateForm: json["generateForm"] as bool,
      generateList: json["generateList"] as bool,
    );
  }

  static GenerateSpecification fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
