import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

abstract class RepositorySingletonCodeBaseGenerator extends CodeGeneratorMulti {
  final String prefix;  // class prefix
  final String file_prefix; // filename prefix

  RepositorySingletonCodeBaseGenerator(String fileName, this.prefix, this.file_prefix): super(fileName: fileName);

  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.writeln("import 'abstract_repository_singleton.dart';");
    codeBuffer.writeln("import 'dart:collection';");
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateRepositorySingleton) {
        codeBuffer.writeln("import '../" + path + file_prefix + "_firestore.dart';");
      }
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../" + path + "_repository.dart';");
      }
      if (spec.modelSpecification.generate.generateCache) {
        codeBuffer.writeln("import '../" + path + "_cache.dart';");
      }
    });
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.uniqueAssociationTypes().isNotEmpty) {
        codeBuffer.writeln("import '../" + spec.path + "_model.dart';");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("class ${prefix}RepositorySingleton extends AbstractRepositorySingleton {");

    // attributes
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepositorySingleton) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        codeBuffer.write(spaces(4) + "var _" + firstLowerCase(spec.modelSpecification.id) + "Repository = ");
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln("HashMap<String, " + spec.modelSpecification.id + "Repository>();");
        } else {
          if (spec.modelSpecification.generate.generateCache) {
            codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + "${prefix}Firestore());");
          } else {
            codeBuffer.writeln(spec.modelSpecification.id + "Firestore();");
          }
        }
      }
    });
    codeBuffer.writeln();

    // Methods
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepositorySingleton) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        codeBuffer.write(spaces(4) + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository");
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln("(String appId) {");
          codeBuffer.write(spaces(6) + "if (_" + firstLowerCase(spec.modelSpecification.id) + "Repository[appId] == null) _" + firstLowerCase(spec.modelSpecification.id) + "Repository[appId] = ");

          if (spec.modelSpecification.generate.generateCache) {
            codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + "${prefix}Firestore(appId));");
          } else {
            codeBuffer.writeln("${prefix}FireStore(appId);");
          }

          codeBuffer.writeln(spaces(6) + "return _" + firstLowerCase(spec.modelSpecification.id) + "Repository[appId];");
        } else {
          codeBuffer.writeln("() {");
          codeBuffer.writeln(spaces(6) + "return _" + firstLowerCase(spec.modelSpecification.id) + "Repository;");
        }
        codeBuffer.writeln(spaces(4) + "}");
      }
    });
    codeBuffer.writeln();

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
