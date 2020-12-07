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

  static String copyWith(ModelSpecification modelSpecifications) {
    var hasServerTimeStamp = false;
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write("copyWith(");
    modelSpecifications.fields.forEach((field) {
      if (field.isServerTimestamp()) {
        codeBuffer.write(field.fieldName + " : FieldValue.serverTimestamp(), ");
        hasServerTimeStamp = true;
      }
    });
    codeBuffer.write(").");
    if (hasServerTimeStamp) {
      return codeBuffer.toString();
    } else {
      return "";
    }
  }

  // When a document gets a new server timestamp with the copy with statement, then we need to make sure that the document that is being returned is the correct document.
  static String then(ModelSpecification modelSpecifications) {
    var hasServerTimeStamp = false;
    modelSpecifications.fields.forEach((field) {
      if (field.isServerTimestamp()) {
        hasServerTimeStamp = true;
      }
    });
    if (hasServerTimeStamp) {
      return '.then((v) => get(value.documentID))';
    } else {
      return '';
    }
  }

}
