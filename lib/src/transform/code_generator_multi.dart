import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';
import 'package:json_schema/json_schema.dart';

abstract class CodeGeneratorMulti extends CodeGeneratorBase {
  final String fileName;

  CodeGeneratorMulti({ this.fileName });

  @override
  String theFileName() {
    return fileName;
  }

  String getCode(List<ModelSpecification> modelSpecifications);
}
