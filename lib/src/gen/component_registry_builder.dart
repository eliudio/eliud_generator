

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/component_registry_generator.dart';

import 'code_builder_multi.dart';

class ComponentRegistryBuilder extends CodeBuilderMulti {
  ComponentRegistryGenerator componentRegistryGenerator = ComponentRegistryGenerator(fileName);

  static const String fileName = 'model/component_registry.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return componentRegistryGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
