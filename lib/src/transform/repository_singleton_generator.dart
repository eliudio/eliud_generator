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
      String path = spec.path;
      if (spec.modelSpecification.generate.generateFirestoreRepository) {
        codeBuffer.writeln("import '../" + path + ".firestore.dart';");
        codeBuffer.writeln("//import '../" + path + ".js_firestore.dart';");
      }
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../" + path + ".repository.dart';");
      }
      if (spec.modelSpecification.generate.generateCache) {
        codeBuffer.writeln("import '../" + path + ".cache.dart';");
      }
    });
    codeBuffer.writeln("import '../auth/user_repository.dart';");
    codeBuffer.writeln("import 'package:eliud_model/tools/types.dart';");
    codeBuffer.writeln();
    codeBuffer.writeln("import '../shared/image.firestore.bespoke.dart';");
    codeBuffer.writeln("//import '../shared/image.js_firestore.bespoke.dart';");
    codeBuffer.writeln("import '../shared/image.cache.dart';");
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
        codeBuffer.writeln(spaces(2) + "static " + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository;");
      }
    });
    codeBuffer.writeln(spaces(2) + "static ImageRepository imageRepository;");
    codeBuffer.writeln(spaces(2) + "static UserRepository userRepository;");
    codeBuffer.writeln();
    codeBuffer.writeln(spaces(2) + "static initApp(DeviceType deviceType) {");

    codeBuffer.writeln(spaces(4) + "if ((deviceType == DeviceType.Android) || (deviceType == DeviceType.iPhone)) {");
    codeBuffer.writeln(spaces(6) + "imageRepository = new ImageCache(ImageFirestore());");
    codeBuffer.writeln(spaces(6) + "userRepository = new UserRepository();");

    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.write(spaces(6) + firstLowerCase(spec.modelSpecification.id) + "Repository = new ");
        if (spec.modelSpecification.generate.generateCache) {
          codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + "Firestore());");
        } else {
          codeBuffer.writeln(spec.modelSpecification.id + "Firestore();");
        }
      }
    });

    codeBuffer.writeln(spaces(4) + "} else {");
/*
    codeBuffer.writeln(spaces(6) + "//imageRepository = new ImageCache(ImageJsFirestore());");
    codeBuffer.writeln(spaces(6) + "userRepository = new UserRepository();");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.write(spaces(6) + firstLowerCase(spec.modelSpecification.id) + "Repository = new ");
        if (spec.modelSpecification.generate.generateCache) {
          codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + "JsFirestore());");
        } else {
          codeBuffer.writeln(spec.modelSpecification.id + "JsFirestore();");
        }
      }
    });
*/
    codeBuffer.writeln(spaces(4) + "}");

    modelSpecificationPlus.forEach((spec) {
      spec.modelSpecification.uniqueAssociationTypes().forEach((type) {
        codeBuffer.writeln(spaces(4) + spec.modelSpecification.id + "Model." + firstLowerCase(type) + "Repository = " + firstLowerCase(type) + "Repository;");
      });
    });
    codeBuffer.writeln(spaces(2) + "}");
    codeBuffer.writeln();

    codeBuffer.writeln(spaces(2) + "static void flush() {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        if (spec.modelSpecification.generate.generateCache) {
          codeBuffer.writeln(
              spaces(4) + "(" + firstLowerCase(spec.modelSpecification.id) + "Repository as " + spec.modelSpecification.id +
                  "Cache).flush();");
        }
      }
    });
    codeBuffer.writeln(spaces(2) + "}");

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
