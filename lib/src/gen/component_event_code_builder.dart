import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/component_event_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an event class based on a `spec` file
class ComponentEventCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_component_event.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateComponent) {
      ComponentEventCodeGenerator eventCodeGenerator = ComponentEventCodeGenerator(
          modelSpecifications: modelSpecification);

      return eventCodeGenerator;
    }
    return null;
  }
}
