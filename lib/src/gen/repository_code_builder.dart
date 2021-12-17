import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/repository_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a repository based on a `spec` file
class RepositoryCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_repository.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateRepository) {
      RepositoryCodeGenerator repositoryCodeGenerator = RepositoryCodeGenerator(
          modelSpecifications: modelSpecification);
      return repositoryCodeGenerator;
    }
    return null;
  }
}
