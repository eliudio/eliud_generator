import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';
import 'export_generator.dart';

class EntityExportGenerator extends ExportGenerator {
  EntityExportGenerator(String fileName): super(fileName: fileName, extension: 'entity');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateEntity);
  }
}
