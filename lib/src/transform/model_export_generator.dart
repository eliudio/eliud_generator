import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';
import 'package:eliud_generator/src/transform/export_generator.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class ModelExportGenerator extends ExportGenerator {
  ModelExportGenerator(String fileName): super(fileName: fileName, extension: 'model');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateModel);
  }
}
