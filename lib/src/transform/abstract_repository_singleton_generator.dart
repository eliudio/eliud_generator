import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

class AbstractRepositorySingletonCodeGenerator extends CodeGeneratorMulti {
  AbstractRepositorySingletonCodeGenerator(String fileName)
      : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    for (var spec in modelSpecificationPlus) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../${path}_repository.dart';");
      }
    }

    codeBuffer.writeln(
        "import 'package:eliud_core_helpers/helpers/common_tools.dart';");
    codeBuffer.writeln(
        "import 'package:eliud_core_main/tools/etc/member_collection_info.dart';");

    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      List<ModelSpecificationPlus>? parents = getParantChain(modelSpecificationPlus, spec);
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton)) {
        var documentSubCollection =
            spec.modelSpecification.generate.documentSubCollectionOf;
        String appIdVar;
        if ((documentSubCollection != null) ||
            (spec.modelSpecification.getIsAppModel())) {
          if (spec.modelSpecification.generate.isAppSubCollection()) {
            appIdVar = "appId";
          } else {
            String parameters = "";
            if (parents != null) {
              for (var parent in parents) {
                parameters = "${firstLowerCase(
                    parent.modelSpecification.id)}Id, $parameters";
              }
            }
            appIdVar = "appId, " + parameters;
          }
        } else {
          appIdVar = "";
        }
        var appParams = "{ String? appId }";
        // if this is a subcollection but not subcollection from app...
        String parametersUse = "";
        if ((documentSubCollection != null) &&
            (!spec.modelSpecification.generate.isAppSubCollection())) {
          appParams =
              "{ String? appId, ";
          String parameters = "";
          if (parents != null) {
            for (var parent in parents) {
              parameters = "String? ${firstLowerCase(
                  parent.modelSpecification.id)}Id, $parameters";
            }
          }
//          appParams = appParams + ",  String? ${documentSubCollection.toLowerCase()}Id}";
          appParams = appParams + parameters + "}";
        } else {
          appParams = "{ String? appId }";
        }
        codeBuffer.writeln(
            "${spec.modelSpecification.id}Repository? ${firstLowerCase(spec.modelSpecification.id)}Repository($appParams) => AbstractRepositorySingleton.singleton.${firstLowerCase(spec.modelSpecification.id)}Repository($appIdVar);");
      }
    }
    codeBuffer.writeln();
    codeBuffer.writeln("abstract class AbstractRepositorySingleton {");
    codeBuffer.writeln(
        "${spaces(2)}static List<MemberCollectionInfo> collections = [");
    for (var spec in modelSpecificationPlus) {
      if (spec.modelSpecification.memberIdentifier != null) {
        codeBuffer.writeln(
            "${spaces(4)}MemberCollectionInfo('${spec.modelSpecification.id.toLowerCase()}', '${spec.modelSpecification.getMemberIdentifier()}'),");
      }
    }
    codeBuffer.writeln("${spaces(2)}];");

    codeBuffer.writeln(
        "${spaces(2)}static late AbstractRepositorySingleton singleton;");
    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton)) {
        if ((spec.modelSpecification.generate.documentSubCollectionOf !=
                null) ||
            (spec.modelSpecification.getIsAppModel())) {
          String param;
          if (spec.modelSpecification.generate.isAppSubCollection()) {
            param = "String? appId";
          } else {
            param =
                "String? appId, ";
            List<ModelSpecificationPlus>? parents = getParantChain(modelSpecificationPlus, spec);
            String parameters = "";
            if (parents != null) {
              for (var parent in parents) {
                parameters = "String? ${firstLowerCase(
                    parent.modelSpecification.id)}Id, $parameters";
              }
            }
            param = param + parameters;
          }
          codeBuffer.writeln(
              "${spaces(2)}${spec.modelSpecification.id}Repository? ${firstLowerCase(spec.modelSpecification.id)}Repository($param);");
        } else {
          codeBuffer.writeln(
              "${spaces(2)}${spec.modelSpecification.id}Repository? ${firstLowerCase(spec.modelSpecification.id)}Repository();");
        }
      }
    }
    codeBuffer.writeln();
    codeBuffer.writeln("${spaces(2)}void flush(String? appId) {");
    for (var spec in modelSpecificationPlus) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate.generateRepositorySingleton) &&
          (spec.modelSpecification.generate.isAppSubCollection())) {
        if (spec.modelSpecification.getIsAppModel()) {
          codeBuffer.writeln(
              "${spaces(4)}${firstLowerCase(spec.modelSpecification.id)}Repository(appId)!.flush();");
        } else {
          codeBuffer.writeln(
              "${spaces(4)}${firstLowerCase(spec.modelSpecification.id)}Repository()!.flush();");
        }
      }
    }
    codeBuffer.writeln("${spaces(2)}}");

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
