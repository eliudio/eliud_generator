enum FormTypeField {
  EntryField,
  CheckBox,
  Selection,
  Lookup,
  List,
  Unsupported
}

enum ArrayType {
  ListArrayType, // ListArrayType is an embedded array []
  CollectionArrayType, // CollectionArrayType is a list which is actually a firestore sub collection of the document
  NoArray
}

class Field {
  final String fieldName;
  final String? displayName;
  final String fieldType;
  final String? fieldValidation;
  final String? enumName;
  final List<String>? enumValues;
  final ArrayType? arrayType;
  final bool? map;
  final bool? association;
  final String? remark;
  final String? group;
  final String? defaultValue;
  final String?
      iconName; // to be found in Icons..., e.g. specify "adjust" for Icons.adjust
  final bool? hidden;
  final String? bespokeFormField;

  // if fieldType = 'bespoke' then you can specify your own type + it's mapping
  final String? bespokeFieldType;
  final String? bespokeEntityMapping; // fromMap mapping
  final String? bespokeEntityToDocument; // toDocuemnt mapping

  final bool? optional; // is optional in the gui?
  final bool? isRequired; // is 'dart' required ?
  final String?
      conditional; // field is visible in form when this condition is true

  final String? refCode; // code to use to collect references

  const Field(
      {required this.fieldName,
      required this.displayName,
      required this.fieldType,
      required this.fieldValidation,
      this.arrayType = ArrayType.NoArray,
      this.map = false,
      this.association = false,
      required this.enumName,
      required this.enumValues,
      required this.remark,
      required this.group,
      required this.defaultValue,
      required this.iconName,
      required this.hidden,
      required this.bespokeFormField,
      required this.bespokeFieldType,
      required this.bespokeEntityMapping,
      required this.bespokeEntityToDocument,
      required this.optional,
      required this.conditional,
      required this.isRequired,
      required this.refCode});

/*
  Map<String, dynamic> toJson() {
    return {
      "fieldName": fieldName,
      "displayName": displayName,
      "fieldType": fieldType,
      "fieldValidation": fieldValidation,
      "enumName": enumName,
      "enumValues": enumValues ?? [],
      "arrayType": arrayType,
      "map": map,
      "association": association,
      "remark": remark,
      "group": group,
      "defaultValue": defaultValue,
      "iconName": iconName,
      "hidden": hidden,
      "bespokeFormField": bespokeFormField,
      "bespokeFieldType": bespokeFieldType,
      "bespokeEntityMapping": bespokeEntityMapping,
      "bespokeEntityToDocument": bespokeEntityToDocument,
      "optional": optional,
      "conditional": conditional,
    };
  }

  @override
  List<Object> get props => [
        fieldName,
        displayName,
        fieldType,
        fieldValidation,
        arrayType,
        map,
        association,
        enumName,
        remark,
        group,
        defaultValue,
        iconName,
        hidden,
        bespokeFormField,
        bespokeFieldType,
        bespokeEntityMapping,
        bespokeEntityToDocument,
        optional,
        conditional
      ];
*/

  bool isDartRequired() => isRequired ?? false;

  String getDefaultValue() {
    if (defaultValue == null) return "";
    return defaultValue!;
  }

  bool isHidden() {
    if (hidden == null) return false;
    return hidden!;
  }

  String getConditional() {
    if (conditional == null) return "";
    return conditional!;
  }

  String getBespokeFormField() {
    if (bespokeFormField == null) return "";
    return bespokeFormField!;
  }

  String getBespokeFieldType() {
    if (bespokeFieldType == null) return "";
    return bespokeFieldType!;
  }

  String getGroup() {
    if (group == null) return "";
    return group!;
  }

  String getBespokeEntityMapping() {
    if (bespokeEntityMapping == null) return "";
    return bespokeEntityMapping!;
  }

  String getEnumName() {
    if (enumName == null) return "";
    return enumName!;
  }

  bool isOptional() {
    if (optional == null) return false;
    return optional!;
  }

  @override
  String toString() {
    return 'Field { fieldName: $fieldName, displayName: $displayName, fieldType: $fieldType, fieldValidation: $fieldValidation, arrayType: $arrayType, map: $map, association: $association, enumName: $enumName, enumValues: $enumValues, remark: $remark, group: $group, defaultValue: $defaultValue, iconName: $iconName, hidden: $hidden, bespokeFormField: $bespokeFormField, bespokeEntityMapping: $bespokeEntityMapping, bespokeEntityToDocument: $bespokeEntityToDocument, bespokeFieldType: $bespokeFieldType, optional: $optional, conditional: $conditional }';
  }

  static Field fromJson(Map<String, dynamic> json) {
    //print("field::fromJson Step 1");
    String? arrayTypeS = json["arrayType"] as String?;
    //print("field::fromJson Step 2");
    ArrayType arrayType = ArrayType.NoArray;
    //print("field::fromJson Step 3");
    if (arrayTypeS != null) {
      if (arrayTypeS.toLowerCase() == "array") {
        arrayType = ArrayType.ListArrayType;
      }
      if (arrayTypeS.toLowerCase() == "collection") {
        arrayType = ArrayType.CollectionArrayType;
      }
    }
    //print("field::fromJson Step 4a");
    bool map = json["map"] as bool? ?? false;
    //print("field::fromJson Step 4b");
    bool association = json["association"] as bool? ?? false;
    //print("field::fromJson Step 4c");
    bool hidden = json["hidden"] as bool? ?? false;
    //print("field::fromJson Step 4d");
    bool optional = json["optional"] as bool? ?? false;
    //print("field::fromJson Step 4e");
    bool isRequired = json["required"] as bool? ?? false;
    //print("field::fromJson Step 4f");
    List<String>? myList;
    //print("field::fromJson Step 4g");
    Iterable? i = json["enumValues"] as Iterable?;

    //print("field::fromJson Step 5");
    if (i != null) {
      myList = <String>[];
      for (var val in i) {
        myList.add(val);
      }
    }
    //print("field::fromJson Step 6");
    fieldName:
    json["fieldName"] as String;
    //print("field::fromJson Step 6b");
    displayName:
    json["displayName"] as String?;
    //print("field::fromJson Step 6c");
    fieldType:
    json["fieldType"] as String;
    //print("field::fromJson Step 6d");

    var field = Field(
      fieldName: json["fieldName"] as String,
      displayName: json["displayName"] as String?,
      fieldType: json["fieldType"] as String,
      fieldValidation: json["fieldValidation"] as String?,
      enumName: json["enumName"] as String?,
      enumValues: myList,
      arrayType: arrayType,
      map: map,
      association: association,
      remark: json["remark"] as String?,
      group: json["group"] as String?,
      defaultValue: json["defaultValue"] as String?,
      iconName: json["iconName"] as String?,
      hidden: hidden,
      bespokeFormField: json["bespokeFormField"] as String?,
      bespokeFieldType: json["bespokeFieldType"] as String?,
      bespokeEntityMapping: json["bespokeEntityMapping"] as String?,
      bespokeEntityToDocument: json["bespokeEntityToDocument"] as String?,
      optional: optional,
      isRequired: isRequired,
      conditional: json["conditional"] as String?,
      refCode: json["refCode"] as String?,
    );
    //print("field::fromJson Step 7");
    return field;
  }

  bool isEnum() {
    return (fieldType == "enum");
  }

  bool isMap() {
    return map != null && map!;
  }

  bool isAssociation() {
    if (association == null) return false;
    return association!;
  }

  bool isInt() {
    return (fieldType == "int");
  }

  bool isDouble() {
    return (fieldType == "double");
  }

  bool isString() {
    return (fieldType == "String");
  }

  bool isBool() {
    return (fieldType == "bool");
  }

  bool isServerTimestamp() {
    return (fieldType == "ServerTimestamp") ||
        (fieldType == "ServerTimestampUninitialized");
  }

  bool isServerTimestampInitialized() {
    return (fieldType == "ServerTimestamp");
  }

  bool isBespoke() {
    return (fieldType == "bespoke");
  }

  bool isMedium() {
    return (fieldType == "PlatformMedium") ||
        (fieldType == "PublicMedium") ||
        (fieldType == "MemberMedium");
  }

  String getRemark() {
    if (remark == null) return "";
    return remark!;
  }

  String dataType(String suffix) {
    if (isBespoke()) {
      return getBespokeFieldType();
    } else {
      if (arrayType != ArrayType.NoArray) {
        if (isNativeType()) return "List<$fieldType>";
        return "List<$fieldType$suffix>";
      } else {
        if (isMap()) {
          if (isNativeType()) return "Map<String, $fieldType>";
          return "Map<String, $fieldType$suffix>";
        } else {
          if (isNativeType()) return fieldType;
          return fieldType + suffix;
        }
      }
    }
  }

  bool isModel() {
    if (isEnum()) return false;
    if (isMap()) return false;
    if (isString()) return false;
    if (isDouble()) return false;
    if (isBool()) return false;
    if (isServerTimestamp()) return false;
    if (isInt()) return false;
    if (isBespoke()) return false;
    return true;
  }

  bool isArray() => (arrayType != ArrayType.NoArray);

  String dartModelType() {
    if (isServerTimestamp()) {
      return "DateTime";
    } else if (isEnum()) {
      if (isArray()) {
        return "List<${getEnumName()}>";
      } else if (isMap())
        return "Map<String, ${getEnumName()}>";
      else
        return getEnumName();
    } else {
      return dataType("Model");
    }
  }

  String dartEntityType() {
    if (isServerTimestamp()) {
      return "Object";
    } else if (isEnum()) {
      if (isArray()) {
        return "List<int>";
      } else if (isMap()) {
        return "Map<String, int>";
      } else {
        return "int";
      }
    } else {
      return dataType("Entity");
    }
  }

  bool isNativeType() {
    if (isBool()) return true;
    if (isInt()) return true;
    if (isDouble()) return true;
    if (isString()) return true;
    return false;
  }

  FormTypeField formFieldType() {
    if (isMap()) {
      // todo!
      return FormTypeField.Unsupported;
    } else {
      if (isArray()) {
        if (!isAssociation()) return FormTypeField.List;
      } else {
        if (isAssociation()) return FormTypeField.Lookup;
        if (isEnum()) return FormTypeField.Selection;
        if (isInt()) return FormTypeField.EntryField;
        if (isDouble()) return FormTypeField.EntryField;
        if (isString()) return FormTypeField.EntryField;
        if (isBool()) return FormTypeField.CheckBox;
      }
      return FormTypeField.Unsupported;
    }
  }
}
