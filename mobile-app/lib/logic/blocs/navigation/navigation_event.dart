import 'package:equatable/equatable.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_state.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

class NavigationSelectTab extends NavigationEvent {
  final NavigationTab tab;

  const NavigationSelectTab({required this.tab});

  @override
  List<Object> get props => [tab];
}
