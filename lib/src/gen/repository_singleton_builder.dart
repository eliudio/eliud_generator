import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/repository_singleton_generator.dart';

import 'code_builder_multi.dart';

class RepositorySingletonBuilder extends CodeBuilderMulti {
  RepositorySingletonCodeGenerator repositorySingletonCodeGenerator =
      RepositorySingletonCodeGenerator(fileName);

  static const String fileName = 'model/repository_singleton.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': [fileName],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return repositorySingletonCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
