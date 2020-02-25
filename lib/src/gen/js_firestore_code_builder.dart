import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/js_firestore_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a java firestore (for flutterweb) repository based on a `spec` file
class JsFirestoreCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['.js_firestore.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateFirestoreRepository) {
      JsFirestoreCodeGenerator firestoreCodeGenerator = JsFirestoreCodeGenerator(
          modelSpecifications: modelSpecification);
      return firestoreCodeGenerator;
    }
  }
}
