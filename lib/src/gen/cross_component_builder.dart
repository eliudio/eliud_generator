

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/cross_component_generator.dart';
import 'package:eliud_generator/src/transform/internal_component_generator.dart';

import 'code_builder_multi.dart';

class CrossComponentBuilder extends CodeBuilderMulti {
  CrossComponentCodeGenerator crossComponentCodeGenerator = CrossComponentCodeGenerator(fileName);

  static const String fileName = 'model/cross_component.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return crossComponentCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
