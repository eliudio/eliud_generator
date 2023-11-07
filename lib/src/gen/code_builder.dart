import 'package:build/build.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';

/// Abstract base class for eliud builders
abstract class CodeBuilder extends Builder {
  CodeGenerator? generator(String specifications);

  @override
  Future<void> build(BuildStep buildStep) async {
    //print("1");
    String extension = buildExtensions[".spec"]!.first;
    //print("2");
    final AssetId output = buildStep.inputId.changeExtension(extension);
    //print("3");
    final String jsonString = await buildStep.readAsString(buildStep.inputId);
    //print("4");
    CodeGenerator? codeGenerator = generator(jsonString);
    //print("5");
    if (codeGenerator != null) {
      await buildStep.writeAsString(output, codeGenerator.getCode());
    }
    //print("6");
  }
}
