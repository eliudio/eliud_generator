import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/export_generator.dart';


class CacheExportGenerator extends ExportGenerator {
  CacheExportGenerator(String fileName): super(fileName: fileName, extension: 'cache');

  @override
  bool shouldGenerate(ModelSpecification spec) {
    return (spec.generate.generateCache);
  }
}
