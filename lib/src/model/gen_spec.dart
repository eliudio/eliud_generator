import 'dart:convert';

class GenerateSpecification {
  final bool generateComponent;         // includes bloc, state and event
  final bool generateRepository;        // generate
  final bool generateCache;
  final bool generateFirestoreRepository;
  final bool generateRepositorySingleton;
  final bool hasPersistentRepository;   // not generating a firestore repository doesn't mean there is no repository. Generate a repository doesn't mean there's a persistent repository. We need to know if there is a persistent repository in some cases, such as when wanting to wipe the repository
  final bool generateModel;
  final bool generateEntity;
  final bool generateForm;              // includes bloc, state and event
  final bool generateList;              // includes bloc, state and event
  final bool generateDropDownButton;
  final bool generateInternalComponent; // generate an administrative component
  final bool generateEmbeddedComponent; // is this an embedded internal component?
  final bool isExtension;               // is this an extension, is this a component that can be added to a page
  final String? documentSubCollectionOf;   // is this a subcollection and if so of which doc?

  bool isAppSubCollection() => documentSubCollectionOf != null && documentSubCollectionOf!.toLowerCase() == "app";

  GenerateSpecification({ required this.generateComponent, required this.generateRepository, required this.generateCache, required this.hasPersistentRepository,
    required this.generateFirestoreRepository, required this.generateRepositorySingleton, required this.generateModel, required this.generateEntity,
    required this.generateForm, required this.generateList, required this.generateDropDownButton, required this.generateInternalComponent,
    required this.generateEmbeddedComponent, required this.isExtension, required this.documentSubCollectionOf
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "generateComponent": generateComponent,
      "generateRepository": generateRepository,
      "generateCache": generateCache,
      "generateFirestoreRepository": generateFirestoreRepository,
      "generateRepositorySingleton": generateRepositorySingleton,
      "hasPersistentRepository": hasPersistentRepository,
      "generateModel": generateModel,
      "generateEntity": generateEntity,
      "generateForm": generateForm,
      "generateList": generateList,
      "generateDropDownButton": generateDropDownButton,
      "generateInternalComponent": generateInternalComponent,
      "generateEmbeddedComponent": generateEmbeddedComponent,
      "isExtension": isExtension,
      "documentSubCollectionOf": documentSubCollectionOf,
    };
  }

  String toJsonString() {
    Map<String, dynamic> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [generateComponent, generateRepository, generateCache, generateFirestoreRepository, generateRepositorySingleton, hasPersistentRepository, generateModel,
    generateEntity, generateForm, generateList, generateDropDownButton, generateInternalComponent, generateEmbeddedComponent, isExtension];

  @override
  String toString() {
    return 'GenerateSpecification { generateComponent: $generateComponent, generateRepository: $generateCache: generateCache, $generateRepository, hasPersistentRepository: $hasPersistentRepository, generateFirestoreRepository: $generateFirestoreRepository, generateRepositorySingleton: $generateRepositorySingleton, generateModel: $generateModel, generateEntity: $generateEntity, generateForm: $generateForm, generateList: $generateList, generateDropDownButton: $generateDropDownButton, generateInternalComponent: $generateInternalComponent, generateEmbeddedComponent: $generateEmbeddedComponent, isExtension:$isExtension }';
  }

  static GenerateSpecification fromJson(Map<String, dynamic> json) {
    return GenerateSpecification(
        generateComponent: json["generateComponent"] as bool? ?? false,
        generateRepository: json["generateRepository"] as bool? ?? false,
        generateCache: json["generateCache"] as bool? ?? false,
        generateFirestoreRepository: json["generateFirestoreRepository"] as bool? ?? false,
        generateRepositorySingleton: json["generateRepositorySingleton"] as bool? ?? false,
        hasPersistentRepository: json["hasPersistentRepository"] as bool? ?? false,
        generateModel: json["generateModel"] as bool? ?? false,
        generateEntity: json["generateEntity"] as bool? ?? false,
        generateForm: json["generateForm"] as bool? ?? false,
        generateList: json["generateList"] as bool? ?? false,
        generateDropDownButton: json["generateDropDownButton"] as bool? ?? false,
        generateInternalComponent: json["generateInternalComponent"] as bool? ?? false,
        generateEmbeddedComponent: json["generateEmbeddedComponent"] as bool? ?? false,
        isExtension: json["isExtension"] as bool? ?? false,
        documentSubCollectionOf: json["documentSubCollectionOf"] as String?
    );
  }

  static GenerateSpecification fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
