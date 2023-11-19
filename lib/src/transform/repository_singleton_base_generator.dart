import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';
import 'code_generator_multi.dart';
import 'firestore_helper.dart';

abstract class RepositorySingletonCodeBaseGenerator extends CodeGeneratorMulti {
  final String prefix; // class prefix
  final String file_prefix; // filename prefix

  RepositorySingletonCodeBaseGenerator(
      String fileName, this.prefix, this.file_prefix)
      : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(header());
    codeBuffer.writeln("import 'abstract_repository_singleton.dart';");
    codeBuffer.writeln(
        "import 'package:eliud_core_model/tools/main_abstract_repository_singleton.dart';");
    codeBuffer.writeln("import 'dart:collection';");
    for (var spec in modelSpecificationPlus) {
      String path = spec.path;
      if (spec.modelSpecification.generate.generateRepositorySingleton) {
        codeBuffer.writeln("import '../$path${file_prefix}_firestore.dart';");
      }
      if (spec.modelSpecification.generate.generateRepository) {
        codeBuffer.writeln("import '../${path}_repository.dart';");
      }
      if (spec.modelSpecification.generate.generateCache) {
        codeBuffer.writeln("import '../${path}_cache.dart';");
      }
    }
    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      if (spec.modelSpecification.uniqueAssociationTypes().isNotEmpty) {
        codeBuffer.writeln("import '../${spec.path}_model.dart';");
      }
    }
    codeBuffer.writeln();
    codeBuffer.writeln(
        "class ${prefix}RepositorySingleton extends AbstractRepositorySingleton {");

    // attributes
    for (var spec in modelSpecificationPlus) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate
              .generateRepositorySingleton) /* && (!spec.modelSpecification.generate.isDocumentCollection)*/) {
        codeBuffer.write(
            "${spaces(4)}var _${firstLowerCase(spec.modelSpecification.id)}Repository = ");
        if (spec.modelSpecification.getIsAppModel()) {
          codeBuffer.writeln(
              "HashMap<String, ${spec.modelSpecification.id}Repository>();");
        } else {
          if (spec.modelSpecification.generate.generateCache) {
            codeBuffer.writeln(
                "${spec.modelSpecification.id}Cache(${spec.modelSpecification.id}${prefix}Firestore());");
          } else {
            codeBuffer
                .writeln("${spec.modelSpecification.id}${prefix}Firestore();");
          }
        }
      }
    }
    codeBuffer.writeln();

    // Methods
    for (var spec in modelSpecificationPlus) {
      if ((spec.modelSpecification.id != "App") &&
          (spec.modelSpecification.generate
              .generateRepositorySingleton) /* && (!spec.modelSpecification.generate.isDocumentCollection)*/) {
        codeBuffer.write(
            "${spaces(4)}${spec.modelSpecification.id}Repository? ${firstLowerCase(spec.modelSpecification.id)}Repository");
        if (spec.modelSpecification.getIsAppModel()) {
          var documentSubCollectionOf =
              spec.modelSpecification.generate.documentSubCollectionOf;
          if ((documentSubCollectionOf != null) &&
              (!spec.modelSpecification.generate.isAppSubCollection())) {
            var lowerCase = documentSubCollectionOf.toLowerCase();
            var id = "${lowerCase}Id";
            codeBuffer.writeln("(String? appId, String? $id) {");
            codeBuffer.writeln(
                "${spaces(6)}var key = appId == null || $id == null ? null : appId + '-' + $id;");
            codeBuffer.write(
                "${spaces(6)}if ((key != null) && (_${firstLowerCase(spec.modelSpecification.id)}Repository[key] == null)) { _${firstLowerCase(spec.modelSpecification.id)}Repository[key] = ");

            var parameter =
                "() => ${lowerCase}Repository(appId)!.getSubCollection($id!, '${FirestoreHelper.collectionId(spec.modelSpecification)}'), appId!";
            if (spec.modelSpecification.generate.generateCache) {
              codeBuffer.writeln(
                  "${spec.modelSpecification.id}Cache(${spec.modelSpecification.id}${prefix}Firestore($parameter));}");
            } else {
              codeBuffer.writeln(
                  "${spec.modelSpecification.id}${prefix}Firestore($parameter);}");
            }

            codeBuffer.writeln(
                "${spaces(6)}return _${firstLowerCase(spec.modelSpecification.id)}Repository[key]; ");
          } else {
            codeBuffer.writeln("(String? appId) {");
            codeBuffer.write(
                "${spaces(6)}if ((appId != null) && (_${firstLowerCase(spec.modelSpecification.id)}Repository[appId] == null)) { _${firstLowerCase(spec.modelSpecification.id)}Repository[appId] = ");

            String parameter;
            if (spec.modelSpecification.generate.isAppSubCollection()) {
              parameter =
                  "() => appRepository()!.getSubCollection(appId, '${FirestoreHelper.collectionId(spec.modelSpecification)}'), appId";
            } else {
              parameter = "appId";
            }
            if (spec.modelSpecification.generate.generateCache) {
              codeBuffer.writeln(
                  "${spec.modelSpecification.id}Cache(${spec.modelSpecification.id}${prefix}Firestore($parameter)); }");
            } else {
              codeBuffer.writeln(
                  "${spec.modelSpecification.id}${prefix}Firestore($parameter); }");
            }

            codeBuffer.writeln(
                "${spaces(6)}return _${firstLowerCase(spec.modelSpecification.id)}Repository[appId];");
          }
        } else {
          codeBuffer.writeln("() {");
          codeBuffer.writeln(
              "${spaces(6)}return _${firstLowerCase(spec.modelSpecification.id)}Repository;");
        }
        codeBuffer.writeln("${spaces(4)}}");
      }
    }
    codeBuffer.writeln();

    codeBuffer.writeln("}");

    return codeBuffer.toString();
  }
}
