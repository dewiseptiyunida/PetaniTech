import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationState()) {
    on<GetNotificationEvent>(_getNotification);
  }

  void _getNotification(
    GetNotificationEvent event,
    Emitter<NotificationState> emit,
  ) {
    // login get from repo
  }
}
