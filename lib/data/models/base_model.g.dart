// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaseModel _$BaseModelFromJson(Map<String, dynamic> json) => BaseModel(
  status: json['status'] as String?,
  sort: (json['sort'] as num?)?.toInt(),
  userCreated: json['user_created'] as String?,
  dateCreated:
      json['date_created'] == null
          ? null
          : DateTime.parse(json['date_created'] as String),
  userUpdated: json['user_updated'] as String?,
  dateUpdated:
      json['date_updated'] == null
          ? null
          : DateTime.parse(json['date_updated'] as String),
);

Map<String, dynamic> _$BaseModelToJson(BaseModel instance) => <String, dynamic>{
  'status': instance.status,
  'sort': instance.sort,
  'user_created': instance.userCreated,
  'date_created': instance.dateCreated?.toIso8601String(),
  'user_updated': instance.userUpdated,
  'date_updated': instance.dateUpdated?.toIso8601String(),
};
