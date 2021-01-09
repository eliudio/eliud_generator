import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

const String _imports = """
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/common_tools.dart';
import 'package:eliud_core/tools/query/query_tools.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/access/bloc/access_bloc.dart';
""";

const String _specificImports = """
import '../\${path}_list_bloc.dart';
import '../\${path}_list.dart';
import '../\${path}_list_event.dart';
import '../\${path}_model.dart';
import '../\${path}_repository.dart';
""";

const String _InMemoryRepositoryMethod = """
static Widget \${lid}sList(BuildContext context, List<\${id}Model> values, \${id}ListChanged trigger) {
  \${id}InMemoryRepository inMemoryRepository = \${id}InMemoryRepository(
    trigger: trigger,
    items: values,
  );
  return MultiBlocProvider(
    providers: [
      BlocProvider<\${id}ListBloc>(
        create: (context) => \${id}ListBloc(
          AccessBloc.getBloc(context), 
          \${lid}Repository: inMemoryRepository,
          )..add(Load\${id}List()),
        )
        ],
    child: \${id}ListWidget(isEmbedded: true),
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

    Future<\${id}Model> add(\${id}Model value) {
        items.add(value.copyWith(documentID: newRandomKey()));
        trigger(items);
    }

    Future<void> delete(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) items.removeAt(index);
      trigger(items);
    }

    Future<\${id}Model> update(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) {
        items.replaceRange(index, index+1, [value]);
        trigger(items);
      }
    }

    Future<\${id}Model> get(String id, { Function(Exception) onError }) {
      int index = _index(id);
      var completer = new Completer<\${id}Model>();
      completer.complete(items[index]);
      return completer.future;
    }

    Stream<List<\${id}Model>> values({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
      return theValues;
    }
    
    Stream<List<\${id}Model>> valuesWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
      return theValues;
    }
    
    @override
    StreamSubscription<List<\${id}Model>> listen(trigger, { String currentMember, String orderBy, bool descending, Object startAfter, int limit, int privilegeLevel, EliudQuery eliudQuery }) {
      return theValues.listen((theList) => trigger(theList));
    }
  
    @override
    StreamSubscription<List<\${id}Model>> listenWithDetails(trigger, { String currentMember, String orderBy, bool descending, Object startAfter, int limit, int privilegeLevel, EliudQuery eliudQuery }) {
      return theValues.listen((theList) => trigger(theList));
    }
    
    void flush() {}

    Future<List<\${id}Model>> valuesList({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
      return Future.value(items);
    }
    
    Future<List<\${id}Model>> valuesListWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
      return Future.value(items);
    }

    @override
    getSubCollection(String documentId, String name) {
      throw UnimplementedError();
    }

  @override
  String timeStampToString(timeStamp) {
    throw UnimplementedError();
  }
  
  @override
  StreamSubscription<\${id}Model> listenTo(String documentId, \${id}Changed changed) {
    throw UnimplementedError();
  }
  
""";

const String _InMemoryRepositoryTemplateFooter = """
    Future<void> deleteAll() {}
}
""";

class EmbeddedComponentCodeGenerator extends CodeGeneratorMulti {
  EmbeddedComponentCodeGenerator (String fileName): super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(process(_imports));

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(process(_specificImports, parameters: <String, String> { '\${path}': spec.path }));
      }
    });

    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln("typedef " + ms.id + "ListChanged(List<" + ms.id + "Model> values);");
      }
    });
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(firstLowerCase(ms.id) + "sList(context, value, trigger) => EmbeddedComponentFactory." + firstLowerCase(ms.id) + "sList(context, value, trigger);");
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("class EmbeddedComponentFactory {");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(process(_InMemoryRepositoryMethod, parameters: <String, String> { "\${id}": ms.id,  "\${lid}": firstLowerCase(ms.id)}));
      }
    });
    codeBuffer.writeln();
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    modelSpecificationPlus.forEach((spec) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        Map<String, String> parameters = <String, String> { '\${id}': ms.id,  '\${triggerSignature}': ms.id + "ListChanged"};

        codeBuffer.writeln(process(_InMemoryRepositoryTemplate, parameters: parameters));
        codeBuffer.writeln(process(_InMemoryRepositoryTemplateFooter, parameters: parameters));
      }
    });
    return codeBuffer.toString();
  }
}
