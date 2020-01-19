import 'dart:io';

import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/firestore_code_generator.dart';
import 'package:eliud_generator/src/transform/model_code_generator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/vm.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  var file = File('C:\src\eliud\eliud_model\lib\model\menu.spec');
  var contents;

  if (await file.exists()) {
    contents = await file.readAsString();
    print(contents);

    ModelSpecification modelSpecifications = ModelSpecification.fromJsonString(
        contents);
  }
}