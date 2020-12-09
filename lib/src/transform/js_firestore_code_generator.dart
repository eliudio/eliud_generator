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
        .set(value.toEntity(\${appIdDef1}).\${copyStatement}toDocument())
        .then((_) => value)\${thenStatement};
  }

  Future<void> delete(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID).delete();
  }

  Future<\${id}Model> update(\${id}Model value) {
    return \${lid}Collection.doc(value.documentID)
        .update(data: value.toEntity(\${appIdDef1}).\${copyStatement}toDocument())
        .then((_) => value)\${thenStatement};
  }

  \${id}Model _populateDoc(DocumentSnapshot value) {
    return \${id}Model.fromEntity(value.id, \${id}Entity.fromMap(value.data()));
  }

  Future<\${id}Model> _populateDocPlus(DocumentSnapshot value) async {
    return \${id}Model.fromEntityPlus(value.id, \${id}Entity.fromMap(value.data()), \${appIdDef2});
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

  @override
  StreamSubscription<List<\${id}Model>> listen(\${currentMemberString}\${id}ModelTrigger trigger, {String orderBy, bool descending }) {
    var stream;
    if (orderBy == null) {
      stream = getCollection().\${where}onSnapshot
          .map((data) {
        Iterable<\${id}Model> \${lid}s  = data.docs.map((doc) {
          \${id}Model value = _populateDoc(doc);
          return value;
        }).toList();
        return \${lid}s;
      });
    } else {
      stream = (orderBy == null ?  getCollection() : getCollection().orderBy(orderBy, descending ? 'desc': 'asc')).\${where}onSnapshot
          .map((data) {
        Iterable<\${id}Model> \${lid}s  = data.docs.map((doc) {
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
    // If we use \${lid}Collection here, then the second subscription fails
    Stream<List<\${id}Model>> stream = getCollection().\${where}onSnapshot
        .asyncMap((data) async {
      return await Future.wait(data.docs.map((doc) =>  _populateDocPlus(doc)).toList());
    });

    return stream.listen((listOf\${id}Models) {
      trigger(listOf\${id}Models);
    });
  }

  Stream<List<\${id}Model>> values(\${currentMemberString}) {
    return \${lid}Collection.\${where}onSnapshot
        .map((data) => data.docs.map((doc) => _populateDoc(doc)).toList());
  }

  Stream<List<\${id}Model>> valuesWithDetails(\${currentMemberString}) {
    return \${lid}Collection.\${where}onSnapshot
        .asyncMap((data) => Future.wait(data.docs.map((doc) => _populateDocPlus(doc)).toList()));
  }

  @override
  Future<List<\${id}Model>> valuesList(\${currentMemberString}) {
    return \${lid}Collection.\${where}get().then((value) {
      var list = value.docs;
      return list.map((doc) => _populateDoc(doc)).toList();
    });
  }

  @override
  Future<List<\${id}Model>> valuesListWithDetails(\${currentMemberString}) {
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
  CollectionReference getCollection() => firestore().collection('\${COLLECTION_ID}-\$appId');

  final String appId;
  
  \${id}JsFirestore(this.appId) : \${lid}Collection = firestore().collection('\${COLLECTION_ID}-\$appId');

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
    headerBuffer.write(importString(modelSpecifications.packageName, "model/" + modelSpecifications.repositoryFileName()));
    headerBuffer.writeln();
    extraImports(headerBuffer, ModelSpecification.IMPORT_KEY_FIRESTORE);
    headerBuffer.writeln();
    headerBuffer.writeln(base_imports(modelSpecifications.packageName, repo: true, model: true, entity: true, depends: modelSpecifications.depends));
    headerBuffer.writeln();

    return headerBuffer.toString();
  }

  @override
  String body() {
    String appVar1;
    String appVar2;
    if (!modelSpecifications.generate.isDocumentCollection && modelSpecifications.isAppModel) {
      appVar1 = appVar2 = "appId: appId";
    } else if (modelSpecifications.id == "App") {
      appVar1 = "appId: value.documentID";
      appVar2 = "appId: value.id";
    } else {
      appVar1 = appVar2 = "";
    }

    String where = "";
    if (modelSpecifications.isMemberSpecific()) {
      where = "where('readAccess', 'array-contains-any', [currentMember, 'PUBLIC']).";
    } else if (modelSpecifications.whereJs != null)
      where = modelSpecifications.whereJs + ".";

    String copyStatement = FirestoreHelper.copyWith(modelSpecifications);
    String thenStatement = FirestoreHelper.then(modelSpecifications);

    Map<String, String> parameters = <String, String>{
      '\${id}': modelSpecifications.id,
      '\${lid}': firstLowerCase(modelSpecifications.id),
      "\${where}": where,
      "\${COLLECTION_ID}": FirestoreHelper.collectionId(modelSpecifications),
      "\${appIdDef1}": appVar1,
      "\${appIdDef2}": appVar2,
      "\${copyStatement}": copyStatement,
      "\${thenStatement}": thenStatement,
      '\${currentMemberString}': modelSpecifications.isMemberSpecific() ? 'String currentMember, ' : '',
      '\${currentMemberStringValue}': modelSpecifications.isMemberSpecific() ? 'currentMember,' : '',
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

  String _id() {
    return modelSpecifications.id;
  }
}
