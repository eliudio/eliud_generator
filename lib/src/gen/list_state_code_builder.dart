import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/list_state_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an state class based on a `spec` file
class ListStateCodeBuilder extends CodeBuilder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.spec': const ['_list_state.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification =
        ModelSpecification.fromJsonString(specifications);
    if ((modelSpecification.generate.generateList) ||
        (modelSpecification.generate.generateDropDownButton) ||
        (modelSpecification.generate.generateComponent)) {
      ListStateCodeGenerator stateCodeGenerator =
          ListStateCodeGenerator(modelSpecifications: modelSpecification);
      return stateCodeGenerator;
    }
    return null;
  }
}
