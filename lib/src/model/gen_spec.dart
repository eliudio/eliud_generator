import 'dart:convert';

class GenerateSpecification {
  final bool generateComponent;         // includes bloc, state and event
  final bool generateRepository;        // generate
  final bool generateCache;
  final bool generateFirestoreRepository;
  final bool hasPersistentRepository;   // not generating a firestore repository doesn't mean there is no repository. Generate a repository doesn't mean there's a persistent repository. We need to know if there is a persistent repository in some cases, such as when wanting to wipe the repository
  final bool generateModel;
  final bool generateEntity;
  final bool generateForm;              // includes bloc, state and event
  final bool generateList;              // includes bloc, state and event
  final bool generateDropDownButton;
  final bool generateInternalComponent; // generate an administrative component
  final bool generateEmbeddedComponent; // is this an embedded internal component?
  final bool isExtension;               // is this an extension, is this a component that can be added to a page
  final bool isDocumentCollection;      // is this a collection within a document, or is this a collection that stands on it's own, e.g. StripeCustomer (false) has Payments (true)

  GenerateSpecification({ this.generateComponent, this.generateRepository, this.generateCache, this.hasPersistentRepository,
    this.generateFirestoreRepository, this.generateModel, this.generateEntity,
    this.generateForm, this.generateList, this.generateDropDownButton, this.generateInternalComponent,
    this.generateEmbeddedComponent, this.isExtension, this.isDocumentCollection
  });

  Map<String, Object> toJson() {
    return <String, dynamic>{
      "generateComponent": generateComponent,
      "generateRepository": generateRepository,
      "generateCache": generateCache,
      "generateFirestoreRepository": generateFirestoreRepository,
      "hasPersistentRepository": hasPersistentRepository,
      "generateModel": generateModel,
      "generateEntity": generateEntity,
      "generateForm": generateForm,
      "generateList": generateList,
      "generateDropDownButton": generateDropDownButton,
      "generateInternalComponent": generateInternalComponent,
      "generateEmbeddedComponent": generateEmbeddedComponent,
      "isExtension": isExtension,
      "isDocumentCollection": isDocumentCollection,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [generateComponent, generateRepository, generateCache, generateFirestoreRepository, hasPersistentRepository, generateModel,
    generateEntity, generateForm, generateList, generateDropDownButton, generateInternalComponent, generateEmbeddedComponent, isExtension, isDocumentCollection];

  @override
  String toString() {
    return 'GenerateSpecification { generateComponent: $generateComponent, generateRepository: $generateCache: generateCache, $generateRepository, hasPersistentRepository: $hasPersistentRepository, generateFirestoreRepository: $generateFirestoreRepository, generateModel: $generateModel, generateEntity: $generateEntity, generateForm: $generateForm, generateList: $generateList, generateDropDownButton: $generateDropDownButton, generateInternalComponent: $generateInternalComponent, generateEmbeddedComponent: $generateEmbeddedComponent, isExtension:$isExtension }';
  }

  static GenerateSpecification fromJson(Map<String, Object> json) {
    return GenerateSpecification(
      generateComponent: json["generateComponent"] as bool ?? false,
      generateRepository: json["generateRepository"] as bool ?? false,
      generateCache: json["generateCache"] as bool ?? false,
      generateFirestoreRepository: json["generateFirestoreRepository"] as bool ?? false,
      hasPersistentRepository: json["hasPersistentRepository"] as bool ?? false,
      generateModel: json["generateModel"] as bool ?? false,
      generateEntity: json["generateEntity"] as bool ?? false,
      generateForm: json["generateForm"] as bool ?? false,
      generateList: json["generateList"] as bool ?? false,
      generateDropDownButton: json["generateDropDownButton"] as bool ?? false,
      generateInternalComponent: json["generateInternalComponent"] as bool ?? false,
      generateEmbeddedComponent: json["generateEmbeddedComponent"] as bool ?? false,
      isExtension: json["isExtension"] as bool ?? false,
      isDocumentCollection: json["isDocumentCollection"] as bool ?? false
    );
  }

  static GenerateSpecification fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
