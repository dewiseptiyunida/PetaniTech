// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['id'] as String,
  status: json['status'] as String?,
  sort: (json['sort'] as num?)?.toInt(),
  dateCreated:
      json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
  dateUpdated:
      json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
  title: json['title'] as String?,
  content: json['content'] as String?,
  userCreated:
      json['user_created'] == null
          ? null
          : UserModel.fromJson(json['user_created'] as Map<String, dynamic>),
  userUpdated:
      json['user_updated'] == null
          ? null
          : UserModel.fromJson(json['user_updated'] as Map<String, dynamic>),
  image:
      json['image'] == null
          ? null
          : ImageModel.fromJson(json['image'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'sort': instance.sort,
  'date_created': instance.dateCreated?.toIso8601String(),
  'date_updated': instance.dateUpdated?.toIso8601String(),
  'title': instance.title,
  'content': instance.content,
  'user_created': instance.userCreated?.toJson(),
  'user_updated': instance.userUpdated?.toJson(),
  'image': instance.image?.toJson(),
};

ImageModel _$ImageModelFromJson(Map<String, dynamic> json) => ImageModel(
  id: json['id'] as String,
  storage: json['storage'] as String,
  filenameDisk: json['filename_disk'] as String,
  filenameDownload: json['filename_download'] as String,
  title: json['title'] as String,
  type: json['type'] as String,
  folder: json['folder'] as String,
  uploadedBy: json['uploaded_by'] as String,
  createdOn: DateTime.parse(json['created_on'] as String),
  modifiedOn:
      json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String),
  width: (json['width'] as num).toInt(),
  height: (json['height'] as num).toInt(),
  description: json['description'] as String?,
);

Map<String, dynamic> _$ImageModelToJson(ImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storage': instance.storage,
      'filename_disk': instance.filenameDisk,
      'filename_download': instance.filenameDownload,
      'title': instance.title,
      'type': instance.type,
      'folder': instance.folder,
      'uploaded_by': instance.uploadedBy,
      'created_on': instance.createdOn.toIso8601String(),
      'modified_on': instance.modifiedOn?.toIso8601String(),
      'width': instance.width,
      'height': instance.height,
      'description': instance.description,
    };
