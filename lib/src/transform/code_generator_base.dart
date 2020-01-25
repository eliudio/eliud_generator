import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';
import 'package:json_schema/json_schema.dart';

const String _header= """
/*
       _ _           _ 
      | (_)         | |
   ___| |_ _   _  __| |
  / _ \\ | | | | |/ _` |
 |  __/ | | |_| | (_| |
  \\___|_|_|\\__,_|\\__,_|
                       
 
 \${fileName}
                       
 This code is generated. This is read only. Don't touch!

*/
""";

abstract class CodeGeneratorBase {
  String theFileName();

  String header() {
    StringBuffer headerBuffer = StringBuffer();
    Map<String, String> parameters = Map();
    parameters['\${fileName}'] = theFileName();
    headerBuffer.writeln(process(_header, parameters));
    return headerBuffer.toString();
  }

  static final ALL_SPACES =
      "                                                                                         ";

  String spaces(int amount) {
    return ALL_SPACES.substring(0, amount);
  }
}
