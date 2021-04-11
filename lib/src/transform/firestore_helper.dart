import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

//COLLECTION_ID = WHAT_COMES_BEFORE-\${appID}-\${id}s

String retrieve_code = """
.then((v) async {
      var newValue = await get(value.documentID);
      if (newValue == null) {
        return value;
      } else {
        return newValue;
      }
    })
""";

class FirestoreHelper {
  static String collectionId(ModelSpecification modelSpecification) {
    return modelSpecification.id.toLowerCase();
  }

  static String eliudQuery(ModelSpecification modelSpecification) {
    return "eliudQuery";
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
      return retrieve_code;
    } else {
      return '';
    }
  }

  static String commonImports(String extraImports, ModelSpecification modelSpecifications, String importSufix) {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    if (extraImports != null) {
      headerBuffer.writeln(extraImports);
    }

    headerBuffer.writeln(base_imports(modelSpecifications.packageName, repo: true, model: true, entity: true, depends: modelSpecifications.depends));

    headerBuffer.writeln();

    return headerBuffer.toString();
  }
}
