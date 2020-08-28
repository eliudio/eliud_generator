

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/entity_export_generator.dart';
import 'package:eliud_generator/src/transform/model_export_generator.dart';
import 'package:eliud_generator/src/transform/repository_export_generator.dart';

import 'code_builder_multi.dart';

class EntityExportBuilder extends CodeBuilderMulti {
  EntityExportGenerator entityExportGenerator = EntityExportGenerator(fileName);

  static const String fileName = 'model/entity_export.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return entityExportGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
