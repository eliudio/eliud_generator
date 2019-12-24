import 'package:build/build.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/model_code_generator.dart';

/// A build which which build the model based on a `spec` file
class SimpleBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => const <String, List<String>>{'.spec' : <String>['.dart']};

  @override
  Future<void> build(BuildStep buildStep) async {
    final AssetId output = buildStep.inputId.changeExtension('.dart');
    final String jsonString = await buildStep.readAsString(buildStep.inputId);
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(jsonString);
    ModelCodeGenerator modelCodeGenerator = ModelCodeGenerator(modelSpecifications: modelSpecification);
    await buildStep.writeAsString(output, modelCodeGenerator.getCode());
  }
}
