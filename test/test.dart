import 'dart:io';

import 'package:eliud_generator/src/transform/json_to_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';
import 'package:json_schema/vm.dart';

void main() {
  test('?', ()  async {
    configureJsonSchemaForVm();
    File file = File('test/test.spec');
    String contents = await file.readAsString();
    final schema = await JsonSchema.createSchema(contents);
    JsonToModel jsonToModel = JsonToModel(className: "Menu", schema: schema);
    print(jsonToModel.getCode());
    expect(1, 1);
  });
}
