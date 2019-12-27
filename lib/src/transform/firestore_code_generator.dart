import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';

class FirestoreCodeGenerator extends CodeGenerator {
  FirestoreCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:cloud_firestore/cloud_firestore.dart';");
    if (!uniqueAssociationTypes.isEmpty) headerBuffer.writeln("import 'package:flutter/cupertino.dart';");
    headerBuffer.writeln();
    headerBuffer.writeln("import '" + modelSpecifications.repositoryFileName() + "';");
    headerBuffer.writeln("import '" + modelSpecifications.modelFileName() + "';");
    headerBuffer.writeln("import '" + modelSpecifications.entityFileName() + "';");
    headerBuffer.writeln();
    uniqueAssociationTypes.forEach((type) {
      headerBuffer.writeln("import '" + camelcaseToUnderscore(type) + ".repository.dart" + "';");
    });

    if (!uniqueAssociationTypes.isEmpty) headerBuffer.writeln();
    return headerBuffer.toString();
  }

  String _dataMembers() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "final " + _collectionName() + " = Firestore.instance.collection('" + _id() + "');");

    uniqueAssociationTypes.forEach((field) {
      codeBuffer.writeln(spaces(2)+ "final " + field + "Repository " + firstLowerCase(field) + "Repository;");
    });

    return codeBuffer.toString();
  }

  String _constructor() {
    if (uniqueAssociationTypes.isEmpty) return "";

    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.write(spaces(2) + modelSpecifications.firestoreClassName() + "({");
    uniqueAssociationTypes.forEach((field) {
      codeBuffer.write("@required this." + firstLowerCase(field) + "Repository, ");
    });
    codeBuffer.writeln("});");

    return codeBuffer.toString();
  }

  String _add() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<void> add(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.id).setData(value.toEntity().toDocument());");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _delete() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<void> delete(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.id).delete();");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _update() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<void> update(" + modelSpecifications.modelClassName() + " value) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(value.id).updateData(value.toEntity().toDocument());");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _populateDoc() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + modelSpecifications.modelClassName() + " _populateDoc(DocumentSnapshot doc) {");
    codeBuffer.writeln(spaces(4) + "return " + modelSpecifications.modelClassName() + ".fromEntity(" + _id() + "Entity.fromMap(doc.data));");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _populateDocPlus() {
    if (uniqueAssociationTypes.isEmpty) return "";

    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> _populateDocPlus(DocumentSnapshot doc) async {");
    codeBuffer.write(spaces(4) + "return " + modelSpecifications.modelClassName() + ".fromEntityPlus(" + _id() + "Entity.fromMap(doc.data)");

    uniqueAssociationTypes.forEach((field) {
      codeBuffer.write(", " + firstLowerCase(field) + "Repository");
    });

    codeBuffer.writeln(");");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _get() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Future<" + modelSpecifications.modelClassName() + "> get(String id) {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".document(id).get().then((doc) {");
    codeBuffer.writeln(spaces(6) + "if (doc.data != null)");
    if (!uniqueAssociationTypes.isEmpty)
      codeBuffer.writeln(spaces(6) + "return _populateDocPlus(doc);");
    else
      codeBuffer.writeln(spaces(6) + "return _populateDoc(doc);");
    codeBuffer.writeln(spaces(6) + "else return null;");
    codeBuffer.writeln(spaces(4) + "});");
    codeBuffer.writeln(spaces(2) + "}");
    return codeBuffer.toString();
  }

  String _values() {
    StringBuffer codeBuffer = StringBuffer();
    codeBuffer.writeln(spaces(2) + "Stream<List<" + modelSpecifications.modelClassName() + ">> values() {");
    codeBuffer.writeln(spaces(4) + "return " + _collectionName() + ".snapshots().map((snapshot) {");
    codeBuffer.writeln(spaces(6) + "return snapshot.documents");
    codeBuffer.writeln(spaces(12) + ".map((doc) => _populateDoc(doc));");
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
    codeBuffer.writeln(_populateDoc());
    codeBuffer.writeln(_populateDocPlus());
    codeBuffer.writeln(_get());
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
