import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'code_generator_multi.dart';

class JsRepositorySingletonCodeGenerator extends CodeGeneratorMulti {
  JsRepositorySingletonCodeGenerator(String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.writeln("import 'abstract_repository_singleton.dart';");
    modelSpecificationPlus.forEach((spec) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateFirestoreRepository) {
        codeBuffer.writeln("import '../" + path + "_js_firestore.dart';");
      }
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../" + path + "_repository.dart';");
      }
      if (spec.modelSpecification.generate.generateCache) {
        codeBuffer.writeln("import '../" + path + "_cache.dart';");
      }
    });
    codeBuffer.writeln("import '../auth/user_repository.dart';");
    codeBuffer.writeln("import 'package:eliud_model/tools/types.dart';");
    codeBuffer.writeln();
    codeBuffer.writeln("import '../shared/image_js_firestore_bespoke.dart';");
    codeBuffer.writeln("import '../shared/image_cache.dart';");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      if (spec.modelSpecification.uniqueAssociationTypes().isNotEmpty) {
        codeBuffer.writeln("import '../" + spec.path + "_model.dart';");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("class JsRepositorySingleton extends AbstractRepositorySingleton {");
    modelSpecificationPlus.forEach((spec) {
      if ((spec.modelSpecification.generate.generateRepository) &&  (spec.modelSpecification.generate.generateFirestoreRepository)) {
        codeBuffer.writeln(spaces(2) + spec.modelSpecification.id + "Repository " + firstLowerCase(spec.modelSpecification.id) + "Repository() => _" + firstLowerCase(spec.modelSpecification.id) + "Repository;");
        codeBuffer.write(spaces(2) + spec.modelSpecification.id + "Repository _" + firstLowerCase(spec.modelSpecification.id) + "Repository = ");
        if (spec.modelSpecification.generate.generateCache) {
          codeBuffer.writeln(spec.modelSpecification.id + "Cache(" + spec.modelSpecification.id + "JsFirestore());");
        } else {
          codeBuffer.writeln(spec.modelSpecification.id + "JsFirestore();");
        }
      }
    });
    codeBuffer.writeln(spaces(2) + "ImageRepository imageRepository() => _imageRepository;");
    codeBuffer.writeln(spaces(2) + "ImageRepository _imageRepository = new ImageCache(ImageJsFirestore());");
    codeBuffer.writeln(spaces(2) + "UserRepository userRepository() => _userRepository;");
    codeBuffer.writeln(spaces(2) + "UserRepository _userRepository = new UserRepository();");
    codeBuffer.writeln();

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
