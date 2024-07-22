import 'dart:convert';

class Upload {
  final String? id;
  final String? accessUrl;
  final String? ext;
  final String? fileName;
  final String? key;

  Upload({
    this.id,
    this.accessUrl,
    this.ext,
    this.fileName,
    this.key,
  });

  Upload.copy(Upload original)
      : id = original.id,
        accessUrl = original.accessUrl,
        ext = original.ext,
        fileName = original.fileName,
        key = original.key;

  factory Upload.fromRawJson(String str) => Upload.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Upload.fromJson(Map<String, dynamic> json) => Upload(
        id: json["_id"],
        accessUrl: json["access_url"],
        ext: json["extension"],
        fileName: json["file_name"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "access_url": accessUrl,
        "extension": ext,
        "file_name": fileName,
        "key": key,
      };
}
