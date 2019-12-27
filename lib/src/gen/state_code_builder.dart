import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/state_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an state class based on a `spec` file
class StateCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.state.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.requiresBLoC) {
      StateCodeGenerator stateCodeGenerator = StateCodeGenerator(
          modelSpecifications: modelSpecification);
      return stateCodeGenerator;
    }
  }
}
