import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  final String id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? email;
  final String? password;
  final String? location;
  final String? title;
  final String? description;
  final List<String>? tags;
  final String? avatar;
  final String? language;
  @JsonKey(name: 'tfa_secret')
  final String? tfaSecret;
  final String? status;
  final String? role;
  final String? token;
  @JsonKey(name: 'last_access')
  final DateTime? lastAccess;
  @JsonKey(name: 'last_page')
  final String? lastPage;
  final String? provider;
  @JsonKey(name: 'external_identifier')
  final String? externalIdentifier;
  @JsonKey(name: 'auth_data')
  final Map<String, dynamic>? authData;
  @JsonKey(name: 'email_notifications')
  final bool emailNotifications;
  final String? appearance;
  @JsonKey(name: 'theme_dark')
  final String? themeDark;
  @JsonKey(name: 'theme_light')
  final String? themeLight;
  @JsonKey(name: 'theme_light_overrides')
  final Map<String, dynamic>? themeLightOverrides;
  @JsonKey(name: 'theme_dark_overrides')
  final Map<String, dynamic>? themeDarkOverrides;
  final List<dynamic>? policies;
  final String? phone;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.location,
    this.title,
    this.description,
    this.tags,
    required this.avatar,
    this.language,
    this.tfaSecret,
    required this.status,
    required this.role,
    this.token,
    this.lastAccess,
    this.lastPage,
    required this.provider,
    this.externalIdentifier,
    this.authData,
    required this.emailNotifications,
    this.appearance,
    this.themeDark,
    this.themeLight,
    this.themeLightOverrides,
    this.themeDarkOverrides,
    required this.policies,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}
