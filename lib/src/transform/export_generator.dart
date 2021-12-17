import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

abstract class ExportGenerator extends CodeGeneratorMulti {
  String extension;

  ExportGenerator({required String fileName, required this.extension}): super(fileName: fileName);

  bool shouldGenerate(ModelSpecification spec);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (shouldGenerate(spec.modelSpecification)) {
        codeBuffer.writeln("export '../" + path + "_" + extension + ".dart';");
      }
    });
    return codeBuffer.toString();

  }
}
