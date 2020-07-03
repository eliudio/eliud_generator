import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/form_state_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an state class based on a `spec` file
class FormStateCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_form_state.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    print("FormStateCodeBuilder");
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateForm) {
      FormStateCodeGenerator stateCodeGenerator = FormStateCodeGenerator(
          modelSpecifications: modelSpecification);
      return stateCodeGenerator;
    }
  }
}
