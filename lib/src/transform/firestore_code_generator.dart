import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

const String _wipeCode = """
  Future<void> deleteAll() {
    return \${lid}Collection.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});
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

  String _dataMembers() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "final " + _collectionName() + " = Firestore.instance.collection('" + firstLowerCase(_id()) + "s');");
    return codeBuffer.toString();
  }

  String _constructor() {
    if (uniqueAssociationTypes.isEmpty) return "";

    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.firestoreClassName() + "();");

    return codeBuffer.toString();
  }

  String _add() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> add(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.documentID).setData(value.toEntity().toDocument()).then((_) => value);");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _delete() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<void> delete(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.documentID).delete();");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _wipe() {
    return process(_wipeCode, parameters: <String, String>{
      '\${lid}': firstLowerCase(modelSpecifications.id),
    });
  }

  String _update() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> update(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.documentID).updateData(value.toEntity().toDocument()).then((_) => value);");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _populateDoc() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.modelClassName() + " _populateDoc(DocumentSnapshot doc) {");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.modelClassName() + ".fromEntity(doc.documentID, " + _id() + "Entity.fromMap(doc.data));");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _populateDocPlus() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> _populateDocPlus(DocumentSnapshot doc) async {");
    codeBuffer.write(spaces(4) + "return " + modelSpecifications.modelClassName() + ".fromEntityPlus(doc.documentID, " + _id() + "Entity.fromMap(doc.data));");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _get() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> get(String id) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(id).get().then((doc) {");
    codeBuffer.writeln(spaces(6) + "if (doc.data != null)");
    codeBuffer.writeln(spaces(8) + "return _populateDocPlus(doc);");
    codeBuffer.writeln(spaces(6) + "else");
    codeBuffer.writeln(spaces(8) + "return null;");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _values() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Stream<List<" + modelSpecifications.modelClassName() + ">> values() {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".snapshots().map((snapshot) {");
    codeBuffer.writeln(spaces(6) + "return snapshot.documents");
    codeBuffer.writeln(spaces(12) + ".map((doc) => _populateDoc(doc)).toList();");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _listen() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "void listen(" + modelSpecifications.modelClassName() + "Trigger trigger) {");
    codeBuffer.writeln(spaces(4) + _collectionName() + ".snapshots().listen((event) {");
    codeBuffer.writeln(spaces(6) + "trigger();");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");

    return codeBuffer.toString();
  }

  @override
  String body() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln("class " + modelSpecifications.firestoreClassName() + " implements " + modelSpecifications.repositoryClassName() + " {");

    codeBuffer.writeln(_dataMembers());
    codeBuffer.writeln(_constructor());
    codeBuffer.writeln(_add());
    codeBuffer.writeln(_delete());
    codeBuffer.writeln(_update());
    codeBuffer.writeln(_wipe());
    codeBuffer.writeln(_populateDoc());
    codeBuffer.writeln(_populateDocPlus());
    codeBuffer.writeln(_get());
    codeBuffer.writeln(_listen());
    codeBuffer.writeln(_values());

    codeBuffer.writeln("}");
    return codeBuffer.toString();
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

  /*
  Example code for search:
  Future<MenuModel> searchMenuWithID(String id) async {
    return await menuCollection
        .where("id", isEqualTo: id)
        .getDocuments().then((data) =>
          data.documents.map((doc) =>
              MenuModel.fromEntity(MenuEntity.fromMap(doc.data))
          ).iterator.current);
  }
  */
}
