import 'dart:async';

import 'package:build/build.dart';

import 'package:build/build.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

abstract class CodeBuilderMulti implements Builder {
  static final _allFilesInLib = new Glob('lib/**.spec');

  static AssetId _allFileOutput(BuildStep buildStep) {
    return new AssetId(
      buildStep.inputId.package,
      p.join('lib', 'all_files.txt'),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': const ['all_files.txt'],
    };
  }

  @override
  Future<void> build(BuildStep buildStep) async {
    final files = <String>[];
    List<String> specifications;
    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      files.add(input.path);
      final String jsonString = await buildStep.readAsString(input);
      specifications.add(jsonString);
    }
    final output = _allFileOutput(buildStep);
    return buildStep.writeAsString(output, specifications.join('\n'));
  }

  CodeGenerator generator(List<String> specifications);
}
