import 'package:build/build.dart';

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
    print(contents);
    await buildStep.writeAsString(output, "contents");
  }
}
