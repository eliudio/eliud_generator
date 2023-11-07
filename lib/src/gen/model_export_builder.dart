import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/model_export_generator.dart';

import 'code_builder_multi.dart';

class ModelExportBuilder extends CodeBuilderMulti {
  ModelExportGenerator modelExportGenerator = ModelExportGenerator(fileName);

  static const String fileName = 'model/model_export.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': [fileName],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return modelExportGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
