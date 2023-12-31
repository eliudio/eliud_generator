import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/form_bloc_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a bloc based on a `spec` file
class FormBlocCodeBuilder extends CodeBuilder {
  @override
  Map<String, List<String>> get buildExtensions {
    return {
      '.spec': const ['_form_bloc.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification =
        ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateForm) {
      FormBlocCodeGenerator repositoryCodeGenerator =
          FormBlocCodeGenerator(modelSpecifications: modelSpecification);
      return repositoryCodeGenerator;
    }
    return null;
  }
}
