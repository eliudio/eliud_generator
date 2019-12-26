import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

abstract class DataCodeGenerator extends CodeGenerator {
  DataCodeGenerator({ModelSpecification modelSpecifications}) : super(modelSpecifications: modelSpecifications);

  String getConstructor(String name) {
    StringBuffer codeBuffer = StringBuffer();
    // Constructor
    codeBuffer.write(spaces(2) + name + "({");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(
          "this." + field.fieldName + ", ");
    });
    codeBuffer.writeln("});");
    codeBuffer.writeln();
    return codeBuffer.toString();
  }

  String toStringCode(String name) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "@override");
    codeBuffer.writeln(spaces(2) + "String toString() {");
    bool extraLine = false;
    modelSpecifications.fields.forEach((field) {
      if (field.array) {
        codeBuffer.write(spaces(4) + "String " + field.fieldName + "Csv = " + field.fieldName + ".join(', ');");
        bool extraLine = true;
      }
    });
    if (extraLine) codeBuffer.writeln();
    codeBuffer.write(spaces(4) + "return '" + name + "{");
    modelSpecifications.fields.forEach((field) {
      codeBuffer.write(field.fieldName + ": ");
      if (field.array) {
        codeBuffer.write(field.fieldType + "[] { \$" + field.fieldName + "Csv }");
      } else {
        codeBuffer.write("\$" + field.fieldName);
      }
      if (modelSpecifications.fields.last != field) {
        codeBuffer.write(", ");
      }
    });
    codeBuffer.writeln("}';");
    codeBuffer.writeln("  }");
    return codeBuffer.toString();
  }
}
