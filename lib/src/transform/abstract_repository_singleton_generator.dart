import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class AbstractRepositorySingletonCodeGenerator extends CodeGeneratorMulti {
  AbstractRepositorySingletonCodeGenerator(String fileName): super(fileName: fileName);

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
    codeBuffer.writeln("import 'package:eliud_core/core/access/bloc/user_repository.dart';");
    codeBuffer.writeln("import 'package:eliud_core/tools/common_tools.dart';");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepositorySingleton) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln(
              spec.modelSpecification.id + "Repository " +
                  firstLowerCase(spec.modelSpecification.id) +
                  "Repository({ String appId }) => AbstractRepositorySingleton.singleton." +
                  firstLowerCase(spec.modelSpecification.id) +
                  "Repository(appId);");
        } else {
          codeBuffer.writeln(
              spec.modelSpecification.id + "Repository " +
                  firstLowerCase(spec.modelSpecification.id) +
                  "Repository({ String appId }) => AbstractRepositorySingleton.singleton." +
                  firstLowerCase(spec.modelSpecification.id) +
                  "Repository();");
        }
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("abstract class AbstractRepositorySingleton {");
    codeBuffer.writeln(spaces(2) + "static AbstractRepositorySingleton singleton;");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") && (spec.modelSpecification.generate.generateRepositorySingleton) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln(
              spaces(2) + spec.modelSpecification.id + "Repository " +
                  firstLowerCase(spec.modelSpecification.id) + "Repository(String appId);");
        } else {
          codeBuffer.writeln(
              spaces(2) + spec.modelSpecification.id + "Repository " +
                  firstLowerCase(spec.modelSpecification.id) + "Repository();");
        }
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "void flush(String appId) {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.id != "App") &&  (spec.modelSpecification.generate.generateRepositorySingleton) && (!spec.modelSpecification.generate.isDocumentCollection)) {
        if (spec.modelSpecification.isAppModel) {
          codeBuffer.writeln(
              spaces(4) + firstLowerCase(spec.modelSpecification.id) +
                  "Repository(appId).flush();");
        } else {
          codeBuffer.writeln(
              spaces(4) + firstLowerCase(spec.modelSpecification.id) +
                  "Repository().flush();");
        }
      }
    });
    codeBuffer.writeln(spaces(2) + "}");

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
