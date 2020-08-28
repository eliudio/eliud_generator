

import 'package:eliud_generator/src/transform/cache_export_generator.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';

import 'code_builder_multi.dart';

class CacheExportBuilder extends CodeBuilderMulti {
  CacheExportGenerator cacheExportGenerator = CacheExportGenerator(fileName);

  static const String fileName = 'model/cache_export.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return cacheExportGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
