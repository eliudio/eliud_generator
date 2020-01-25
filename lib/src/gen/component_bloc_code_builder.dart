import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/component_bloc_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a bloc based on a `spec` file
class ComponentBlocCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.component.bloc.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateComponent) {
      ComponentBlocCodeGenerator repositoryCodeGenerator = ComponentBlocCodeGenerator(
          modelSpecifications: modelSpecification);
      return repositoryCodeGenerator;
    }
  }
}
