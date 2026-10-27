// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commodity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommodityModel _$CommodityModelFromJson(Map<String, dynamic> json) =>
    CommodityModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String,
      sort: (json['sort'] as num?)?.toInt(),
      userCreated: json['user_created'] as String,
      dateCreated: DateTime.parse(json['date_created'] as String),
      userUpdated: json['user_updated'] as String?,
      dateUpdated:
          json['date_updated'] == null
              ? null
              : DateTime.parse(json['date_updated'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
    );

Map<String, dynamic> _$CommodityModelToJson(CommodityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'status': instance.status,
      'sort': instance.sort,
      'user_created': instance.userCreated,
      'date_created': instance.dateCreated.toIso8601String(),
      'user_updated': instance.userUpdated,
      'date_updated': instance.dateUpdated?.toIso8601String(),
      'name': instance.name,
      'description': instance.description,
      'image': instance.image,
    };
