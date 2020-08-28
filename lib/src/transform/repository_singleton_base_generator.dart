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
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateFirestoreRepository) {
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

    codeBuffer.writeln("  ${prefix}RepositorySingleton(String appID) {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        codeBuffer.write(spaces(4) + "_" + firstLowerCase(spec.modelSpecification.id) + "Repository = ");
        String init;
        if (spec.modelSpecification.isAppModel) {
          init = "${prefix}Firestore(appID)";
        } else {
          init = "${prefix}Firestore()";
        }
        if (spec.modelSpecification.generate.generateCache) {
          codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + init + ");");
        } else {
          codeBuffer.writeln(spec.modelSpecification.id + init + ";");
        }
      }
    });
    codeBuffer.writeln("  }");

    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        codeBuffer.writeln(spaces(2) + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository() => _" + firstLowerCase(spec.modelSpecification.id) + "Repository;");
        codeBuffer.writeln(spaces(2) + spec.modelSpecification.id + "Repository _" + firstLowerCase(spec.modelSpecification.id) + "Repository;");
      }
    });
    codeBuffer.writeln();

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
