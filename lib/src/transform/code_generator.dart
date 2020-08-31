import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';

String base_imports({bool repo, bool model, bool entity, bool cache, bool embeddedComponent, List<String> depends}) {
  String base = "";
  if ((repo != null) && (repo)) {
    if (depends != null) {
      depends.forEach((element) {
        base = base + "import 'package:" + element + "/model/repository_export.dart';\n";
        base = base + "import 'package:" + element + "/model/abstract_repository_singleton.dart';\n";
      });
    }
    base = base + "import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';\n";
    base = base + "import '../model/abstract_repository_singleton.dart';\n";
    base = base + "import 'repository_export.dart';\n";
//    base = base + "import '../model/repository_export.dart';\n";
  }

  if ((cache != null) && (cache)) {
    if (depends != null) {
      depends.forEach((element) {
        base = base + "import 'package:" + element + "/model/cache_export.dart';\n";
      });
    }
    base = base + "import '../model/cache_export.dart';\n";
  }

  if ((embeddedComponent != null) && (embeddedComponent)) {
    if (depends != null) {
      depends.forEach((element) {
        base = base + "import 'package:" + element + "/model/embedded_component.dart';\n";
      });
    }
    base = base + "import '../model/embedded_component.dart';\n";
  }

  if ((model != null) && (model)) {
    if (depends != null) {
      depends.forEach((element) {
        base = base + "import 'package:" + element + "/model/model_export.dart';\n";
      });
    }
    base = base + "import 'package:eliud_core/tools/action_model.dart';\n";
    base = base + "import '../model/model_export.dart';\n";
  }

  if ((entity != null) && (entity)) {
    if (depends != null) {
      depends.forEach((element) {
        base = base + "import 'package:" + element + "/model/entity_export.dart';\n";
      });
    }
    base = base + "import 'package:eliud_core/tools/action_entity.dart';\n";
    base = base + "import '../model/entity_export.dart';\n";
  }

  return base;
}

List<String> mergeAllDepends(List<ModelSpecificationPlus> modelSpecificationPlus) {
  List<String> depends = [];
  modelSpecificationPlus.forEach((modelSpecificationPlus) {
    if (modelSpecificationPlus.modelSpecification.depends != null) {
      modelSpecificationPlus.modelSpecification.depends.forEach((newDepend) {
        if (!depends.contains(newDepend)) {
          depends.add(newDepend);
        }
      });
    }
  });
  return depends;
}


abstract class CodeGenerator extends CodeGeneratorBase {
  final ModelSpecification modelSpecifications;
  final List<String> uniqueAssociationTypes;
  
  Field field(String fieldName) {
    for (Field f in modelSpecifications.fields) {
      if (f.fieldName == fieldName) return f;
    }
    return null;
  }

  CodeGenerator({this.modelSpecifications})
      : uniqueAssociationTypes = modelSpecifications.uniqueAssociationTypes();

  bool hasArray() {
    bool returnMe = false;
    modelSpecifications.fields.forEach((field) {
      if (field.isArray()) returnMe = true;
    });
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
    return modelSpecifications.fields.where((element) => element.fieldName == "documentID").length > 0;
  }

  bool withRepository() {
    return (modelSpecifications.generate.generateRepository) &&  (modelSpecifications.generate.generateFirestoreRepository);
  }

  void extraImports(StringBuffer headerBuffer, String key) {
    if (modelSpecifications.extraImports != null) {
      if (modelSpecifications.extraImports[key] != null) {
        headerBuffer.writeln(modelSpecifications.extraImports[key]);
      }
    }
  }
}
