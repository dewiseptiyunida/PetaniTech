import 'package:equatable/equatable.dart';

enum NotificationType { initial, success, failure }

class NotificationState extends Equatable {
  final NotificationType notificationType;
  final int total;
  final List<Object> data;

  const NotificationState({
    this.notificationType = NotificationType.initial,
    this.data = const [],
    this.total = 0,
  });

  NotificationState copyWith({
    NotificationType? notificationType,
    List<Object>? data,
    int? total,
  }) {
    return NotificationState(
      notificationType: notificationType ?? this.notificationType,
      data: data ?? this.data,
      total: total ?? this.total,
    );
  }

  @override
  List<Object> get props => [notificationType];
}
