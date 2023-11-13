import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator_multi.dart';

const String _imports = """
import 'package:eliud_core/tools/random.dart';
import 'package:eliud_core/tools/common_tools.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/model/app_model.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eliud_core/core/blocs/access/access_bloc.dart';
""";

const String _specificImports = """
import '../\${path}_list_bloc.dart';
import '../\${path}_list.dart';
import '../\${path}_list_event.dart';
import '../\${path}_model.dart';
import '../\${path}_entity.dart';
import '../\${path}_repository.dart';
""";

const String _InMemoryRepositoryMethod = """
/* 
 * \${lid}sList function to construct a list of \${id}Model
 */
static Widget \${lid}sList(AppModel app, BuildContext context, List<\${id}Model> values, \${id}ListChanged trigger) {
  \${id}InMemoryRepository inMemoryRepository = \${id}InMemoryRepository(trigger, values,);
  return MultiBlocProvider(
    providers: [
      BlocProvider<\${id}ListBloc>(
        create: (context) => \${id}ListBloc(
          \${lid}Repository: inMemoryRepository,
          )..add(Load\${id}List()),
        )
        ],
    child: \${id}ListWidget(app: app, isEmbedded: true),
  );
}
""";

const String _InMemoryRepositoryTemplate = """
/* 
 * \${id}InMemoryRepository is an in memory implementation of \${id}Repository
 */
class \${id}InMemoryRepository implements \${id}Repository {
    final List<\${id}Model> items;
    final \${triggerSignature} trigger;
    Stream<List<\${id}Model>>? theValues;

    /* 
     * Construct the \${id}InMemoryRepository
     */
    \${id}InMemoryRepository(this.trigger, this.items) {
        List<List<\${id}Model>> myList = <List<\${id}Model>>[];
        if (items != null) myList.add(items);
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

    /* 
     * Add an entity
     */
    Future<\${id}Entity> addEntity(String documentID, \${id}Entity value) {
      throw Exception('Not implemented'); 
    }

    /* 
     * Update an entity
     */
    Future<\${id}Entity> updateEntity(String documentID, \${id}Entity value) {
      throw Exception('Not implemented'); 
    }

    /* 
     * Update a model
     */
    Future<\${id}Model> add(\${id}Model value) {
        items.add(value.copyWith(documentID: newRandomKey()));
        trigger(items);
        return Future.value(value);
    }

    /* 
     * Delete a model
     */
    Future<void> delete(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) items.removeAt(index);
      trigger(items);
      return Future.value();
    }

    /* 
     * Update a model
     */
    Future<\${id}Model> update(\${id}Model value) {
      int index = _index(value.documentID);
      if (index >= 0) {
        items.replaceRange(index, index+1, [value]);
        trigger(items);
      }
      return Future.value(value);
    }

    /* 
     * Get a model
     */
    Future<\${id}Model> get(String? id, { Function(Exception)? onError }) {
      int index = _index(id!);
      var completer = new Completer<\${id}Model>();
      completer.complete(items[index]);
      return completer.future;
    }

    /* 
     * Retrieve to a list of \${id}Model base on a query
     */
    Stream<List<\${id}Model>> values({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return theValues!;
    }
    
    /* 
     * Retrieve to a list of \${id}Model, including linked models base on a query
     */
    Stream<List<\${id}Model>> valuesWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return theValues!;
    }
    
    /* 
     * Subscribe to a list of \${id}Model base on a query
     */
    @override
    StreamSubscription<List<\${id}Model>> listen(trigger, { String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return theValues!.listen((theList) => trigger(theList));
    }
  
    /* 
     * Subscribe to a list of \${id}Model, including linked models, base on a query
     */
    @override
    StreamSubscription<List<\${id}Model>> listenWithDetails(trigger, { String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return theValues!.listen((theList) => trigger(theList));
    }
    
    /* 
     * Flush the repository
     */
    void flush() {}

    /* 
     * Retrieve the list of models
     */
    Future<List<\${id}Model>> valuesList({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return Future.value(items);
    }
    
    Future<List<\${id}Model>> valuesListWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
      return Future.value(items);
    }

    /* 
     * Retrieve a subcollection of this collection
     */
    @override
    getSubCollection(String documentId, String name) {
      throw UnimplementedError();
    }

  /* 
   * Retrieve a timestamp
   */
  @override
  String timeStampToString(timeStamp) {
    throw UnimplementedError();
  }
  
  /* 
   * Subscribe to 1 document / 1 model
   */
  @override
  StreamSubscription<\${id}Model> listenTo(String documentId, \${id}Changed changed, {\${id}ErrorHandler? errorHandler}) {
    throw UnimplementedError();
  }

  @override
  Future<\${id}Model> changeValue(String documentId, String fieldName, num changeByThisValue) {
    throw UnimplementedError();
  }
  
  @override
  Future<\${id}Entity?> getEntity(String? id, {Function(Exception p1)? onError}) {
    throw UnimplementedError();
  }

  @override
  \${id}Entity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    throw UnimplementedError();
  }
""";

const String _InMemoryRepositoryTemplateFooter = """
    Future<void> deleteAll() async {}
}
""";

class EmbeddedComponentCodeGenerator extends CodeGeneratorMulti {
  EmbeddedComponentCodeGenerator(String fileName) : super(fileName: fileName);

  @override
  String getCode(List<ModelSpecificationPlus> modelSpecificationPlus) {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(header());
    codeBuffer.writeln(process(_imports));

    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(process(_specificImports,
            parameters: <String, String>{'\${path}': spec.path}));
      }
    }

    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(
            "typedef ${ms.id}ListChanged(List<${ms.id}Model> values);");
      }
    }
    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(
            "${firstLowerCase(ms.id)}sList(app, context, value, trigger) => EmbeddedComponentFactory.${firstLowerCase(ms.id)}sList(app, context, value, trigger);");
      }
    }
    codeBuffer.writeln();
    codeBuffer.writeln("class EmbeddedComponentFactory {");
    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        codeBuffer.writeln(process(_InMemoryRepositoryMethod,
            parameters: <String, String>{
              "\${id}": ms.id,
              "\${lid}": firstLowerCase(ms.id)
            }));
      }
    }
    codeBuffer.writeln();
    codeBuffer.writeln("}");
    codeBuffer.writeln();
    for (var spec in modelSpecificationPlus) {
      ModelSpecification ms = spec.modelSpecification;
      if (ms.generate.generateEmbeddedComponent) {
        Map<String, String> parameters = <String, String>{
          '\${id}': ms.id,
          '\${triggerSignature}': "${ms.id}ListChanged"
        };

        codeBuffer.writeln(
            process(_InMemoryRepositoryTemplate, parameters: parameters));
        codeBuffer.writeln(
            process(_InMemoryRepositoryTemplateFooter, parameters: parameters));
      }
    }
    return codeBuffer.toString();
  }
}
