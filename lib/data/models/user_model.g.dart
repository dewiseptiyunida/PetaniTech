// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String?,
  password: json['password'] as String?,
  location: json['location'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  avatar: json['avatar'] as String?,
  language: json['language'] as String?,
  tfaSecret: json['tfa_secret'] as String?,
  status: json['status'] as String?,
  role: json['role'] as String?,
  token: json['token'] as String?,
  lastAccess:
      json['last_access'] == null
          ? null
          : DateTime.parse(json['last_access'] as String),
  lastPage: json['last_page'] as String?,
  provider: json['provider'] as String?,
  externalIdentifier: json['external_identifier'] as String?,
  authData: json['auth_data'] as Map<String, dynamic>?,
  emailNotifications: (json['email_notifications'] as bool?) ?? false,
  appearance: json['appearance'] as String?,
  themeDark: json['theme_dark'] as String?,
  themeLight: json['theme_light'] as String?,
  themeLightOverrides: json['theme_light_overrides'] as Map<String, dynamic>?,
  themeDarkOverrides: json['theme_dark_overrides'] as Map<String, dynamic>?,
  policies: json['policies'] as List<dynamic>?,
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'email': instance.email,
  'password': instance.password,
  'location': instance.location,
  'title': instance.title,
  'description': instance.description,
  'tags': instance.tags,
  'avatar': instance.avatar,
  'language': instance.language,
  'tfa_secret': instance.tfaSecret,
  'status': instance.status,
  'role': instance.role,
  'token': instance.token,
  'last_access': instance.lastAccess?.toIso8601String(),
  'last_page': instance.lastPage,
  'provider': instance.provider,
  'external_identifier': instance.externalIdentifier,
  'auth_data': instance.authData,
  'email_notifications': instance.emailNotifications,
  'appearance': instance.appearance,
  'theme_dark': instance.themeDark,
  'theme_light': instance.themeLight,
  'theme_light_overrides': instance.themeLightOverrides,
  'theme_dark_overrides': instance.themeDarkOverrides,
  'policies': instance.policies,
  'phone': instance.phone,
};
