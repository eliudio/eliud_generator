import 'package:equatable/equatable.dart';

class Field extends Equatable {
  final String fieldName;
  final String fieldType;
  final bool array;
  final bool association;

  const Field({this.fieldName, this.fieldType, this.array, this.association});

  Map<String, Object> toJson() {
    return {
      "fieldName": fieldName,
      "fieldType": fieldType,
      "array": array,
      "association": association,
    };
  }

  @override
  List<Object> get props => [fieldName, fieldType, array, association];

  @override
  String toString() {
    return 'Field { fieldName: $fieldName, fieldType: $fieldType, array: $array, association: $association }';
  }

  static Field fromJson(Map<String, Object> json) {
    return Field(
      fieldName: json["fieldName"] as String,
      fieldType: json["fieldType"] as String,
      array:  json["array"] as bool,
      association: json["association"] as bool,
    );
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
    return dataType("Model");
  }

  String dartEntityType() {
    return dataType("Entity");
  }

  bool isNativeType() {
    if (fieldType == "bool") return true;
    if (fieldType == "int") return true;
    if (fieldType == "String") return true;
    return false;
  }
}
