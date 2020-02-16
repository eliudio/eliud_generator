import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';

const String _imports = """
import 'dart:async';
import '\${filename}.model.dart';
import '\${filename}.repository.dart';

""";

const String _code = """
class \${id}Cache implements \${id}Repository {
  final \${id}Repository reference;
  final Map<String, \${id}Model> fullCache = Map();

  \${id}Cache(this.reference);

  Future<void> add(\${id}Model value) {
    fullCache[value.documentID] = value;
    reference.add(value);
    return Future.value();
  }

  Future<void> delete(\${id}Model value){
    fullCache.remove(value.documentID);
    reference.delete(value);
    return Future.value();
  }

  Future<\${id}Model> get(String id){
    \${id}Model value = fullCache[id];
    if (value != null) return Future.value(value);
    return reference.get(id).then((value) {
      fullCache[id] = value;
      return value;
    });
  }

  Future<void> update(\${id}Model value) {
    fullCache[value.documentID] = value;
    reference.update(value);
    return Future.value();
  }

  Stream<List<\${id}Model>> values() {
    return reference.values();
  }

\${listen}

  void flush() {
    fullCache.clear();
  }
  
  Future<void> deleteAll() {
    return reference.deleteAll();
  }
}

""";

class CacheCodeGenerator extends CodeGenerator {
  CacheCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln(process(_imports, parameters: <String, String> { '\${filename}': camelcaseToUnderscore(modelSpecifications.id) }));
    return headerBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    String listen;
    if (modelSpecifications.generate.generateCache) {
      StringBuffer listenBuffer = StringBuffer();
      listenBuffer.writeln("void listen(" + modelSpecifications.modelClassName() + "Trigger trigger) {");
      listenBuffer.writeln("reference.listen(trigger);");
      listenBuffer.writeln("}");
      listen = listenBuffer.toString();
    } else {
      listen = "";
    }
    codeBuffer.writeln(process(_code, parameters: <String, String> { '\${id}': modelSpecifications.id, '\${listen}' : listen }));
    return codeBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.repositoryFileName();
  }
}
