import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:json_schema/json_schema.dart';

abstract class CodeGenerator {
  final ModelSpecification modelSpecifications;

  CodeGenerator({ this.modelSpecifications });

  String theFileName();

  String header() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("/*");
    headerBuffer.writeln("                 _ _           _");
    headerBuffer.writeln("                | (_)         | |");
    headerBuffer.writeln("             ___| |_ _   _  __| |");
    headerBuffer.writeln("            / _ \\ | | | | |/ _` |");
    headerBuffer.writeln("           |  __/ | | |_| | (_| |");
    headerBuffer.writeln("            \\___|_|_|\\__,_|\\__,_|");
    headerBuffer.writeln();
    headerBuffer.writeln("           " + theFileName());
    headerBuffer.writeln();
    headerBuffer.writeln("This code is generated. This is read only. Don't touch!");
    headerBuffer.writeln("*/");
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

  static final ALL_SPACES = "                                                                                         ";

  String spaces(int amount) {
    return ALL_SPACES.substring(0, amount);
  }

}
