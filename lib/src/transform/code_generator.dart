import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';
import 'package:json_schema/json_schema.dart';

abstract class CodeGenerator extends CodeGeneratorBase {
  final ModelSpecification modelSpecifications;
  final List<String> uniqueAssociationTypes;

  CodeGenerator({this.modelSpecifications})
      : uniqueAssociationTypes = modelSpecifications.uniqueAssociationTypes();

  String resolveImport({String importThis}) {
    if ((importThis.startsWith("action.")) ||
        (importThis.startsWith("image.")) ||
        (importThis.startsWith("rgb.")) ||
        (importThis.startsWith("icon.")))
      return "package:eliud_model/shared/" + importThis;
    return importThis;
  }

  bool hasArray() {
    bool returnMe = false;
    modelSpecifications.fields.forEach((field) {
      if (field.array) returnMe = true;
    });
    return returnMe;
  }

  String commonImports();

  String body();

  String getCode() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.write(commonImports());
    codeBuffer.write(body());
    return codeBuffer.toString();
  }
}
