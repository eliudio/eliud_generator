import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/form_event_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an event class based on a `spec` file
class FormEventCodeBuilder extends CodeBuilder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.spec': const ['_form_event.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification =
        ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateForm) {
      FormEventCodeGenerator eventCodeGenerator =
          FormEventCodeGenerator(modelSpecifications: modelSpecification);
      return eventCodeGenerator;
    }
    return null;
  }
}
