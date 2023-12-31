import 'package:eliud_generator/src/model/field.dart';

import 'code_generator.dart';

abstract class DataCodeGenerator extends CodeGenerator {
  DataCodeGenerator({required super.modelSpecifications});

  String fieldName(Field field);

  String getConstructor(
      {required bool removeDocumentID,
      required String name,
      required bool terminate}) {
    StringBuffer codeBuffer = StringBuffer();
    // Constructor
    codeBuffer.write("${spaces(2)}$name({");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.fieldName == "documentID") {
          if (!removeDocumentID) {
            codeBuffer.write(
                "${field.isRequired ?? false ? 'required this.' : 'this.'}${fieldName(field)}, ");
          }
        } else {
          codeBuffer.write(
              "${field.isRequired ?? false ? 'required this.' : 'this.'}${fieldName(field)}, ");
        }
      }
    }
    codeBuffer.write("})");
    if (terminate) {
      codeBuffer.writeln(";");
      codeBuffer.writeln();
    }
    return codeBuffer.toString();
  }

  String toStringCode(bool removeDocumentID, String name) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("${spaces(2)}@override");
    codeBuffer.writeln("${spaces(2)}String toString() {");
    bool extraLine = false;
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (field.isArray()) {
          codeBuffer.writeln(
              "${spaces(4)}String ${fieldName(field)}Csv = (${fieldName(field)} == null) ? '' : ${fieldName(field)}!.join(', ');");
          extraLine = true;
        }
      }
    }
    if (extraLine) codeBuffer.writeln();
    codeBuffer.write("${spaces(4)}return '$name{");
    for (var field in modelSpecifications.fields) {
      if (field.arrayType != ArrayType.CollectionArrayType) {
        if (!((removeDocumentID) && (field.fieldName == "documentID"))) {
          codeBuffer.write("${fieldName(field)}: ");
          if (field.isArray()) {
            codeBuffer
                .write("${field.fieldType}[] { \$${fieldName(field)}Csv }");
          } else {
            codeBuffer.write("\$${fieldName(field)}");
          }
          if (modelSpecifications.fields.last != field) {
            codeBuffer.write(", ");
          }
        }
      }
    }
    codeBuffer.writeln("}';");
    codeBuffer.writeln("  }");
    return codeBuffer.toString();
  }
}
