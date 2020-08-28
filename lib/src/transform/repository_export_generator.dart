import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';
import 'export_generator.dart';

class RepositoryExportGenerator extends ExportGenerator {
  RepositoryExportGenerator(String fileName)
      : super(fileName: fileName, extension: 'repository');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateRepository);
  }
}
