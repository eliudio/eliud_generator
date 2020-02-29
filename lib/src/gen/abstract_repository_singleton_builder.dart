

import 'package:eliud_generator/src/transform/abstract_repository_singleton_generator.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/internal_component_generator.dart';
import 'package:eliud_generator/src/transform/repository_singleton_generator.dart';

import 'code_builder_multi.dart';

class AbstractRepositorySingletonBuilder extends CodeBuilderMulti {
  AbstractRepositorySingletonCodeGenerator abstractRepositorySingletonCodeGenerator = AbstractRepositorySingletonCodeGenerator(fileName);

  static const String fileName = 'shared/abstract_repository_singleton.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return abstractRepositorySingletonCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}