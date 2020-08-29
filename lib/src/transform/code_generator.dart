import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';

String base_imports({bool repo, bool model, bool entity, bool cache}) {
  String base = """
// import the main classes
import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';

// import the shared classes
import 'package:eliud_core/model/abstract_repository_singleton.dart';
""";

  if ((repo != null) && (repo)) {
    base = base + """
import 'package:eliud_core/model/repository_export.dart';
""";
  }

  if ((cache != null) && (cache)) {
    base = base + """
import 'package:eliud_core/model/cache_export.dart';
""";
  }

  if ((model != null) && (model)) {
    base = base + """
import 'package:eliud_core/model/model_export.dart';
import 'package:eliud_core/tools/action_model.dart';
""";
  }

  if ((entity != null) && (entity)) {
    base = base + """
import 'package:eliud_core/model/entity_export.dart';
""";
  }

  base = base + """
  
// import the classes of this package:
import '../model/abstract_repository_singleton.dart';
""";

  if ((repo != null) && (repo)) {
    base = base + """
import '../model/repository_export.dart';
import 'package:eliud_core/model/repository_export.dart';
""";
  }

  if ((cache != null) && (cache)) {
    base = base + """
import '../model/cache_export.dart';
import 'package:eliud_core/model/cache_export.dart';
""";
  }

  if ((model != null) && (model)) {
    base = base + """
import '../model/model_export.dart';
import 'package:eliud_core/model/model_export.dart';
""";
  }

  if ((entity != null) && (entity)) {
    base = base + """
import '../model/entity_export.dart';
import 'package:eliud_core/model/entity_export.dart';
""";
  }

  return base;
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
