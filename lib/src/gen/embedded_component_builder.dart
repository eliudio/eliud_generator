

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/embedded_component_generator.dart';
import 'package:eliud_generator/src/transform/internal_component_generator.dart';

import 'code_builder_multi.dart';

class EmbeddedComponentBuilder extends CodeBuilderMulti {
  EmbeddedComponentCodeGenerator embeddedComponentCodeGenerator = EmbeddedComponentCodeGenerator(fileName);

  static const String fileName = 'shared/embedded_component.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return embeddedComponentCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
