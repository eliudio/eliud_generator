import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

const String _code = """
class \${id}Firestore implements \${id}Repository {
  final \${id}Collection = Firestore.instance.collection('\${id}s');

  \${id}Firestore();

  Future<\${id}Model> add(\${id}Model value) {
    return \${id}Collection.document(value.documentID).setData(value.toEntity().toDocument()).then((_) => value);
  }

  Future<void> delete(\${id}Model value) {
    return \${id}Collection.document(value.documentID).delete();
  }

  Future<\${id}Model> update(\${id}Model value) {
    return \${id}Collection.document(value.documentID).updateData(value.toEntity().toDocument()).then((_) => value);
  }

  Future<void> deleteAll() {
    return \${id}Collection.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});
  }

  \${id}Model _populateDoc(DocumentSnapshot doc) {
    return \${id}Model.fromEntity(doc.documentID, \${id}Entity.fromMap(doc.data));
  }

  Future<\${id}Model> _populateDocPlus(DocumentSnapshot doc) async {
    return \${id}Model.fromEntityPlus(doc.documentID, \${id}Entity.fromMap(doc.data));  }

  Future<\${id}Model> get(String id) {
    return \${id}Collection.document(id).get().then((doc) {
      if (doc.data != null)
        return _populateDocPlus(doc);
      else
        return null;
    });
  }

  void listen(\${id}ModelTrigger trigger) {
    \${id}Collection.snapshots().listen((event) {
      trigger();
    });
  }

  Stream<List<\${id}Model>> values() {
    return \${id}Collection.snapshots().map((snapshot) {
      return snapshot.documents
            .map((doc) => _populateDoc(doc)).toList();
    });
  }

  Future<List<\${id}Model>> valuesList() async {
    return await \${id}Collection.getDocuments().then((value) {
      var list = value.documents;
      return list.map((doc) => _populateDoc(doc)).toList();
    });
  }

  void flush() {}
}
""";

class FirestoreCodeGenerator extends CodeGenerator {
  FirestoreCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:cloud_firestore/cloud_firestore.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.repositoryFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.modelFileName()) + "';");
    headerBuffer.writeln("import '" + resolveImport(importThis: modelSpecifications.entityFileName()) + "';");
    headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    return process(_code, parameters: <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
    });
  }

  @override
  String theFileName() {
    return modelSpecifications.firestoreFileName();
  }

  String _collectionName() {
    return firstLowerCase(_id()) + "Collection";
  }

  String _id() {
    return modelSpecifications.id;
  }
}
