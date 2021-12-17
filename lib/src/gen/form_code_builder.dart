import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/form_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an form class based on a `spec` file
class FormCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_form.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateForm) {
      FormCodeGenerator formCodeGenerator = FormCodeGenerator(
          modelSpecifications: modelSpecification);
      return formCodeGenerator;
    }
    return null;
  }
}
