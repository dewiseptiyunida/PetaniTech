import 'package:equatable/equatable.dart';

enum NavigationTab { home, community, farming, weather, profile }

class NavigationState extends Equatable {
  final NavigationTab currentTab;

  const NavigationState({this.currentTab = NavigationTab.home});

  NavigationState copyWith({NavigationTab? currentTab}) {
    return NavigationState(currentTab: currentTab ?? this.currentTab);
  }

  @override
  List<Object> get props => [currentTab];
}
