import 'package:equatable/equatable.dart';

enum FormTypeField {
  EntryField, CheckBox, Selection, Lookup, List, Unsupported
}

class Field extends Equatable {
  final String fieldName;
  final String displayName;
  final String fieldType;
  final String fieldValidation;
  final String enumName;
  final List<String> enumValues;
  final bool array;
  final bool map;
  final bool association;
  final String remark;
  final String group;
  final String defaultValue;
  final String iconName; // to be found in Icons..., e.g. specify "adjust" for Icons.adjust
  final bool hidden;
  final String bespokeFormField;
  final bool optional;  // is optional?
  final String conditional; // field is visible in form when this condition is true

  const Field({this.fieldName, this.displayName, this.fieldType, this.fieldValidation, this.array = false, this.map = false, this.association = false, this.enumName, this.enumValues, this.remark, this.group, this.defaultValue, this.iconName, this.hidden, this.bespokeFormField, this.optional, this.conditional });

  Map<String, Object> toJson() {
    return {
      "fieldName": fieldName,
      "displayName": displayName,
      "fieldType": fieldType,
      "fieldValidation": fieldValidation,
      "enumName": enumName,
      "enumValues": enumValues,
      "array": array,
      "map": map,
      "association": association,
      "remark": remark,
      "group": group,
      "defaultValue": defaultValue,
      "iconName": iconName,
      "hidden": hidden,
      "bespokeFormField": bespokeFormField,
      "optional": optional,
      "conditional": conditional,
    };
  }

  @override
  List<Object> get props => [fieldName, displayName, fieldType, fieldValidation, array, map, association, enumName, enumValues, remark, group, defaultValue, iconName, hidden, bespokeFormField, optional, conditional ];

  @override
  String toString() {
    return 'Field { fieldName: $fieldName, displayName: $displayName, fieldType: $fieldType, fieldValidation: $fieldValidation, array: $array, map: $map, association: $association, enumName: $enumName, enumValues: $enumValues, remark: $remark, group: $group, defaultValue: $defaultValue, iconName: $iconName, hidden: $hidden, bespokeFormField: $bespokeFormField, optional: $optional, conditional: $conditional }';
  }

  static Field fromJson(Map<String, Object> json) {
    bool array = json["array"] as bool ?? false;
    bool map = json["map"] as bool ?? false;
    bool association = json["association"] as bool ?? false;
    bool hidden = json["hidden"] as bool ?? false;
    bool optional = json["optional"] as bool ?? false;
    List<String> myList;
    Iterable i = json["enumValues"];
    if (i != null) {
      myList = List();
      i.forEach((val) {
        myList.add(val);
      });
    }
    return Field(
      fieldName: json["fieldName"] as String,
      displayName: json["displayName"] as String,
      fieldType: json["fieldType"] as String,
      fieldValidation: json["fieldValidation"] as String,
      enumName: json["enumName"] as String,
      enumValues: myList,
      array:  array,
      map: map,
      association: association,
      remark: json["remark"] as String,
      group: json["group"] as String,
      defaultValue: json["defaultValue"] as String,
      iconName: json["iconName"] as String,
      hidden: hidden,
      bespokeFormField: json["bespokeFormField"] as String,
      optional: optional,
      conditional: json["conditional"] as String,
    );
  }

  bool isEnum() {
    return (fieldType == "enum");
  }

  bool isMap() {
    return map;
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

  String dataType(String suffix) {
    if (array) {
      if (isNativeType()) return "List<" + fieldType + ">";
      return "List<" + fieldType + suffix + ">";
    } else {
      if (map) {
        if (isNativeType()) return "Map<String, " + fieldType + ">";
        return "Map<String, " + fieldType + suffix + ">";
      } else {
        if (isNativeType()) return fieldType;
        return fieldType + suffix;
      }
    }
  }

  bool isModel() {
    if (isEnum()) return false;
    if (isMap()) return false;
    if (isString()) return false;
    if (isDouble()) return false;
    if (isBool()) return false;
    if (isInt()) return false;
    return true;
  }

  String dartModelType() {
    if (isEnum()) {
      if (array)
        return "List<" + enumName + ">";
      else
        if (map)
          return "Map<String, " + enumName + ">";
        else
          return enumName;
    } else {
      return dataType("Model");
    }
  }

  String dartEntityType() {
    if (isEnum()) {
      if (array)
        return "List<int>";
      else
        if (map) {
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
    if (map) {
      // todo!
      return FormTypeField.Unsupported;
    } else {
      if (array) {
        if (!association) return FormTypeField.List;
      } else {
        if (association) return FormTypeField.Lookup;
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
