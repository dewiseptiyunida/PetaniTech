// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommunityModel _$CommunityModelFromJson(Map<String, dynamic> json) =>
    CommunityModel(
      id: json['id'] as String,
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
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      visibility: json['visibility'] as String,
      members:
          (json['members'] as List<dynamic>?)?.map((e) => e as String).toList(),
      membersCount: json['members_count'] as String?,
    );

Map<String, dynamic> _$CommunityModelToJson(CommunityModel instance) =>
    <String, dynamic>{
      'status': instance.status,
      'sort': instance.sort,
      'user_created': instance.userCreated,
      'date_created': instance.dateCreated?.toIso8601String(),
      'user_updated': instance.userUpdated,
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
      'visibility': instance.visibility,
      'members': instance.members,
      'members_count': instance.membersCount,
    };
