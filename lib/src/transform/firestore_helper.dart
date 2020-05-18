import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

//COLLECTION_ID = WHAT_COMES_BEFORE-\${appID}-\${id}s

class FirestoreHelper {
  static String collectionId(ModelSpecification modelSpecification) {
    return firstUpperCase(modelSpecification.id);
  }
}
