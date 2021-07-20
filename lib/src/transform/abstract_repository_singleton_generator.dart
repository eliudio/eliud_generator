import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class AbstractRepositorySingletonCodeGenerator extends CodeGeneratorMulti {
  AbstractRepositorySingletonCodeGenerator(String fileName)
      : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../" + path + "_repository.dart';");
      }
    });
    codeBuffer.writeln(
        "import 'package:eliud_core/core/access/bloc/user_repository.dart';");
    codeBuffer.writeln("import 'package:eliud_core/tools/common_tools.dart';");
    codeBuffer.writeln(
        "import 'package:eliud_core/tools/main_abstract_repository_singleton.dart';");
    codeBuffer.writeln("import 'package:eliud_core/package/package.dart';");

    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton)) {
        var documentSubCollection = spec.modelSpecification.generate.documentSubCollectionOf;
        var appIdVar;
        if ((documentSubCollection != null) ||
            (spec.modelSpecification.isAppModel)) {
          if (spec.modelSpecification.generate.isAppSubCollection()) {
            appIdVar = "appId";
          } else {
            appIdVar = "appId, " + documentSubCollection.toLowerCase() + "Id";
          }
        } else {
          appIdVar = "";
        }
        var appParams = "{ String? appId }";
        // if this is a subcollection but not subcollection from app...
        if ((documentSubCollection != null) && (!spec.modelSpecification.generate.isAppSubCollection())) {
          appParams = "{ String? appId,  String? " + documentSubCollection.toLowerCase() + "Id}";
        } else {
          appParams = "{ String? appId }";
        }
        codeBuffer.writeln(spec.modelSpecification.id +
            "Repository? " +
            firstLowerCase(spec.modelSpecification.id) +
            "Repository($appParams) => AbstractRepositorySingleton.singleton." +
            firstLowerCase(spec.modelSpecification.id) +
            "Repository($appIdVar);");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("abstract class AbstractRepositorySingleton {");
    codeBuffer.writeln(
        spaces(2) + "static List<MemberCollectionInfo> collections = [");
    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.memberIdentifier != null) {
        codeBuffer.writeln(spaces(4) +
            "MemberCollectionInfo('" +
            spec.modelSpecification.id.toLowerCase() +
            "', '" +
            spec.modelSpecification.memberIdentifier +
            "'),");
      }
    });
    codeBuffer.writeln(spaces(2) + "];");

    codeBuffer.writeln(
        spaces(2) + "static late AbstractRepositorySingleton singleton;");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton)) {
        if ((spec.modelSpecification.generate.documentSubCollectionOf !=
                null) ||
            (spec.modelSpecification.isAppModel)) {

          var param;
          if (spec.modelSpecification.generate.isAppSubCollection()) {
            param = "String? appId";
          } else {
            param = "String? appId, String? " + spec.modelSpecification.generate.documentSubCollectionOf.toLowerCase() + "Id";
          }
          codeBuffer.writeln(spaces(2) +
              spec.modelSpecification.id +
              "Repository? " +
              firstLowerCase(spec.modelSpecification.id) +
              "Repository($param);");
        } else {
          codeBuffer.writeln(spaces(2) +
              spec.modelSpecification.id +
              "Repository? " +
              firstLowerCase(spec.modelSpecification.id) +
              "Repository();");
        }
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "void flush(String? appId) {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton) &&
          (spec.modelSpecification.generate.isAppSubCollection())) {
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln(spaces(4) +
              firstLowerCase(spec.modelSpecification.id) +
              "Repository(appId)!.flush();");
        } else {
          codeBuffer.writeln(spaces(4) +
              firstLowerCase(spec.modelSpecification.id) +
              "Repository()!.flush();");
        }
      }
    });
    codeBuffer.writeln(spaces(2) + "}");

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
