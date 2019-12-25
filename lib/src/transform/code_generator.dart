import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:json_schema/json_schema.dart';

abstract class CodeGenerator {
  final ModelSpecification modelSpecifications;

  CodeGenerator({ this.modelSpecifications });

  String theFileName();

  String getHeader() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("///////////////////////////////////////////////////////////");
    headerBuffer.writeln("// " + theFileName());
    headerBuffer.writeln("// This code is generated. This is read only. Don't touch!");
    headerBuffer.writeln("///////////////////////////////////////////////////////////");
    headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String getCode();

  bool hasArray() {
    bool returnMe = false;
    modelSpecifications.fields.forEach((field) {
      if (field.array) returnMe = true;
    });
    return returnMe;
  }

}
