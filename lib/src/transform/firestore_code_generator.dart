import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'firestore_helper.dart';

const String _code = """
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eliud_core_model/tools/query/query_tools.dart';
import 'package:eliud_core_model/tools/firestore/firestore_tools.dart';
import 'package:eliud_core_model/tools/common_tools.dart';

/* 
 * \${id}Firestore is the firestore implementation of \${id}Repository
 */
class \${id}Firestore implements \${id}Repository {
  /* 
   * transform a map into an entity
   */
  @override
  \${id}Entity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    return \${id}Entity.fromMap(o, newDocumentIds: newDocumentIds);
  }

  /* 
   * add an entity to the repository
   */
  Future<\${id}Entity> addEntity(String documentID, \${id}Entity value) {
    return \${lid}Collection.doc(documentID).set(value.toDocument()).then((_) => value)\${thenStatementEntity};
  }

  /* 
   * Update an entity
   */
  Future<\${id}Entity> updateEntity(String documentID, \${id}Entity value) {
    return \${lid}Collection.doc(documentID).update(value.toDocument()).then((_) => value)\${thenStatementEntity};
  }

  /* 
   * Add a model to the repository
   */
  Future<\${id}Model> add(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID).set(value.toEntity(\${appIdDef4}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  /* 
   * Delete a model
   */
  Future<void> delete(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID).delete();
  }

  /* 
   * Update a model
   */
  Future<\${id}Model> update(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID).update(value.toEntity(\${appIdDef4}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  Future<\${id}Model?> _populateDoc(DocumentSnapshot value) async {
    return \${id}Model.fromEntity(value.id, \${id}Entity.fromMap(value.data()));
  }

  Future<\${id}Model?> _populateDocPlus(DocumentSnapshot value) async {
    return \${id}Model.fromEntityPlus(value.id, \${id}Entity.fromMap(value.data()), \${appIdDef});  }

  /* 
   * Retrieve an entity from the repository with id
   */
  Future<\${id}Entity?> getEntity(String? id, {Function(Exception)? onError}) async {
    try {
      var collection = \${lid}Collection.doc(id);
      var doc = await collection.get();
      return \${id}Entity.fromMap(doc.data());
    } on Exception catch(e) {
      if (onError != null) {
        onError(e);
      } else {
        print("Error whilst retrieving \${id} with id \$id");
        print("Exceptoin: \$e");
      }
    };
  }

  /* 
   * Retrieve an model from the repository with id
   */
  Future<\${id}Model?> get(String? id, {Function(Exception)? onError}) async {
    try {
      var collection = \${lid}Collection.doc(id);
      var doc = await collection.get();
      return await _populateDocPlus(doc);
    } on Exception catch(e) {
      if (onError != null) {
        onError(e);
      } else {
        print("Error whilst retrieving \${id} with id \$id");
        print("Exceptoin: \$e");
      }
    };
  }

  /* 
   * Listen to the repository using a query. Retrieve models
   */
  StreamSubscription<List<\${id}Model?>> listen(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    Stream<List<\${id}Model?>> stream;
    stream = getQuery(\${collection}, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
//  see comment listen(...) above
//  stream = getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDoc(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  /* 
   * Listen to the repository using a query. Retrieve models and linked models
   */
  StreamSubscription<List<\${id}Model?>> listenWithDetails(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    Stream<List<\${id}Model?>> stream;
    stream = getQuery(\${collection}, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
//  see comment listen(...) above
//  stream = getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  /* 
   * Listen to 1 document in the repository
   */
  @override
  StreamSubscription<\${id}Model?> listenTo(String documentId, \${id}Changed changed, {\${id}ErrorHandler? errorHandler}) {
    var stream = \${lid}Collection.doc(documentId)
        .snapshots()
        .asyncMap((data) {
      return _populateDocPlus(data);
    });
    var theStream = stream.listen((value) {
      changed(value);
    });
    theStream.onError((theException, theStacktrace) {
      if (errorHandler != null) {
        errorHandler(theException, theStacktrace);
      }
    });
    return theStream;
  }

  /* 
   * Retrieve values/models from the repository
   */
  Stream<List<\${id}Model?>> values({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    DocumentSnapshot? lastDoc;
    Stream<List<\${id}Model?>> _values = getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  /* 
   * Retrieve values/models, including linked models, from the repository
   */
  Stream<List<\${id}Model?>> valuesWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    DocumentSnapshot? lastDoc;
    Stream<List<\${id}Model?>> _values = getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  /* 
   * Retrieve values/models from the repository
   */
  Future<List<\${id}Model?>> valuesList({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    DocumentSnapshot? lastDoc;
    List<\${id}Model?> _values = await getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.get().then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  /* 
   * Retrieve values/models, including linked models, from the repository
   */
  Future<List<\${id}Model?>> valuesListWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    DocumentSnapshot? lastDoc;
    List<\${id}Model?> _values = await getQuery(\${lid}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.get().then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  /* 
   * Flush the repository
   */
  void flush() {}

  /* 
   * Delete all entries in the repository
   */
  Future<void> deleteAll() {
    return \${lid}Collection.get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }

  /* 
   * Retrieve the subcollection of this repository
   */
  dynamic getSubCollection(String documentId, String name) {
    return \${lid}Collection.doc(documentId).collection(name);
  }

  /* 
   * Retrieve a timestamp
   */
  String? timeStampToString(dynamic timeStamp) {
    return firestoreTimeStampToString(timeStamp);
  } 

  /* 
   * change 1 a fieldvalue for 1 document  
   */
  Future<\${id}Model?> changeValue(String documentId, String fieldName, num changeByThisValue) {
    var change = FieldValue.increment(changeByThisValue);
    return \${lid}Collection.doc(documentId).update({fieldName: change}).then((v) => get(documentId));
  }

""";

/*
const String _collectionCode = """
  \${collectionFieldType}Repository app_\${lCollectionFieldType}Repository(String documentID) {
    CollectionReference reference = \${lid}Collection.document(documentID).collection("\${collectionFieldType}");
    return \${collectionFieldType}Firestore(reference);
  }
  
""";
*/

const String _footerWithoutAppID = """
  \${id}Firestore();

  final CollectionReference \${lid}Collection = FirebaseFirestore.instance.collection('\${COLLECTION_ID}');

}
""";

const String _footerWithoutCollectionParameter = """
  final String appId;
  \${id}Firestore(this.getCollection, this.appId): \${lid}Collection = getCollection();

  final CollectionReference \${lid}Collection;
  final GetCollection getCollection;
}
""";

const String _footer = """
  final String appId;
  final CollectionReference \${lid}Collection;

  \${id}Firestore(this.appId) : \${lid}Collection = FirebaseFirestore.instance.collection('\${COLLECTION_ID}');
}
""";

class FirestoreCodeGenerator extends CodeGenerator {
  FirestoreCodeGenerator({required super.modelSpecifications});

  @override
  String commonImports() {
    return FirestoreHelper.commonImports(
        extraImports2(ModelSpecification.IMPORT_KEY_FIRESTORE),
        modelSpecifications,
        "firestore");
  }

  @override
  String body() {
    String appVar;
    String appVar3;
    String appVar4;
    String collection;
    if (modelSpecifications.getIsAppModel()) {
      appVar = appVar3 = appVar4 = "appId: appId";
      collection = "getCollection()";
    } else if (modelSpecifications.id == "App") {
      appVar = "appId: value.id";
      appVar3 = "";
      appVar4 = "appId: value.documentID";
      collection = "FirebaseFirestore.instance.collection('app')";
    } else {
      appVar = appVar3 = appVar4 = "";
      collection =
          "FirebaseFirestore.instance.collection('${modelSpecifications.id.toLowerCase()}')";
    }

    String copyStatement = FirestoreHelper.copyWith(modelSpecifications);
    String thenStatement = FirestoreHelper.then(modelSpecifications);
    String thenStatementEntity =
        FirestoreHelper.thenEntity(modelSpecifications);

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${eliudQuery}": FirestoreHelper.eliudQuery(modelSpecifications),
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications),
      "\${collection}": collection,
      "\${appIdDef}": appVar,
      "\${appIdDef3}": appVar3,
      "\${appIdDef4}": appVar4,
      "\${copyStatement}": copyStatement,
      "\${thenStatement}": thenStatement,
      "\${thenStatementEntity}": thenStatementEntity,
    };
    StringBuffer headerBuffer = StringBuffer();

    headerBuffer.writeln(process(_code, parameters: parameters));

    if (modelSpecifications.generate.documentSubCollectionOf != null) {
      headerBuffer.writeln(
          process(_footerWithoutCollectionParameter, parameters: parameters));
    } else if (modelSpecifications.getIsAppModel()) {
      headerBuffer.writeln(process(_footer, parameters: parameters));
    } else {
      headerBuffer
          .writeln(process(_footerWithoutAppID, parameters: parameters));
    }

    return headerBuffer.toString();
  }

  @override
  String theFileName() {
    return modelSpecifications.firestoreFileName();
  }
}
