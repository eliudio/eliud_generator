import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator.dart';
import 'package:eliud_generator/src/transform/firestore_code_generator.dart';

import 'code_builder.dart';

/// A builder which builds a firestore repository based on a `spec` file
class FirestoreCodeBuilder extends CodeBuilder {
  Map<String, List<String>> get buildExtensions {
    return  {
      '.spec': const ['_firestore.dart'],
    };
  }

  @override
  CodeGenerator generator(String specifications) {
    ModelSpecification modelSpecification = ModelSpecification.fromJsonString(specifications);
    if (modelSpecification.generate.generateFirestoreRepository) {
      FirestoreCodeGenerator firestoreCodeGenerator = FirestoreCodeGenerator(
          modelSpecifications: modelSpecification);
      return firestoreCodeGenerator;
    }
  }
}
