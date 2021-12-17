import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/model_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a model based on a `spec` file
class ModelCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_model.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    ModelCodeGenerator modelCodeGenerator = ModelCodeGenerator(modelSpecifications: modelSpecification);
    return modelCodeGenerator;
  }
}
