import 'package:build/build.dart';
import 'package:eliud_generator/src/eliud_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder eliud(BuilderOptions options) =>
    SharedPartBuilder([EliudGenerator()], 'eliud');
