import 'package:eliud_generator/src/model/field.dart';
import 'package:eliud_generator/src/model/model_spec.dart';
import 'package:eliud_generator/src/tools/tool_set.dart';

import 'code_generator.dart';
import 'data_code_generator.dart';
import 'firestore_helper.dart';

const String _code = """
class \${id}JsFirestore implements \${id}Repository {
  Future<\${id}Model> add(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID)
        .set(value.toEntity().toDocument())
        .then((_) => value);
  }

  Future<void> delete(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID).delete();
  }

  Future<\${id}Model> update(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID)
        .update(data: value.toEntity().toDocument())
        .then((_) => value);
  }

  \${id}Model _populateDoc(DocumentSnapshot doc) {
    return \${id}Model.fromEntity(doc.id, \${id}Entity.fromMap(doc.data()));
  }

  Future<\${id}Model> _populateDocPlus(DocumentSnapshot doc) async {
    return \${id}Model.fromEntityPlus(doc.id, \${id}Entity.fromMap(doc.data()));
  }

  Future<\${id}Model> get(String id) {
    return \${lid}Collection.doc(id).get().then((data) {
      if (data.data() != null) {
        return _populateDocPlus(data);
      } else {
        return null;
      }
    });
  }

  StreamSubscription<List<\${id}Model>> listen(\${id}ModelTrigger trigger) {
    // If we use \${lid}Collection here, then the second subscription fails
    Stream<List<\${id}Model>> stream = getCollection().\${where}onSnapshot
        .map((data) {
      Iterable<\${id}Model> \${lid}s  = data.docs.map((doc) {
        \${id}Model value = _populateDoc(doc);
        return value;
      }).toList();
      return \${lid}s;
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  StreamSubscription<List<\${id}Model>> listenWithDetails(\${id}ModelTrigger trigger) {
    // If we use \${lid}Collection here, then the second subscription fails
    Stream<List<\${id}Model>> stream = getCollection().\${where}onSnapshot
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  Stream<List<\${id}Model>> values() {
    return \${lid}Collection.\${where}onSnapshot
        .map((data) => data.docs.map((doc) => _populateDoc(doc)).toList());
  }

  Stream<List<\${id}Model>> valuesWithDetails() {
    return \${lid}Collection.\${where}onSnapshot
        .asyncMap((data) => Future.wait(data.docs.map((doc) => _populateDocPlus(doc)).toList()));
  }

  @override
  Future<List<\${id}Model>> valuesList() {
    return \${lid}Collection.\${where}get().then((value) {
      var list = value.docs;
      return list.map((doc) => _populateDoc(doc)).toList();
    });
  }

  @override
  Future<List<\${id}Model>> valuesListWithDetails() {
    return \${lid}Collection.\${where}get().then((value) {
      var list = value.docs;
      return Future.wait(list.map((doc) =>  _populateDocPlus(doc)).toList());
    });
  }

  void flush() {
  }
  
  Future<void> deleteAll() {
    return \${lid}Collection.get().then((snapshot) => snapshot.docs
        .forEach((element) => \${lid}Collection.doc(element.id).delete()));
  }
""";


const String _codeFooterWithoutAppId = """
  CollectionReference getCollection() => firestore().collection('\${COLLECTION_ID}');

  \${id}JsFirestore();

  final CollectionReference \${lid}Collection = firestore().collection('\${COLLECTION_ID}');
}
""";

const String _footerWithoutCollectionParameter = """
  CollectionReference getCollection() => \${lid}Collection;

  \${id}JsFirestore(this.\${lid}Collection);

  final CollectionReference \${lid}Collection;
}
""";

const String _collectionCode = """
  \${collectionFieldType}Repository \${lCollectionFieldType}Repository(String documentID) {
    CollectionReference reference = \${lid}Collection.doc(documentID).collection("\${collectionFieldType}");
    return \${collectionFieldType}JsFirestore(reference);
  }
  
""";

const String _codeFooter = """
  CollectionReference getCollection() => firestore().collection('\${COLLECTION_ID}-\$appID');

  final String appID;
  
  \${id}JsFirestore(this.appID) : \${lid}Collection = firestore().collection('\${COLLECTION_ID}-\$appID');

  final CollectionReference \${lid}Collection;
}
""";

class JsFirestoreCodeGenerator extends CodeGenerator {
  JsFirestoreCodeGenerator({ModelSpecification modelSpecifications})
      : super(modelSpecifications: modelSpecifications);

  @override
  String commonImports() {
    StringBuffer headerBuffer = StringBuffer();
    headerBuffer.writeln("import 'dart:async';");
    headerBuffer.writeln("import 'package:firebase/firebase.dart';");
    headerBuffer.writeln("import 'package:firebase/firestore.dart';");
    headerBuffer.writeln("import '" + modelSpecifications.repositoryFileName() + "';");
    headerBuffer.writeln();
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_FIRESTORE);
    headerBuffer.writeln();
    headerBuffer.writeln(base_imports(repo: true, model: true, entity: true, depends: modelSpecifications.depends));
    headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    String where = "";
    if (modelSpecifications.whereJs != null)
      where = modelSpecifications.whereJs + ".";

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${where}": where,
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications)
    };

    StringBuffer bodyBuffer = StringBuffer();
    bodyBuffer.write(process(_code, parameters: parameters));

    modelSpecifications.fields.forEach((field) {
      if (field.arrayType == ArrayType.CollectionArrayType) {
        bodyBuffer.writeln(process(_collectionCode,
            parameters: <String, String>{
              '\${collectionFieldType}': field.fieldType,
              '\${lCollectionFieldType}': firstLowerCase(field.fieldType),
              '\${id}': modelSpecifications.id,
              '\${lid}': firstLowerCase(modelSpecifications.id),
            }));
      }
    });

    if (modelSpecifications.generate.isDocumentCollection)
      bodyBuffer.writeln(process(_footerWithoutCollectionParameter, parameters: parameters));
    else if (modelSpecifications.isAppModel)
      bodyBuffer.write(process(_codeFooter, parameters: parameters));
    else
      bodyBuffer.write(process(_codeFooterWithoutAppId, parameters: parameters));

    return bodyBuffer.toString();
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
