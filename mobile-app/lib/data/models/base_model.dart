import 'package:json_annotation/json_annotation.dart';

part 'base_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BaseModel {
  final String? status;
  final int? sort;
  @JsonKey(name: 'user_created')
  final String? userCreated;
  @JsonKey(name: 'date_created')
  final DateTime? dateCreated;
  @JsonKey(name: 'user_updated')
  final String? userUpdated;
  @JsonKey(name: 'date_updated')
  final DateTime? dateUpdated;

  BaseModel({
    this.status,
    this.sort,
    this.userCreated,
    this.dateCreated,
    this.userUpdated,
    this.dateUpdated,
  });

  factory BaseModel.fromJson(Map<String, dynamic> json) =>
      _$BaseModelFromJson(json);
  Map<String, dynamic> toJson() => _$BaseModelToJson(this);
}
