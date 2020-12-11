import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';
import 'firestore_helper.dart';

const String _code = """
class \${id}Firestore implements \${id}Repository {
  Future<\${id}Model> add(\${id}Model value) {
    return \${id}Collection.document(value.documentID).setData(value.toEntity(\${appIdDef}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  Future<void> delete(\${id}Model value) {
    return \${id}Collection.document(value.documentID).delete();
  }

  Future<\${id}Model> update(\${id}Model value) {
    return \${id}Collection.document(value.documentID).updateData(value.toEntity(\${appIdDef}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  \${id}Model _populateDoc(DocumentSnapshot value) {
    return \${id}Model.fromEntity(value.documentID, \${id}Entity.fromMap(value.data));
  }

  Future<\${id}Model> _populateDocPlus(DocumentSnapshot value) async {
    return \${id}Model.fromEntityPlus(value.documentID, \${id}Entity.fromMap(value.data), \${appIdDef});  }

  Future<\${id}Model> get(String id) {
    return \${id}Collection.document(id).get().then((doc) {
      if (doc.data != null)
        return _populateDocPlus(doc);
      else
        return null;
    });
  }

  StreamSubscription<List<\${id}Model>> listen(\${currentMemberString}\${id}ModelTrigger trigger, { String orderBy, bool descending }) {
    Stream<List<\${id}Model>> stream;
    if (orderBy == null) {
       stream = \${id}Collection.\${where}snapshots().map((data) {
        Iterable<\${id}Model> \${lid}s  = data.documents.map((doc) {
          \${id}Model value = _populateDoc(doc);
          return value;
        }).toList();
        return \${lid}s;
      });
    } else {
      stream = \${id}Collection.orderBy(orderBy, descending: descending).\${where}snapshots().map((data) {
        Iterable<\${id}Model> \${lid}s  = data.documents.map((doc) {
          \${id}Model value = _populateDoc(doc);
          return value;
        }).toList();
        return \${lid}s;
      });
  
    }
    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  StreamSubscription<List<\${id}Model>> listenWithDetails(\${currentMemberString}\${id}ModelTrigger trigger) {
    Stream<List<\${id}Model>> stream = \${id}Collection.snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.documents.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }


  Stream<List<\${id}Model>> values(\${currentMemberString}) {
    return \${id}Collection.\${where}snapshots().map((snapshot) {
      return snapshot.documents
            .map((doc) => _populateDoc(doc)).toList();
    });
  }

  Stream<List<\${id}Model>> valuesWithDetails(\${currentMemberString}) {
    return \${id}Collection.\${where}snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.documents
          .map((doc) => _populateDocPlus(doc)).toList());
    });
  }

  Future<List<\${id}Model>> valuesList(\${currentMemberString}) async {
    return await \${id}Collection.\${where}getDocuments().then((value) {
      var list = value.documents;
      return list.map((doc) => _populateDoc(doc)).toList();
    });
  }

  Future<List<\${id}Model>> valuesListWithDetails(\${currentMemberString}) async {
    return await \${id}Collection.\${where}getDocuments().then((value) {
      var list = value.documents;
      return Future.wait(list.map((doc) =>  _populateDocPlus(doc)).toList());
    });
  }

  void flush() {}

  Future<void> deleteAll() {
    return \${id}Collection.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }});
  }

""";

const String _collectionCode = """
  \${collectionFieldType}Repository \${lCollectionFieldType}Repository(String documentID) {
    CollectionReference reference = \${id}Collection.document(documentID).collection("\${collectionFieldType}");
    return \${collectionFieldType}Firestore(reference);
  }
  
""";

const String _footerWithoutAppID = """
  \${id}Firestore();

  final CollectionReference \${id}Collection = Firestore.instance.collection('\${COLLECTION_ID}');

}
""";

const String _footerWithoutCollectionParameter = """
  \${id}Firestore(this.\${id}Collection);

  final CollectionReference \${id}Collection;
}
""";

const String _footer = """
  final String appId;
  final CollectionReference \${id}Collection;

  \${id}Firestore(this.appId) : \${id}Collection = Firestore.instance.collection('\${COLLECTION_ID}-\${appId}');
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
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.writeln();
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_FIRESTORE);
    headerBuffer.writeln(base_imports(modelSpecifications.packageName, repo: true, model: true, entity: true, depends: modelSpecifications.depends));

    headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    String appVar;
    if (!modelSpecifications.generate.isDocumentCollection && modelSpecifications.isAppModel) {
      appVar = "appId: appId";
    } else if (modelSpecifications.id == "App") {
      appVar = "appId: value.documentID";
    } else {
      appVar = "";
    }

    String where = "";
    if (modelSpecifications.isMemberSpecific()) {
      where = "where('readAccess', arrayContainsAny: ((currentMember == null) || (currentMember == \"\")) ? ['PUBLIC'] : [currentMember, 'PUBLIC']).";
    } else if (modelSpecifications.where != null) {
      where = modelSpecifications.where + ".";
    }

    String copyStatement = FirestoreHelper.copyWith(modelSpecifications);
    String thenStatement = FirestoreHelper.then(modelSpecifications);

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${where}": where,
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications),
      "\${appIdDef}": appVar,
      "\${copyStatement}": copyStatement,
      "\${thenStatement}": thenStatement,
      '\${currentMemberString}': modelSpecifications.isMemberSpecific() ? 'String currentMember, ' : '',
      '\${currentMemberStringValue}': modelSpecifications.isMemberSpecific() ? 'currentMember,' : '',
    };
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln(process(_code, parameters: parameters));

    modelSpecifications.fields.forEach((field) {
      if (field.arrayType == ArrayType.CollectionArrayType) {
        headerBuffer.writeln(process(_collectionCode,
            parameters: <String, String>{
              '\${collectionFieldType}': field.fieldType,
              '\${lCollectionFieldType}': firstLowerCase(field.fieldType),
              '\${id}': modelSpecifications.id,
              '\${lid}': firstLowerCase(modelSpecifications.id),
            }));
      }
    });

    if (modelSpecifications.generate.isDocumentCollection)
      headerBuffer.writeln(process(_footerWithoutCollectionParameter, parameters: parameters));
    else if (modelSpecifications.isAppModel)
      headerBuffer.writeln(process(_footer, parameters: parameters));
    else
      headerBuffer.writeln(process(_footerWithoutAppID, parameters: parameters));


    return headerBuffer.toString();
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
