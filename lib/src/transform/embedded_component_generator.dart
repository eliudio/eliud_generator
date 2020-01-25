import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';


// lid = lower case modelspecifications.id
// id = modelspecifications.id
// triggerSignature = method signature for callback

const String _imports = """
import '../tools/random.dart';

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
    final List<\${id}Model> items;
    final \${triggerSignature} trigger;
    Stream<List<\${id}Model>> theValues;

    \${id}InMemoryRepository({this.trigger, this.items}) {
        List<List<\${id}Model>> myList = new List<List<\${id}Model>>();
        myList.add(items);
        theValues = Stream<List<\${id}Model>>.fromIterable(myList);
    }

    int _index(String documentID) {
      int i = 0;
      for (final item in items) {
        if (item.documentID == documentID) {
          return i;
        }
        i++;
      }
      return -1;
    }

    Future<void> add(\${id}Model value) {
        items.add(value.copyWith(documentID: newRandomKey()));
        trigger(items);
    }

    Future<void> delete(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) items.removeAt(index);
      trigger(items);
    }

    Future<void> update(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) {
        items.replaceRange(index, index+1, [value]);
        trigger(items);
      }
    }

    Future<\${id}Model> get(String id) {
      int index = _index(id);
      var completer = new Completer<\${id}Model>();
      completer.complete(items[index]);
      return completer.future;
    }

    Stream<List<\${id}Model>> values() {
      return theValues;
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
