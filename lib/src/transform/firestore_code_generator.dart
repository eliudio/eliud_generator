import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';
import 'firestore_helper.dart';

const String _code = """
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eliud_core/tools/query/query_tools.dart';
import 'package:eliud_core/tools/firestore/firestore_tools.dart';
import 'package:eliud_core/tools/common_tools.dart';

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

  StreamSubscription<List<\${id}Model>> listen(\${id}ModelTrigger trigger, {String currentMember, String orderBy, bool descending, Object startAfter, int limit, int privilegeLevel, EliudQuery eliudQuery}) {
    Stream<List<\${id}Model>> stream;
    stream = getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).snapshots().map((data) {
      Iterable<\${id}Model> \${lid}s  = data.documents.map((doc) {
        \${id}Model value = _populateDoc(doc);
        return value;
      }).toList();
      return \${lid}s;
    });
    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  StreamSubscription<List<\${id}Model>> listenWithDetails(\${id}ModelTrigger trigger, {String currentMember, String orderBy, bool descending, Object startAfter, int limit, int privilegeLevel, EliudQuery eliudQuery}) {
    Stream<List<\${id}Model>> stream;
    stream = getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.documents.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  @override
  StreamSubscription<\${id}Model> listenTo(String documentId, \${id}Changed changed) {
    var stream = \${id}Collection.document(documentId)
        .snapshots()
        .asyncMap((data) {
      return _populateDocPlus(data);
    });
    return stream.listen((value) {
      changed(value);
    });
  }

  Stream<List<\${id}Model>> values({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
    DocumentSnapshot lastDoc;
    Stream<List<\${id}Model>> _values = getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).snapshots().map((snapshot) {
      return snapshot.documents.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList();});
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Stream<List<\${id}Model>> valuesWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) {
    DocumentSnapshot lastDoc;
    Stream<List<\${id}Model>> _values = getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.documents.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Future<List<\${id}Model>> valuesList({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) async {
    DocumentSnapshot lastDoc;
    List<\${id}Model> _values = await getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).getDocuments().then((value) {
      var list = value.documents;
      return list.map((doc) { 
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList();
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Future<List<\${id}Model>> valuesListWithDetails({String currentMember, String orderBy, bool descending, Object startAfter, int limit, SetLastDoc setLastDoc, int privilegeLevel, EliudQuery eliudQuery }) async {
    DocumentSnapshot lastDoc;
    List<\${id}Model> _values = await getQuery(\${id}Collection, currentMember: currentMember, orderBy: orderBy,  descending: descending,  startAfter: startAfter,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3}).getDocuments().then((value) {
      var list = value.documents;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  void flush() {}

  Future<void> deleteAll() {
    return \${id}Collection.getDocuments().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.documents){
        ds.reference.delete();
      }
    });
  }

  dynamic getSubCollection(String documentId, String name) {
    return \${id}Collection.document(documentId).collection(name);
  }

  String timeStampToString(dynamic timeStamp) {
    return firestoreTimeStampToString(timeStamp);
  } 
""";

/*
const String _collectionCode = """
  \${collectionFieldType}Repository app_\${lCollectionFieldType}Repository(String documentID) {
    CollectionReference reference = \${id}Collection.document(documentID).collection("\${collectionFieldType}");
    return \${collectionFieldType}Firestore(reference);
  }
  
""";
*/

const String _footerWithoutAppID = """
  \${id}Firestore();

  final CollectionReference \${id}Collection = Firestore.instance.collection('\${COLLECTION_ID}');

}
""";

const String _footerWithoutCollectionParameter = """
  final String appId;
  \${id}Firestore(this.\${id}Collection, this.appId);

  final CollectionReference \${id}Collection;
}
""";

const String _footer = """
  final String appId;
  final CollectionReference \${id}Collection;

  \${id}Firestore(this.appId) : \${id}Collection = Firestore.instance.collection('\${COLLECTION_ID}');
}
""";

class FirestoreCodeGenerator extends CodeGenerator {
  FirestoreCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    return FirestoreHelper.commonImports(extraImports2(ModelSpecification.IMPORT_KEY_FIRESTORE), modelSpecifications, "firestore");
  }

  @override
  String body() {
    String appVar;
    String appVar3;
    if (modelSpecifications.isAppModel) {
      appVar = appVar3 = "appId: appId";
    } else if (modelSpecifications.id == "App") {
      appVar = "appId: value.documentID";
      appVar3 = "";
    } else {
      appVar = appVar3 = "";
    }

    String copyStatement = FirestoreHelper.copyWith(modelSpecifications);
    String thenStatement = FirestoreHelper.then(modelSpecifications);

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${eliudQuery}": FirestoreHelper.eliudQuery(modelSpecifications),
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications),
      "\${appIdDef}": appVar,
      "\${appIdDef3}": appVar3,
      "\${copyStatement}": copyStatement,
      "\${thenStatement}": thenStatement,
    };
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln(process(_code, parameters: parameters));

/*
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

*/
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
