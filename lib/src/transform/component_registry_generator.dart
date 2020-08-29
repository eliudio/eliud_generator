import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import '../model/internal_component.dart';
import 'package:eliud_core/tools/registry.dart';

\${import}

""";

const String _code = """
class ComponentRegistry {

  void init() {
\${register}
  }
}

""";

class ComponentRegistryGenerator extends CodeGeneratorMulti {
  ComponentRegistryGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());

    StringBuffer _import = StringBuffer();
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        _import.writeln("import '../extensions/" + camelcaseToUnderscore(spec.modelSpecification.id) + "_component.dart';");
      }
    });
    codeBuffer.writeln(process(_imports, parameters: <String, String> { '\${import}': _import.toString() }));
    StringBuffer register = StringBuffer();

    register.write(spaces(4) + "Registry.registry().addInternalComponents([");
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        register.write("\"" + firstLowerCase(ms.id) + "s\", ");
      }
    });
    register.writeln("]);");
    register.writeln();

    register .writeln(spaces(4) + "Registry.registry().register(componentName: \"internalWidgets\", componentConstructor: ListComponentFactory());");
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        register .writeln(spaces(4) + "Registry.registry().register(componentName: \"" + firstLowerCase(spec.modelSpecification.id) + "s\", componentConstructor: " + spec.modelSpecification.id + "ComponentConstructorDefault());");
      }
    });
    codeBuffer.writeln(process(_code, parameters: <String, String> { '\${register}': register.toString() }));
    return codeBuffer.toString();

  }
}
