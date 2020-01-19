import 'dart:async';

import 'package:build/build.dart';

import 'package:build/build.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/code_generator_multi.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

abstract class CodeBuilderMulti implements Builder {
  static final _allFilesInLib = new Glob('lib/**.spec');

  static AssetId _allFileOutput(String fileName, BuildStep buildStep) {
    return new AssetId(
      buildStep.inputId.package,
      p.join('lib', fileName),
    );
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final files = <String>[];
    List<String> specifications = List();
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      files.add(input.path);
      final String jsonString = await buildStep.readAsString(input);
      specifications.add(jsonString);
    }
    List<ModelSpecification> modelSpecifications = specifications.map((spec) =>
        ModelSpecification.fromJsonString(spec)).toList();

    CodeGeneratorMulti codeGenerator = generator();
    String theCode = codeGenerator.getCode(modelSpecifications);
    final output = _allFileOutput(getFileName(), buildStep);
    return buildStep.writeAsString(output, theCode);
  }

  CodeGeneratorMulti generator();

  String getFileName();
}
