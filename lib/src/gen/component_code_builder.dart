import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/component_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an component class based on a `spec` file
class ComponentCodeBuilder extends CodeBuilder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.spec': const ['_component.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification =
        ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateComponent) {
      ComponentCodeGenerator componentCodeGenerator =
          ComponentCodeGenerator(modelSpecifications: modelSpecification);
      return componentCodeGenerator;
    }
    return null;
  }
}
