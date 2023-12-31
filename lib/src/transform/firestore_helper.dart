import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

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

String retrieve_code_entity = """
.then((v) async {
      var newValue = await getEntity(documentID);
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
    for (var field in modelSpecifications.fields) {
      if (field.isServerTimestampInitialized()) {
        codeBuffer.write("${field.fieldName} : FieldValue.serverTimestamp(), ");
        hasServerTimeStamp = true;
      }
    }
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
    for (var field in modelSpecifications.fields) {
      if (field.isServerTimestamp()) {
        hasServerTimeStamp = true;
      }
    }
    if (hasServerTimeStamp) {
      return retrieve_code;
    } else {
      return '';
    }
  }

  static String thenEntity(ModelSpecification modelSpecifications) {
    var hasServerTimeStamp = false;
    for (var field in modelSpecifications.fields) {
      if (field.isServerTimestamp()) {
        hasServerTimeStamp = true;
      }
    }
    if (hasServerTimeStamp) {
      return retrieve_code_entity;
    } else {
      return '';
    }
  }

  static String commonImports(String extraImports,
      ModelSpecification modelSpecifications, String importSufix) {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(importString(modelSpecifications.packageName,
        "model/${modelSpecifications.repositoryFileName()}"));
    headerBuffer.writeln(extraImports);

    headerBuffer.writeln(base_imports(modelSpecifications.packageName,
        repo: true,
        model: true,
        entity: true,
        depends: modelSpecifications.depends));

    headerBuffer.writeln();

    return headerBuffer.toString();
  }
}
