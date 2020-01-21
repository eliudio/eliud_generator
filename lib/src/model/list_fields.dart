import 'dart:convert';

class ListFields {
  final String title;
  final String subTitle;

  ListFields({ this.title, this.subTitle });

  Map<String, Object> toJson() {
    return <String, dynamic>{
      "title": title,
      "subTitle": subTitle,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [title, subTitle];

  @override
  String toString() {
    return 'ListFields { title: $title, subTitle: $subTitle }';
  }

  static ListFields fromJson(Map<String, Object> json) {
    return ListFields(
      title: json["title"] as String,
      subTitle: json["subTitle"] as String,
    );
  }

  static ListFields fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
