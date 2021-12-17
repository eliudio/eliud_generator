import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/cache_code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/entity_code_generator.dart';
import 'package:eliud_generator/src/transform/repository_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a cache based on a `spec` file
class CacheCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_cache.dart'],
    };
  }

  @override
  CodeGenerator? generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateCache) {
      CacheCodeGenerator cacheCodeGenerator = CacheCodeGenerator(
          modelSpecifications: modelSpecification);
      return cacheCodeGenerator;
    }
    return null;
  }
}
