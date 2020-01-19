import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class InternalComponentCodeGenerator extends CodeGeneratorMulti {
  InternalComponentCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecification> modelSpecifications) {
    return fileName + " .... " + modelSpecifications.map((spec) => spec.id).toList().join(" | ");
  }
}
