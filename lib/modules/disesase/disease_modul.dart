import 'package:flutter_modular/flutter_modular.dart';
import 'package:image_picker/image_picker.dart';
import 'logic/services/api_service.dart';
import 'logic/controllers/prediction_controller.dart';
import 'logic/controllers/chat_controller.dart';
import 'presentation/prediction_chat_screen.dart';

class DiseaseModule extends Module {
  static const String homeRoute = '/';
  static const String predictionRoute = '/prediction';
  static const String chatRoute = '/chat';
  static const String predictionChatRoute = '/prediction-chat';

  @override
  void binds(i) {
    // Services
    i.addLazySingleton<ApiService>(ApiService.new);

    // Controllers
    i.addLazySingleton<PredictionController>(PredictionController.new);
    i.addLazySingleton<ChatController>(ChatController.new);

    // External dependencies
    i.addLazySingleton<ImagePicker>(ImagePicker.new);
  }

  @override
  void routes(r) {
    // Route baru untuk PredictionChatScreen
    r.child(predictionChatRoute, child: (_) => PredictionChatScreen());
  }
}
