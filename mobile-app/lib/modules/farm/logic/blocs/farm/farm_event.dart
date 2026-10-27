import 'package:equatable/equatable.dart';

class FarmEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFarms extends FarmEvent {
  final int offset;
  final int limit;
  LoadFarms({this.offset = 0, this.limit = 5});

  @override
  List<Object?> get props => [offset, limit];
}

class RefreshFarms extends FarmEvent {}
