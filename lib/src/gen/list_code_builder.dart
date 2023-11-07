import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/list_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an list class based on a `spec` file
class ListCodeBuilder extends CodeBuilder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.spec': const ['_list.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification =
        ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateList) {
      ListCodeGenerator listCodeGenerator =
          ListCodeGenerator(modelSpecifications: modelSpecification);
      return listCodeGenerator;
    }
    return null;
  }
}
