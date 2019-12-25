import 'package:build/build.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';

/// Abstract base class for eliud builders
abstract class CodeBuilder extends Builder {
  CodeGenerator generator(String specifications);

  Future<void> build(BuildStep buildStep) async {
    String extension = buildExtensions[".spec"].first;
    final AssetId output = buildStep.inputId.changeExtension(extension);
    final String jsonString = await buildStep.readAsString(buildStep.inputId);
    CodeGenerator codeGenerator = generator(jsonString);
    await buildStep.writeAsString(output, codeGenerator.getCode());
  }
}
