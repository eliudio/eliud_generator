import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';
import 'package:eliud_generator/src/transform/repository_singleton_base_generator.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class RepositorySingletonCodeGenerator extends RepositorySingletonCodeBaseGenerator {
  RepositorySingletonCodeGenerator(String fileName): super(fileName, "", "");
}
