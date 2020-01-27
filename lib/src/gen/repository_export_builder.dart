

import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:eliud_generator/src/transform/repository_export_generator.dart';

import 'code_builder_multi.dart';

class RepositoryExportBuilder extends CodeBuilderMulti {
  RepositoryExportGenerator repositoryExportGenerator = RepositoryExportGenerator(fileName);

  static const String fileName = 'shared/repository_export.dart';

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const [ fileName ],
    };
  }

  @override
  CodeGeneratorMulti generator() {
    return repositoryExportGenerator;
  }

  @override
  String getFileName() {
    return fileName;
  }
}
