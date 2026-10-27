import 'package:json_annotation/json_annotation.dart';

part 'commodity_model.g.dart';

@JsonSerializable()
class CommodityModel {
  final int id;
  final String status;
  final int? sort;
  @JsonKey(name: 'user_created')
  final String userCreated;
  @JsonKey(name: 'date_created')
  final DateTime dateCreated;
  @JsonKey(name: 'user_updated')
  final String? userUpdated;
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;
  final String name;
  final String description;
  final String image;

  CommodityModel({
    required this.id,
    required this.status,
    this.sort,
    required this.userCreated,
    required this.dateCreated,
    this.userUpdated,
    this.dateUpdated,
    required this.name,
    required this.description,
    required this.image,
  });

  factory CommodityModel.fromJson(Map<String, dynamic> json) =>
      _$CommodityModelFromJson(json);

  Map<String, dynamic> toJson() => _$CommodityModelToJson(this);
}
