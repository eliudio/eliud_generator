import 'package:build/build.dart';
import 'package:json_schema/json_schema.dart';

/// A trivial builder which copies the contents of a `spec` file into a `dart` file.
class SimpleBuilder extends Builder {
  @override
  Map<String, List<String>> get buildExtensions => const <String, List<String>>{'.spec' : <String>['.dart']};

  @override
  Future<void> build(BuildStep buildStep) async {
    // The asset id identifies
    print("HALLO");
    final AssetId output = buildStep.inputId.changeExtension('.dart');
    final String contents = await buildStep.readAsString(buildStep.inputId);
    JsonSchema jsonSchema = JsonSchema.createSchema(contents);
    print(jsonSchema.toJson());
    await buildStep.writeAsString(output, jsonSchema.toJson());
  }
}
