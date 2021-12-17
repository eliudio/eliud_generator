import 'package:equatable/equatable.dart';

class Group {
  final String? group;
  final String? description;
  final String? conditional; // group is visible in form when this condition is true

  const Group({required this.group, required this.description, required this.conditional,});

  @override
  String toString() {
    return 'Field { group: $group, description: $description, conditional: $conditional }';
  }

  static Group fromJson(Map<String, Object> json) {
    return Group(
      group: json["group"] as String,
      description: json["description"] as String,
      conditional: json["conditional"] as String,
    );
  }

  String getDescription() {
    if (description == null) return "";
    return description!;
  }
}
