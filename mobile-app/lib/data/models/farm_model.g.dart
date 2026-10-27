// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'farm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FarmModel _$FarmModelFromJson(Map<String, dynamic> json) => FarmModel(
  id: json['id'] as String?,
  status: json['status'] as String?,
  sort: json['sort'],
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
  name: json['name'] as String?,
  location:
      json['location'] == null
          ? null
          : LocationModel.fromJson(json['location'] as Map<String, dynamic>),
  areaSize: json['area_size'] as String?,
  userId: json['user_id'] as String?,
  soilType: (json['soil_type'] as num?)?.toInt(),
  ownershipType: json['ownership_type'] as String?,
  areaUnit: json['area_unit'] as String?,
  address: json['address'] as String?,
);

Map<String, dynamic> _$FarmModelToJson(FarmModel instance) => <String, dynamic>{
  'id': instance.id,
  'status': instance.status,
  'sort': instance.sort,
  'user_created': instance.userCreated,
  'date_created': instance.dateCreated?.toIso8601String(),
  'user_updated': instance.userUpdated,
  'date_updated': instance.dateUpdated?.toIso8601String(),
  'name': instance.name,
  'location': instance.location,
  'area_size': instance.areaSize,
  'user_id': instance.userId,
  'soil_type': instance.soilType,
  'ownership_type': instance.ownershipType,
  'area_unit': instance.areaUnit,
  'address': instance.address,
};

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      coordinates:
          (json['coordinates'] as List<dynamic>?)
              ?.map(
                (e) =>
                    (e as List<dynamic>)
                        .map(
                          (e) =>
                              (e as List<dynamic>)
                                  .map((e) => (e as num).toDouble())
                                  .toList(),
                        )
                        .toList(),
              )
              .toList(),
      type: json['type'] as String?,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'coordinates': instance.coordinates,
      'type': instance.type,
    };
