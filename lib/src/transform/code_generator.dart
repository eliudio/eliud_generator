import 'package:json_schema/json_schema.dart';

abstract class CodeGenerator {
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

}
