import 'package:eliud_generator/src/model/model_spec.dart';

import 'export_generator.dart';

class EntityExportGenerator extends ExportGenerator {
  EntityExportGenerator(String fileName): super(fileName: fileName, extension: 'entity');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateEntity);
  }
}
