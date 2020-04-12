import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';
import 'package:json_schema/json_schema.dart';

abstract class CodeGenerator extends CodeGeneratorBase {
  final ModelSpecification modelSpecifications;
  final List<String> uniqueAssociationTypes;
  
  Field field(String fieldName) {
    for (Field f in modelSpecifications.fields) {
      if (f.fieldName == fieldName) return f;
    }
    return null;
  }

  CodeGenerator({this.modelSpecifications})
      : uniqueAssociationTypes = modelSpecifications.uniqueAssociationTypes();

  String resolveImport({String importThis}) {
    if ((importThis.startsWith("action_")) ||
        (importThis.startsWith("image_")) ||
        (importThis.startsWith("grid_view_type_")) ||
        (importThis.startsWith("tile_type_")) ||
        (importThis.startsWith("rgb_")) ||
        (importThis.startsWith("background_")) ||
        (importThis.startsWith("decoration_color_")) ||
        (importThis.startsWith("icon_")))
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

  bool hasDocumentID() {
    return modelSpecifications.fields.where((element) => element.fieldName == "documentID").length > 0;
  }

  bool withRepository() {
    return (modelSpecifications.generate.generateRepository) &&  (modelSpecifications.generate.generateFirestoreRepository);
  }

}
