import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';

String importString(String packageName, String file) {
  if (file.endsWith('.dart')) {
    return "import 'package:$packageName/$file';\n";
  } else {
    return "import 'package:$packageName/$file.dart';\n";
  }
}

String base_imports(String packageName,
    {bool? repo,
    bool? model,
    required bool entity,
    bool? cache,
    bool? embeddedComponent,
    List<String>? depends}) {
  String base = "";
  if ((repo != null) && (repo)) {
    if (depends != null) {
      for (var element in depends) {
        base =
            "${base}import 'package:$element/model/repository_export.dart';\n";
        base =
            "${base}import 'package:$element/model/abstract_repository_singleton.dart';\n";
      }
    }
    base =
        "${base}import 'package:eliud_core_model/tools/main_abstract_repository_singleton.dart';\n";
    base =
        base + importString(packageName, "model/abstract_repository_singleton");
    base = base + importString(packageName, "model/repository_export");
  }

  if ((cache != null) && (cache)) {
    if (depends != null) {
      for (var element in depends) {
        base = "${base}import 'package:$element/model/cache_export.dart';\n";
      }
    }
    base = base + importString(packageName, "model/cache_export");
  }

  if ((embeddedComponent != null) && (embeddedComponent)) {
    if (depends != null) {
      for (var element in depends) {
        base =
            "${base}import 'package:$element/model/embedded_component.dart';\n";
      }
    }
    base = base + importString(packageName, "model/embedded_component");
  }

  if ((model != null) && (model)) {
    if (depends != null) {
      for (var element in depends) {
        base = "${base}import 'package:$element/model/model_export.dart';\n";
      }
    }
    base = "${base}import '../tools/bespoke_models.dart';\n";
    base = base + importString(packageName, "model/model_export");
  }

  if ((entity != null) && (entity)) {
    if (depends != null) {
      for (var element in depends) {
        base = "${base}import 'package:$element/model/entity_export.dart';\n";
      }
    }
    base = "${base}import '../tools/bespoke_entities.dart';\n";
    base = base + importString(packageName, "model/entity_export");
  }

  return base;
}

/*
 * In theory all modelSpecifications must share the same package name. This is unexpected and unhandled if this is not the case.
 */
String sharedPackageName(List<ModelSpecificationPlus> modelSpecificationPlus) =>
    modelSpecificationPlus[0].modelSpecification.packageName;
String sharedPackageFriendlyName(
        List<ModelSpecificationPlus> modelSpecificationPlus) =>
    modelSpecificationPlus[0].modelSpecification.packageFriendlyName;

List<String> mergeAllDepends(
    List<ModelSpecificationPlus> modelSpecificationPlus) {
  List<String> depends = [];
  for (var modelSpecificationPlus in modelSpecificationPlus) {
    if (modelSpecificationPlus.modelSpecification.depends != null) {
      for (var newDepend
          in modelSpecificationPlus.modelSpecification.depends!) {
        if (!depends.contains(newDepend)) {
          depends.add(newDepend);
        }
      }
    }
  }
  return depends;
}

abstract class CodeGenerator extends CodeGeneratorBase {
  final ModelSpecification modelSpecifications;
  final List<String> uniqueAssociationTypes;

  Field? field(String fieldName) {
    for (Field f in modelSpecifications.fields) {
      if (f.fieldName == fieldName) return f;
    }
    return null;
  }

  CodeGenerator({required this.modelSpecifications})
      : uniqueAssociationTypes = modelSpecifications.uniqueAssociationTypes();

  bool hasArray() {
    bool returnMe = false;
    for (var field in modelSpecifications.fields) {
      if (field.isArray()) returnMe = true;
    }
    return returnMe;
  }

  String commonImports();

  String body();

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.write(commonImports());
    codeBuffer.write(body());
    return codeBuffer.toString();
  }

  bool hasDocumentID() {
    return modelSpecifications.fields
        .where((element) => element.fieldName == "documentID")
        .isNotEmpty;
  }

  bool withRepository() {
    return (modelSpecifications.generate.generateRepository) &&
        (modelSpecifications.generate.generateFirestoreRepository);
  }

  void extraImports(StringBuffer headerBuffer, String key) {
    if (modelSpecifications.extraImports[key] != null) {
      headerBuffer.writeln(modelSpecifications.extraImports[key]);
    }
  }

  String extraImports2(String key) {
    StringBuffer headerBuffer = StringBuffer();
    extraImports(headerBuffer, key);
    return headerBuffer.toString();
  }
}
