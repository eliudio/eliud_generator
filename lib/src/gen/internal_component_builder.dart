import 'dart:async';

import 'package:build/build.dart';

import 'package:build/build.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/internal_component_generator.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

import 'code_builder_multi.dart';

class InternalComponentBuilder extends CodeBuilderMulti {
  InternalComponentCodeGenerator internalComponentCodeGenerator = InternalComponentCodeGenerator(fileName);

  static const String fileName = 'shared/internal_component.dart';

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
