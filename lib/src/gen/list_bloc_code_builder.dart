import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/list_bloc_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a bloc based on a `spec` file
class ListBlocCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_list_bloc.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateList) {
      ListBlocCodeGenerator repositoryCodeGenerator = ListBlocCodeGenerator(
          modelSpecifications: modelSpecification);
      return repositoryCodeGenerator;
    }

  }
}
