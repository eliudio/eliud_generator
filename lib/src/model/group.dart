import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String group;
  final String description;

  const Group({this.group, this.description});

  Map<String, Object> toJson() {
    return {
      "group": group,
      "description": description,
    };
  }

  @override
  List<Object> get props => [group, description];

  @override
  String toString() {
    return 'Field { group: $group, description: $description }';
  }

  static Group fromJson(Map<String, Object> json) {
    return Group(
      group: json["group"] as String,
      description: json["description"] as String,
    );
  }
}
