import 'dart:io';

import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/model_code_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/vm.dart';

void main() {
  test('?', ()  async {
    List<Field> fields = List();
    fields.add(Field(fieldName: "id", array: false, fieldType: "String"));
    fields.add(Field(fieldName: "menuItems", array: true, fieldType: "MenuItem"));
    ModelSpecification modelSpecifications = ModelSpecification(id: "Menu", fields: fields);
    print(modelSpecifications.toJsonString());
    ModelCodeGenerator modelCodeGenerator = ModelCodeGenerator(modelSpecifications: modelSpecifications);
    print(modelCodeGenerator.getCode());
    expect(1, 1);
  });
}
