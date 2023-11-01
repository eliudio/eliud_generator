import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/repository_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a repository based on a `spec` file
class RepositoryCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    //print("BBBAAAAAAAAAA");
    return  {
      '.spec': const ['_repository.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    //print("AAAAAAAAAA 1");
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    //print("AAAAAAAAAA 2");
    if (modelSpecification.generate.generateRepository) {
      //print("AAAAAAAAAA 3");
      RepositoryCodeGenerator repositoryCodeGenerator = RepositoryCodeGenerator(
          modelSpecifications: modelSpecification);
      //print("AAAAAAAAAA 4");
      return repositoryCodeGenerator;
    }
    return null;
  }
}
