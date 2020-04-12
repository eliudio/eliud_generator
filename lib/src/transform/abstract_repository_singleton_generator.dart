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
    codeBuffer.writeln("import '../auth/user_repository.dart';");
    codeBuffer.writeln("import 'package:eliud_model/tools/types.dart';");
    codeBuffer.writeln();
    codeBuffer.writeln("abstract class AbstractRepositorySingleton {");
    codeBuffer.writeln(spaces(2) + "static AbstractRepositorySingleton singleton;");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.writeln(spaces(2) + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository();");
      }
    });
    codeBuffer.writeln(spaces(2) + "ImageRepository imageRepository();");
    codeBuffer.writeln(spaces(2) + "UserRepository userRepository();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "void flush() {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.writeln(spaces(4) + firstLowerCase(spec.modelSpecification.id) + "Repository().flush();");
      }
    });
    codeBuffer.writeln(spaces(2) + "}");

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
