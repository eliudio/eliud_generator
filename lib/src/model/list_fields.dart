import 'dart:convert';

class ListFields {
  final String title;
  final String subTitle;
  final bool imageTitle;
  final bool imageSubTitle;

  ListFields({ this.title, this.subTitle, this.imageTitle = false, this.imageSubTitle = false});

  Map<String, Object> toJson() {
    return <String, dynamic>{
      "title": title,
      "subTitle": subTitle,
      "imageTitle": imageTitle,
      "imageSubTitle": imageSubTitle,
    };
  }

  String toJsonString() {
    Map<String, Object> jsonMap = toJson();
    JsonEncoder encoder = new JsonEncoder.withIndent('  ');
    return encoder.convert(jsonMap);
  }

  @override
  List<Object> get props => [title, subTitle, imageTitle, imageSubTitle];

  @override
  String toString() {
    return 'ListFields { title: $title, subTitle: $subTitle, imageTitle: $imageTitle, imageSubTitle: $imageSubTitle }';
  }

  static ListFields fromJson(Map<String, Object> json) {
    return ListFields(
      title: json["title"] as String,
      subTitle: json["subTitle"] as String,
      imageTitle: json["imageTitle"] as bool ?? false,
      imageSubTitle: json["imageSubTitle"] as bool ?? false,
    );
  }

  static ListFields fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }
}
