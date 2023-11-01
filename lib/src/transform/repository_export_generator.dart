import 'package:eliud_generator/src/model/model_spec.dart';

import 'export_generator.dart';

class RepositoryExportGenerator extends ExportGenerator {
  RepositoryExportGenerator(String fileName)
      : super(fileName: fileName, extension: 'repository');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateRepository);
  }
}
