import 'package:json_annotation/json_annotation.dart';
import 'package:petanitech_mobile/data/models/base_model.dart';

part 'community_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CommunityModel extends BaseModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'image')
  final String image;

  @JsonKey(name: 'visibility')
  final String visibility;

  @JsonKey(name: 'members')
  final List<String>? members;

  @JsonKey(name: 'members_count')
  final String? membersCount;

  CommunityModel({
    required this.id,
    super.status,
    super.sort,
    super.userCreated,
    super.dateCreated,
    super.userUpdated,
    super.dateUpdated,
    required this.name,
    required this.description,
    required this.image,
    required this.visibility,
    this.members,
    this.membersCount,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) =>
      _$CommunityModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CommunityModelToJson(this);
}
