import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/admin_app_code_generator.dart';
import 'package:eliud_generator/src/transform/cache_code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/repository_code_generator.dart';
import 'package:eliud_generator/src/transform/repository_singleton_generator.dart';

import 'code_builder.dart';
import 'code_builder_multi.dart';

/// A builder which builds the admin app / pages / menu based on a `spec` file
class AdminAppBuilder extends CodeBuilderMulti {
  AdminAppCodeGenerator adminAppCodeGenerator = AdminAppCodeGenerator(fileName);

  static const String fileName = 'model/admin_app.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return adminAppCodeGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
