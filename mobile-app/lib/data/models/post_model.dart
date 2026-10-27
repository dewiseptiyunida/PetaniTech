import 'package:json_annotation/json_annotation.dart';
import 'package:petanitech_mobile/data/models/user_model.dart';

part 'post_model.g.dart';

@JsonSerializable(explicitToJson: true)
class PostModel {
  final String id;
  final String? status;
  final int? sort;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  final String? title;
  final String? content;
  @JsonKey(name: 'user_created')
  final UserModel? userCreated;
  @JsonKey(name: 'user_updated')
  final UserModel? userUpdated;
  final ImageModel? image;

  PostModel({
    required this.id,
    required this.status,
    this.sort,
    required this.dateCreated,
    required this.dateUpdated,
    required this.title,
    required this.content,
    required this.userCreated,
    required this.userUpdated,
    required this.image,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) =>
      _$PostModelFromJson(json);

  Map<String, dynamic> toJson() => _$PostModelToJson(this);
}

@JsonSerializable()
class ImageModel {
  final String id;
  final String storage;
  @JsonKey(name: 'filename_disk')
  final String filenameDisk;
  @JsonKey(name: 'filename_download')
  final String filenameDownload;
  final String title;
  final String type;
  final String folder;
  @JsonKey(name: 'uploaded_by')
  final String uploadedBy;
  @JsonKey(name: 'created_on')
  final DateTime createdOn;
  @JsonKey(name: 'modified_on')
  final DateTime? modifiedOn;
  final int width;
  final int height;
  final String? description;

  ImageModel({
    required this.id,
    required this.storage,
    required this.filenameDisk,
    required this.filenameDownload,
    required this.title,
    required this.type,
    required this.folder,
    required this.uploadedBy,
    required this.createdOn,
    this.modifiedOn,
    required this.width,
    required this.height,
    this.description,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImageModelToJson(this);
}
