import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';

import 'code_generator.dart';

abstract class DataCodeGenerator extends CodeGenerator {
  DataCodeGenerator({ModelSpecification modelSpecifications}) : super(modelSpecifications: modelSpecifications);

  String fieldName(Field field);

  String getConstructor({bool removeDocumentID, String name, bool terminate}) {
    StringBuffer codeBuffer = StringBuffer();
    // Constructor
    codeBuffer.write(spaces(2) + name + "({");
    bool addInit = false;
    modelSpecifications.fields.forEach((field) {
      if (field.fieldName == "documentID") {
        if (!removeDocumentID) {
          codeBuffer.write(
              "String " + fieldName(field) + ", ");
          addInit = true;
        }
      } else {
        codeBuffer.write(
            "this." + fieldName(field) + ", ");
      }
    });
    codeBuffer.write("})");
    if (addInit) {
      codeBuffer.write(" : this.documentID = documentID.toLowerCase()");
    }
    if (terminate) {
      codeBuffer.writeln(";");
      codeBuffer.writeln();
    }
    return codeBuffer.toString();
  }

  String toStringCode(bool removeDocumentID, String name) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (field.array) {
        codeBuffer.writeln(spaces(4) + "String " + fieldName(field) + "Csv = (" + fieldName(field) + " == null) ? '' : " + fieldName(field) + ".join(', ');");
        extraLine = true;
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.write(spaces(4) + "return '" + name + "{");
    modelSpecifications.fields.forEach((field) {
      if (!((removeDocumentID) && (field.fieldName == "documentID"))) {
        codeBuffer.write(fieldName(field) + ": ");
        if (field.array) {
          codeBuffer.write(
              field.fieldType + "[] { \$" + fieldName(field) + "Csv }");
        } else {
          codeBuffer.write("\$" + fieldName(field));
        }
        if (modelSpecifications.fields.last != field) {
          codeBuffer.write(", ");
        }
      }
    });
    codeBuffer.writeln("}';");
    codeBuffer.writeln("  }");
    return codeBuffer.toString();
  }
}
