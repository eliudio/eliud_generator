import 'package:equatable/equatable.dart';

class Field extends Equatable {
  final String fieldName;
  final String fieldType;
  final bool array;

  const Field({this.fieldName, this.fieldType, this.array});

  Map<String, Object> toJson() {
    return {
      "fieldName": fieldName,
      "fieldType": fieldType,
      "array": array
    };
  }

  @override
  List<Object> get props => [fieldName, fieldType, array];

  @override
  String toString() {
    return 'Field { fieldName: $fieldName, fieldType: $fieldType, array: $array }';
  }

  static Field fromJson(Map<String, Object> json) {
    return Field(
      fieldName: json["fieldName"] as String,
      fieldType: json["fieldType"] as String,
      array:  json["array"] as bool,
    );
  }

  String dartType() {
    if (array) return "List<$fieldType>";
    else return fieldType;
  }

  bool isNativeType() {
    if (fieldType == "bool") return true;
    if (fieldType == "int") return true;
    if (fieldType == "String") return true;
    return false;
  }
}
