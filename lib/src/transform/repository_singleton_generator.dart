import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class RepositorySingletonCodeGenerator extends CodeGeneratorMulti {
  RepositorySingletonCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        String path = spec.path;
        codeBuffer.writeln("import '../" + path + ".firestore.dart';");
        codeBuffer.writeln("import '../" + path + ".repository.dart';");
        codeBuffer.writeln();
      }
    });
    codeBuffer.writeln("import '../shared/image.repository.dart';");
    codeBuffer.writeln("import '../shared/image.firestore.dart';");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.uniqueAssociationTypes().isNotEmpty) {
        codeBuffer.writeln("import '../" + spec.path + ".model.dart';");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("class RepositorySingleton {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.writeln(spaces(2) + "static final " + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository = new " + spec.modelSpecification.id + "Firestore();");
      }
    });
    codeBuffer.writeln(spaces(2) + "static final ImageRepository imageRepository = new ImageFirestore();");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "static initApp() {");
    modelSpecificationPlus.forEach((spec) {
      spec.modelSpecification.uniqueAssociationTypes().forEach((type) {
        codeBuffer.writeln(spaces(4) + spec.modelSpecification.id + "Model." + firstLowerCase(type) + "Repository = " + firstLowerCase(type) + "Repository;");
      });
    });
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln("}");

    return codeBuffer.toString();

  }
}
