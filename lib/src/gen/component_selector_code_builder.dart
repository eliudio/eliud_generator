import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/component_selector_code_generator.dart';
import 'package:eliud_generator/src/transform/dropdownbutton_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a selector class based on a `spec` file
class ComponentSelectorCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_component_selector.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateComponent) {
      ComponentSelectorCodeGenerator componentSelectorCodeGenerator = ComponentSelectorCodeGenerator(
          modelSpecifications: modelSpecification);
      return componentSelectorCodeGenerator;
    }
    return null;
  }
}
