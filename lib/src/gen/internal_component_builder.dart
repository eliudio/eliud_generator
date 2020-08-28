

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/internal_component_generator.dart';

import 'code_builder_multi.dart';

class InternalComponentBuilder extends CodeBuilderMulti {
  InternalComponentCodeGenerator internalComponentCodeGenerator = InternalComponentCodeGenerator(fileName);

  static const String fileName = 'model/internal_component.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return internalComponentCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
