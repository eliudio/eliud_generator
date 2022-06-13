import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import '../model/internal_component.dart';
import 'package:eliud_core/core/registry.dart';
import 'package:eliud_core/tools/component/component_spec.dart';
import 'abstract_repository_singleton.dart';

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
  ComponentRegistryGenerator(String fileName) : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    var pkgName = sharedPackageName(modelSpecificationPlus);
    var pkgFriendlyName = sharedPackageFriendlyName(modelSpecificationPlus);
    
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());

    StringBuffer _import = StringBuffer();
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        _import.writeln("import '../extensions/" +
            camelcaseToUnderscore(spec.modelSpecification.id) +
            "_component.dart';");
        _import.writeln("import '../editors/" +
            camelcaseToUnderscore(spec.modelSpecification.id) +
            "_component_editor.dart';");
        _import.writeln("import '" +
            camelcaseToUnderscore(spec.modelSpecification.id) +
            "_component_selector.dart';");
      }
    });
    _import.writeln(importString(pkgName, "model/internal_component.dart"));

    codeBuffer.writeln(process(_imports,
        parameters: <String, String>{'\${import}': _import.toString()}));
    StringBuffer register = StringBuffer();

    register.write(spaces(4) +
        "Registry.registry()!.addInternalComponents('" +
        pkgName +
        "', [");
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        register.write("\"" + firstLowerCase(ms.id) + "s\", ");
      }
    });
    register.writeln("]);");
    register.writeln();

    register.writeln(spaces(4) +
        'Registry.registry()!.register(componentName: "' +
        pkgName +
        '_internalWidgets", componentConstructor: ListComponentFactory());');
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        register.writeln(spaces(4) +
            "Registry.registry()!.addDropDownSupporter(\"" +
            firstLowerCase(spec.modelSpecification.id) +
            "s\", DropdownButtonComponentFactory());");
        register.writeln(spaces(4) +
            "Registry.registry()!.register(componentName: \"" +
            firstLowerCase(spec.modelSpecification.id) +
            "s\", componentConstructor: " +
            spec.modelSpecification.id +
            "ComponentConstructorDefault());");
      }
    });

    register.writeln(
        spaces(4) + "Registry.registry()!.addComponentSpec('$pkgName', '$pkgFriendlyName', [");
    modelSpecificationPlus.forEach((spec) {
      var id = spec.modelSpecification.id;
      var lid = firstLowerCase(spec.modelSpecification.id);
      if (spec.modelSpecification.generate.isExtension) {
        register.writeln(spaces(6) +
            "ComponentSpec('" +
            firstLowerCase(id) +
            "s', " +
            id +
            "ComponentConstructorDefault(), " +
            id +
            "ComponentSelector(), " +
            id +
            "ComponentEditorConstructor(), " +
            "({String? appId}) => " + lid + "Repository(appId: appId)! ), ");


      }
    });
    register.writeln(spaces(4) + "]);");

    codeBuffer.writeln(process(_code,
        parameters: <String, String>{'\${register}': register.toString()}));
    return codeBuffer.toString();
  }
}
