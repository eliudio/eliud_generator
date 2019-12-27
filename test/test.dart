import 'dart:io';

import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/firestore_code_generator.dart';
import 'package:eliud_generator/src/transform/model_code_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/vm.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File('$path/test/application.spec');
}

String jsonString() {
  return
      '{'+
      '  \"id\": \"Application\",'+
      '  \"requiresBLoC\": true,'+
      '  \"fields\": ['+
      '    {'+
      '      \"fieldName\": \"id\",'+
      '      \"fieldType\": \"String\"'+
      '    },'+
      '    {'+
      '      \"fieldName\": \"title\",'+
      '      \"fieldType\": \"String\"'+
      '    },'+
      '    {'+
      '      \"fieldName\": \"description\",'+
      '      \"fieldType\": \"String\"'+
      '    },'+
      '    {'+
      '      \"fieldName\": \"entryPageId\",'+
      '      \"fieldType\": \"String\"'+
      '    },'+
      '    {'+
      '      \"fieldName\": \"authenticationRequirement\",'+
      '      \"fieldType\": \"enum\",'+
      '      \"enumName\": \"AuthenticationRequirement\",'+
      '      \"enumValues\" : [ \"LoginRequired\", \"LoginOptional\", \"NoLogin\" ]'+
      '    },'+
      '    {'+
      '      \"fieldName\": \"logo\",'+
      '      \"fieldType\": \"Image\",'+
      '      \"association\": true'+
      '    }'+
      '  ]'+
      '}';
}

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();

  test('coded config', ()  async {
    List<Field> fields = List();
    fields.add(Field(fieldName: "id", fieldType: "String"));
    fields.add(Field(fieldName: "menuItems", array: true, fieldType: "MenuItem"));
    List<String> values = List();
    values.add("EnumValue1");
    values.add("EnumValue2");
    values.add("EnumValue3");
    fields.add(Field(fieldName: "myValue", enumName: "MyEnum", enumValues: values, fieldType: "enum"));
    ModelSpecification modelSpecifications = ModelSpecification(id: "Menu", fields: fields);
    print(modelSpecifications.toJsonString());
    print(ModelCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    print(EntityCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    print(FirestoreCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    expect(1, 1);
  });

  test('application', ()  async {
    ModelSpecification modelSpecifications = ModelSpecification.fromJsonString(jsonString());
    print(modelSpecifications.toJsonString());
    print(ModelCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    print(EntityCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    print(FirestoreCodeGenerator(modelSpecifications: modelSpecifications).getCode());
    expect(1, 1);
  });
}
