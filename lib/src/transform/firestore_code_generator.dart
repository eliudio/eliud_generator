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
  @override
  \${id}Entity? fromMap(Object? o, {Map<String, String>? newDocumentIds}) {
    return \${id}Entity.fromMap(o, newDocumentIds: newDocumentIds);
  }

  Future<\${id}Entity> addEntity(String documentID, \${id}Entity value) {
    return \${id}Collection.doc(documentID).set(value.toDocument()).then((_) => value)\${thenStatementEntity};
  }

  Future<\${id}Entity> updateEntity(String documentID, \${id}Entity value) {
    return \${id}Collection.doc(documentID).update(value.toDocument()).then((_) => value)\${thenStatementEntity};
  }

  Future<\${id}Model> add(\${id}Model value) {
    return \${id}Collection.doc(value.documentID).set(value.toEntity(\${appIdDef4}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  Future<void> delete(\${id}Model value) {
    return \${id}Collection.doc(value.documentID).delete();
  }

  Future<\${id}Model> update(\${id}Model value) {
    return \${id}Collection.doc(value.documentID).update(value.toEntity(\${appIdDef4}).\${copyStatement}toDocument()).then((_) => value)\${thenStatement};
  }

  Future<\${id}Model?> _populateDoc(DocumentSnapshot value) async {
    return \${id}Model.fromEntity(value.id, \${id}Entity.fromMap(value.data()));
  }

  Future<\${id}Model?> _populateDocPlus(DocumentSnapshot value) async {
    return \${id}Model.fromEntityPlus(value.id, \${id}Entity.fromMap(value.data()), \${appIdDef});  }

  Future<\${id}Entity?> getEntity(String? id, {Function(Exception)? onError}) async {
    try {
      var collection = \${id}Collection.doc(id);
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

  Future<\${id}Model?> get(String? id, {Function(Exception)? onError}) async {
    try {
      var collection = \${id}Collection.doc(id);
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

  StreamSubscription<List<\${id}Model?>> listen(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    Stream<List<\${id}Model?>> stream;
    stream = getQuery(\${collection}, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
//  see comment listen(...) above
//  stream = getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDoc(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  StreamSubscription<List<\${id}Model?>> listenWithDetails(\${id}ModelTrigger trigger, {String? orderBy, bool? descending, Object? startAfter, int? limit, int? privilegeLevel, EliudQuery? eliudQuery}) {
    Stream<List<\${id}Model?>> stream;
    stream = getQuery(\${collection}, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
//  see comment listen(...) above
//  stream = getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots()
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  @override
  StreamSubscription<\${id}Model?> listenTo(String documentId, \${id}Changed changed, {\${id}ErrorHandler? errorHandler}) {
    var stream = \${id}Collection.doc(documentId)
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

  Stream<List<\${id}Model?>> values({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    DocumentSnapshot? lastDoc;
    Stream<List<\${id}Model?>> _values = getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Stream<List<\${id}Model?>> valuesWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) {
    DocumentSnapshot? lastDoc;
    Stream<List<\${id}Model?>> _values = getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?, limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.snapshots().asyncMap((snapshot) {
      return Future.wait(snapshot.docs.map((doc) {
        lastDoc = doc;
        return _populateDocPlus(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Future<List<\${id}Model?>> valuesList({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    DocumentSnapshot? lastDoc;
    List<\${id}Model?> _values = await getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.get().then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) {
        lastDoc = doc;
        return _populateDoc(doc);
      }).toList());
    });
    if ((setLastDoc != null) && (lastDoc != null)) setLastDoc(lastDoc);
    return _values;
  }

  Future<List<\${id}Model?>> valuesListWithDetails({String? orderBy, bool? descending, Object? startAfter, int? limit, SetLastDoc? setLastDoc, int? privilegeLevel, EliudQuery? eliudQuery }) async {
    DocumentSnapshot? lastDoc;
    List<\${id}Model?> _values = await getQuery(\${id}Collection, orderBy: orderBy,  descending: descending,  startAfter: startAfter as DocumentSnapshot?,  limit: limit, privilegeLevel: privilegeLevel, eliudQuery: \${eliudQuery}, \${appIdDef3})!.get().then((value) {
      var list = value.docs;
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
    return \${id}Collection.get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs){
        ds.reference.delete();
      }
    });
  }

  dynamic getSubCollection(String documentId, String name) {
    return \${id}Collection.doc(documentId).collection(name);
  }

  String? timeStampToString(dynamic timeStamp) {
    return firestoreTimeStampToString(timeStamp);
  } 

  Future<\${id}Model?> changeValue(String documentId, String fieldName, num changeByThisValue) {
    var change = FieldValue.increment(changeByThisValue);
    return \${id}Collection.doc(documentId).update({fieldName: change}).then((v) => get(documentId));
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

  final CollectionReference \${id}Collection = FirebaseFirestore.instance.collection('\${COLLECTION_ID}');

}
""";

const String _footerWithoutCollectionParameter = """
  final String appId;
  \${id}Firestore(this.getCollection, this.appId): \${id}Collection = getCollection();

  final CollectionReference \${id}Collection;
  final GetCollection getCollection;
}
""";

const String _footer = """
  final String appId;
  final CollectionReference \${id}Collection;

  \${id}Firestore(this.appId) : \${id}Collection = FirebaseFirestore.instance.collection('\${COLLECTION_ID}');
}
""";

class FirestoreCodeGenerator extends CodeGenerator {
  FirestoreCodeGenerator({required ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    return FirestoreHelper.commonImports(extraImports2(ModelSpecification.IMPORT_KEY_FIRESTORE), modelSpecifications, "firestore");
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
      //"appRepository()!.getSubCollection(appId, '" + modelSpecifications.id.toLowerCase() + "')";
    } else if (modelSpecifications.id == "App") {
      appVar = "appId: value.id";
      appVar3 = "";
      appVar4 = "appId: value.documentID";
      collection = "FirebaseFirestore.instance.collection('app')";
    } else {
      appVar = appVar3 = appVar4 = "";
      collection = "FirebaseFirestore.instance.collection('" + modelSpecifications.id.toLowerCase() + "')";
    }

    String copyStatement = FirestoreHelper.copyWith(modelSpecifications);
    String thenStatement = FirestoreHelper.then(modelSpecifications);
    String thenStatementEntity = FirestoreHelper.thenEntity(modelSpecifications);

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${eliudQuery}": FirestoreHelper.eliudQuery(modelSpecifications),
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications),
      "\${collection}" : collection,
      "\${appIdDef}": appVar,
      "\${appIdDef3}": appVar3,
      "\${appIdDef4}": appVar4,
      "\${copyStatement}": copyStatement,
      "\${thenStatement}": thenStatement,
      "\${thenStatementEntity}": thenStatementEntity,
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
    if (modelSpecifications.generate.documentSubCollectionOf != null)
      headerBuffer.writeln(process(_footerWithoutCollectionParameter, parameters: parameters));
    else if (modelSpecifications.getIsAppModel())
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
