import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

const String _imports = """
import '../model/internal_component.dart';
import 'package:eliud_core_main/apis/registryapi/component/component_spec.dart';
import 'abstract_repository_singleton.dart';
import 'package:eliud_core_main/apis/registryapi/component/component_constructor.dart';
import 'package:eliud_core_main/apis/apis.dart';

\${import}

""";

const String _code = """
/* 
 * Component registry contains a list of components
 */
class ComponentRegistry {

  /* 
   * Initialise the component registry
   */
\${register}
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

    StringBuffer import = StringBuffer();
    for (var spec in modelSpecificationPlus) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        import.writeln(
            "import '${camelcaseToUnderscore(spec.modelSpecification.id)}_component_selector.dart';");
      }
    }
    import.writeln(importString(pkgName, "model/internal_component.dart"));

    codeBuffer.writeln(process(_imports,
        parameters: <String, String>{'\${import}': import.toString()}));
    StringBuffer register = StringBuffer();

    register.write("${spaces(2)}init(");
    for (var spec in modelSpecificationPlus) {
      var id = spec.modelSpecification.id;
      var lid = firstLowerCase(spec.modelSpecification.id);
      if (spec.modelSpecification.generate.isExtension) {
        register.write(
            "ComponentConstructor ${lid}ComponentConstructorDefault, ComponentEditorConstructor ${lid}ComponentEditorConstructor, ");
      }
    }
    register.writeln(") {");

    register.write(
        "${spaces(4)}Apis.apis().getRegistryApi().addInternalComponents('$pkgName', [");
    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateInternalComponent) {
        register.write("\"${firstLowerCase(ms.id)}s\", ");
      }
    }
    register.writeln("]);");
    register.writeln();

    register.writeln(
        '${spaces(4)}Apis.apis().getRegistryApi().register(componentName: "${pkgName}_internalWidgets", componentConstructor: ListComponentFactory());');
    for (var spec in modelSpecificationPlus) {
      String path = spec.path;
      if (spec.modelSpecification.generate.isExtension) {
        register.writeln(
            "${spaces(4)}Apis.apis().getRegistryApi().addDropDownSupporter(\"${firstLowerCase(spec.modelSpecification.id)}s\", DropdownButtonComponentFactory());");
        register.writeln(
            "${spaces(4)}Apis.apis().getRegistryApi().register(componentName: \"${firstLowerCase(spec.modelSpecification.id)}s\", componentConstructor: ${firstLowerCase(spec.modelSpecification.id)}ComponentConstructorDefault);");
      }
    }

    register.writeln(
        "${spaces(4)}Apis.apis().getRegistryApi().addComponentSpec('$pkgName', '$pkgFriendlyName', [");
    for (var spec in modelSpecificationPlus) {
      var id = spec.modelSpecification.id;
      var lid = firstLowerCase(spec.modelSpecification.id);
      if (spec.modelSpecification.generate.isExtension) {
        register.writeln(
            "${spaces(6)}ComponentSpec('${firstLowerCase(id)}s', ${lid}ComponentConstructorDefault, ${id}ComponentSelector(), ${lid}ComponentEditorConstructor, ({String? appId}) => ${lid}Repository(appId: appId)! ), ");
      }
    }
    register.writeln("${spaces(4)}]);");

    for (var spec in modelSpecificationPlus) {
      var lid = firstLowerCase(spec.modelSpecification.id);
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton) &&
          (spec.modelSpecification.generate.isAppSubCollection())) {
        register.writeln(
            "${spaces(6)}Apis.apis().getRegistryApi().registerRetrieveRepository('$pkgName', '${lid}s', ({String? appId}) => ${lid}Repository(appId: appId)!);");
      }
    }

    register.writeln("${spaces(2)}}");
    codeBuffer.writeln(process(_code,
        parameters: <String, String>{'\${register}': register.toString()}));
    return codeBuffer.toString();
  }
}
