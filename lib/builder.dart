import 'package:build/build.dart';
import 'file:///C:/src/eliud/eliud_generator/lib/src/gen/model_generator.dart';
import 'file:///C:/src/eliud/eliud_generator/lib/src/gen/simple_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder model(BuilderOptions options) =>
    SharedPartBuilder([ModelGenerator()], 'model');

Builder simple(BuilderOptions options) =>
    SimpleBuilder();
