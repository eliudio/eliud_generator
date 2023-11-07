import 'dart:async';

import 'package:build/build.dart';

import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

abstract class CodeBuilderMulti implements Builder {
  static final _allFilesInLib = Glob('lib/**.spec');

  static AssetId _allFileOutput(String fileName, BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      p.join('lib', fileName),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    List<ModelSpecificationPlus> specifications = <ModelSpecificationPlus>[];
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      String path = input.path.substring(4).replaceAll(".spec", "");
      final String jsonString = await buildStep.readAsString(input);
      specifications.add(ModelSpecificationPlus(
          modelSpecification: ModelSpecification.fromJsonString(jsonString),
          path: path));
    }
    CodeGeneratorMulti codeGenerator = generator();
    String theCode = codeGenerator.getCode(specifications);
    final output = _allFileOutput(getFileName(), buildStep);
    return buildStep.writeAsString(output, theCode);
  }

  CodeGeneratorMulti generator();

  String getFileName();
}
