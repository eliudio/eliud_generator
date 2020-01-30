import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class RepositoryExportGenerator extends CodeGeneratorMulti {
  RepositoryExportGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateFirestoreRepository) {
        codeBuffer.writeln("export '../" + path + ".firestore.dart';");
      }
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("export '../" + path + ".repository.dart';");
      }
    });
    codeBuffer.writeln("export '../shared/image.firestore.bespoke.dart';");
    return codeBuffer.toString();

  }
}
