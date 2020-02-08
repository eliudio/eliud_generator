import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/dropdownbutton_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds an dropdown class based on a `spec` file
class DropdownButtonCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.dropdown_button.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateDropDownButton) {
      DropdownButtonCodeGenerator dropdownButtonCodeGenerator = DropdownButtonCodeGenerator(
          modelSpecifications: modelSpecification);
      return dropdownButtonCodeGenerator;
    }
  }
}
