import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/transform/code_generator_base.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

abstract class CodeGeneratorMulti extends CodeGeneratorBase {
  final String fileName;

  CodeGeneratorMulti({required this.fileName});

  @override
  String theFileName() {
    return fileName;
  }

  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus);


  ModelSpecificationPlus? getParent(List<ModelSpecificationPlus> all, ModelSpecificationPlus child) {
    String? documentSubCollectionOf = child.modelSpecification.generate.documentSubCollectionOf;
    if (documentSubCollectionOf == null) {
      return null;
    }

    for (var spec in all) {
      if (firstLowerCase(spec.modelSpecification.id) == documentSubCollectionOf) {
        return spec;
      }
    }
    return null;
  }

  List<ModelSpecificationPlus>? getParantChain(List<ModelSpecificationPlus> all, ModelSpecificationPlus child) {
    List<ModelSpecificationPlus> chain = [];
    ModelSpecificationPlus? parent = getParent(all, child);
    while (parent != null) {
      chain.add(parent);
      parent = getParent(all, parent);
    }
    return chain;
  }
}
