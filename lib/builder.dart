import 'package:build/build.dart';
import 'package:eliud_generator/src/model_generator.dart';
import 'package:eliud_generator/src/simple_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder model(BuilderOptions options) =>
    SharedPartBuilder([ModelGenerator()], 'model');

Builder simple(BuilderOptions options) =>
    SimpleBuilder();
