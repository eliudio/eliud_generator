import 'dart:convert';

class ListFields {
  final String? title;
  final String? subTitle;
  final bool? imageTitle;
  final bool? imageSubTitle;

  ListFields({ required this.title, required this.subTitle, this.imageTitle = false, this.imageSubTitle = false});

  @override
  String toString() {
    return 'ListFields { title: $title, subTitle: $subTitle, imageTitle: $imageTitle, imageSubTitle: $imageSubTitle }';
  }

  static ListFields fromJson(Map<String, dynamic> json) {
    return ListFields(
      title: json["title"] as String?,
      subTitle: json["subTitle"] as String?,
      imageTitle: json["imageTitle"] as bool? ?? false,
      imageSubTitle: json["imageSubTitle"] as bool? ?? false,
    );
  }

  static ListFields fromJsonString(String json) {
    Map<String, dynamic> generationSpecificationMap = jsonDecode(json);
    return fromJson(generationSpecificationMap);
  }

  bool hasImage() {
    return hasImageTitle() || hasImageSubTitle();
  }

  String getTitle() {
    if (title == null) return "null";
    return title!;
  }

  String getSubTitle() {
    if (subTitle == null) return "null";
    return subTitle!;
  }

  bool hasImageTitle() {
    if (imageTitle == null) return false;
    return imageTitle!;
  }

  bool hasImageSubTitle() {
    if (imageSubTitle == null) return false;
    return imageSubTitle!;
  }
}
