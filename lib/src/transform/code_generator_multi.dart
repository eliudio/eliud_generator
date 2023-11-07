import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';

abstract class CodeGeneratorMulti extends CodeGeneratorBase {
  final String fileName;

  CodeGeneratorMulti({required this.fileName});

  @override
  String theFileName() {
    return fileName;
  }

  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus);
}
