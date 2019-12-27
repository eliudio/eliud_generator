import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/bloc_code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a bloc based on a `spec` file
class BlocCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.bloc.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.requiresBLoC) {
      BlocCodeGenerator repositoryCodeGenerator = BlocCodeGenerator(
          modelSpecifications: modelSpecification);
      return repositoryCodeGenerator;
    }
  }
}
