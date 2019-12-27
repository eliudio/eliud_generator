import 'package:equatable/equatable.dart';

class Field extends Equatable {
  final String fieldName;
  final String fieldType;
  final String enumName;
  final List<String> enumValues;
  final bool array;
  final bool association;
  final String remark;

  const Field({this.fieldName, this.fieldType, this.array = false, this.association = false, this.enumName, this.enumValues, this.remark});

  Map<String, Object> toJson() {
    return {
      "fieldName": fieldName,
      "fieldType": fieldType,
      "enumName": enumName,
      "enumValues": enumValues,
      "array": array,
      "association": association,
      "remark": remark
    };
  }

  @override
  List<Object> get props => [fieldName, fieldType, array, association, enumName, enumValues, remark];

  @override
  String toString() {
    return 'Field { fieldName: $fieldName, fieldType: $fieldType, array: $array, association: $association, enumName: $enumName, enumValues: $enumValues, remark: $remark }';
  }

  static Field fromJson(Map<String, Object> json) {
    bool array = json["array"] as bool;
    bool association = json["association"] as bool;
    if (array == null) array = false;
    if (association == null) association = false;
    List<String> myList = null;
    Iterable i = json["enumValues"];
    if (i != null) {
      myList = List();
      i.forEach((val) {
        myList.add(val);
      });
    }
    return Field(
      fieldName: json["fieldName"] as String,
      fieldType: json["fieldType"] as String,
      enumName: json["enumName"] as String,
      enumValues: myList,
      array:  array,
      association: association,
      remark: json["remark"] as String,
    );
  }

  bool isEnum() {
    return (fieldType == "enum");
  }

  String dataType(String suffix) {
    if (array) {
      if (isNativeType()) return "List<" + fieldType + ">";
      if (array) return "List<" + fieldType + suffix + ">";
    } else {
      if (isNativeType()) return fieldType;
      return fieldType + suffix;
    }
  }

  String dartModelType() {
    if (isEnum()) {
      if (array)
        return "List<" + enumName + ">";
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
        return "int";
    } else {
      return dataType("Entity");
    }
  }

  bool isNativeType() {
    if (fieldType == "bool") return true;
    if (fieldType == "int") return true;
    if (fieldType == "double") return true;
    if (fieldType == "String") return true;
    return false;
  }
}
