import 'package:json_schema/json_schema.dart';

abstract class JsonTo {
  static bool isArray({SchemaType jsonType}) {
    return (jsonType == SchemaType.array);
  }

  String jsonTypeToString({JsonSchema schema}) {
    var jsonType = schema.type;
    if (jsonType == SchemaType.string) return "String";
    if (jsonType == SchemaType.boolean) return "bool";
    if (jsonType == SchemaType.integer) return "int";
    if (jsonType == SchemaType.number) return "int";
    if (jsonType == SchemaType.number) return "int";
    if (jsonType == SchemaType.object) return schema.path;
    return "?";
  }
}