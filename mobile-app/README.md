# Petanitech Mobile App

Petanitech Mobile App adalah aplikasi mobile yang dirancang untuk memudahkan pengguna dalam mengakses layanan dan informasi terkait pertanian teknologi tinggi. Aplikasi ini menyediakan berbagai fitur yang membantu petani dalam mengelola lahan, memantau kondisi tanaman, dan mendapatkan informasi terkini mengenai teknologi pertanian.

## Arsitektur Aplikasi

Arsitektur aplikasi Petanitech Mobile App menggunakan pendekatan modular yang memisahkan setiap fitur ke dalam modul yang terpisah. Setiap modul memiliki tanggung jawab spesifik dan terdiri dari beberapa lapisan seperti data, logika, dan presentasi. Pendekatan ini memudahkan pengembangan, pemeliharaan, dan pengujian aplikasi.

### Struktur Proyek

```plaintext
/lib
│── main.dart
│── /core
│   ├── app_module.dart
│   ├── app_router.dart
│   ├── app_theme.dart
│── /modules
│   │── /auth
│   │   ├── auth_module.dart
│   │   ├── /data
│   │   │   ├── models
│   │   │   │   ├── auth_model.dart
│   │   │   ├── repositories
│   │   │   │   ├── user_repository.dart
│   │   ├── /logic
│   │   │   ├── blocs
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   ├── auth_state.dart
│   │   ├── /presentation
│   │   │   ├── login_screen.dart
│── pubspec.yaml
```

### Package

- Flutter Bloc (State Management)
- Flutter Modular (Modular Feature/Use Case/Domain, etc)
- Dio (Access Rest API)
- Dartz (Async Handle like Promise - Resolve, Reject)
- Equatable (Object equal handler)

### Generator

- Run Code Generator

  ```bash
  flutter pub run build_runner build --delete-conflicting-outputs
  ```

## Dokumentasi

- [Dokumentasi API Directus](https://directus.io/docs/api)
- [Flutter Intl Official Documentation](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)
- [Flutter Multi Language Easy Localization](https://pub.dev/packages/easy_localization)
- [Issue Flutter Intl](https://docs.flutter.dev/release/breaking-changes/flutter-generate-i10n-source)
