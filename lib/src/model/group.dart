import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String group;
  final String description;
  final String conditional; // group is visible in form when this condition is true

  const Group({this.group, this.description, this.conditional,});

  Map<String, Object> toJson() {
    return {
      "group": group,
      "description": description,
      "conditional": conditional,
    };
  }

  @override
  List<Object> get props => [group, description, conditional];

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
}
