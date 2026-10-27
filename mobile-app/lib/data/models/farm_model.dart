import 'package:json_annotation/json_annotation.dart';

part 'farm_model.g.dart';

@JsonSerializable()
class FarmModel {
  @JsonKey(name: 'id')
  String? id;

  @JsonKey(name: 'status')
  String? status;

  @JsonKey(name: 'sort')
  dynamic sort;

  @JsonKey(name: 'user_created')
  String? userCreated;

  @JsonKey(name: 'date_created')
  DateTime? dateCreated;

  @JsonKey(name: 'user_updated')
  String? userUpdated;

  @JsonKey(name: 'date_updated')
  DateTime? dateUpdated;

  @JsonKey(name: 'name')
  String? name;

  @JsonKey(name: 'location')
  LocationModel? location;

  @JsonKey(name: 'area_size')
  String? areaSize;

  @JsonKey(name: 'user_id')
  String? userId;

  @JsonKey(name: 'soil_type')
  int? soilType;

  @JsonKey(name: 'ownership_type')
  String? ownershipType;

  @JsonKey(name: 'area_unit')
  String? areaUnit;

  @JsonKey(name: 'address')
  String? address;

  FarmModel({
    this.id,
    this.status,
    this.sort,
    this.userCreated,
    this.dateCreated,
    this.userUpdated,
    this.dateUpdated,
    this.name,
    this.location,
    this.areaSize,
    this.userId,
    this.soilType,
    this.ownershipType,
    this.areaUnit,
    this.address,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) =>
      _$FarmModelFromJson(json);

  Map<String, dynamic> toJson() => _$FarmModelToJson(this);
}

@JsonSerializable()
class LocationModel {
  @JsonKey(name: 'coordinates')
  List<List<List<double>>>? coordinates;

  @JsonKey(name: 'type')
  String? type;

  LocationModel({this.coordinates, this.type});

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);
}
