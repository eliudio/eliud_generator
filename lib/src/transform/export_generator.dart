import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator_multi.dart';

abstract class ExportGenerator extends CodeGeneratorMulti {
  String extension;

  ExportGenerator({required super.fileName, required this.extension});

  bool shouldGenerate(ModelSpecification spec);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    for (var spec in modelSpecificationPlus) {
      String path = spec.path;
      if (shouldGenerate(spec.modelSpecification)) {
        codeBuffer.writeln("export '../${path}_$extension.dart';");
      }
    }
    return codeBuffer.toString();
  }
}
