import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';


// lid = lower case modelspecifications.id
// id = modelspecifications.id
// triggerSignature = method signature for callback

const String _imports = """
import 'component_constructor.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
""";

const String _InMemoryRepositoryMethod = """
static Widget \${lid}sList(List<\${id}Model> values, \${id}ListChanged trigger) {
  \${id}InMemoryRepository inMemoryRepository = \${id}InMemoryRepository(
    trigger: trigger,
    items: values,
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider<\${id}ListBloc>(
        create: (context) => \${id}ListBloc(
          \${lid}Repository: inMemoryRepository,
          )..add(Load\${id}List()),
        )
        ],
    child: \${id}ListWidget(),
  );
}
""";

const String _InMemoryRepositoryTemplate = """
class \${id}InMemoryRepository implements \${id}Repository {
    List<\${id}Model> items;
    \${triggerSignature} trigger;

    \${id}InMemoryRepository({this.trigger, this.items});

    Future<void> add(\${id}Model value) {
        items.add(value);
        trigger(items);
    }

    Future<void> delete(\${id}Model value) {
        items.removeAt(items.indexOf(value));
        trigger(items);
    }

    Future<void> update(\${id}Model value) {
        int index = items.indexOf(value);
        items.removeAt(index);
        items.add(value);
        trigger(items);
    }

    Future<\${id}Model> get(String id) {
        int index = int.parse(id);
        var completer = new Completer<\${id}Model>();
        completer.complete(items[index]);
        return completer.future;
    }

    Stream<List<\${id}Model>> values() {
        List<List<\${id}Model>> myList = new List<List<\${id}Model>>();
        myList.add(items);
        return Stream<List<\${id}Model>>.fromIterable(myList);
    }
}
""";

class EmbeddedComponentCodeGenerator extends CodeGeneratorMulti {
  EmbeddedComponentCodeGenerator (String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(_imports);

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln("import '../" + spec.path + ".list.bloc.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".list.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".list.event.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".model.dart';");
        codeBuffer.writeln("import '../" + spec.path + ".repository.dart';");
        codeBuffer.writeln();
      }
    });

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln("typedef " + ms.id + "ListChanged(List<" + ms.id + "Model> values);");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("class EmbeddedComponentFactory {");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        Map<String, String> parameters = Map();
        parameters['\${id}'] = ms.id;
        parameters['\${lid}'] = firstLowerCase(ms.id);
        codeBuffer.writeln(process(_InMemoryRepositoryMethod, parameters));
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        Map<String, String> parameters = Map();
        parameters['\${id}'] = ms.id;
        parameters['\${triggerSignature}'] = ms.id + "ListChanged";
        codeBuffer.writeln(process(_InMemoryRepositoryTemplate, parameters));
      }
    });
    return codeBuffer.toString();
  }
}
