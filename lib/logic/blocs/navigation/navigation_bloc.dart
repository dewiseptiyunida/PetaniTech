import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_event.dart';
import 'package:petanitech_mobile/logic/blocs/navigation/navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationState(currentTab: NavigationTab.home)) {
    on<NavigationEvent>((event, emit) {
      if (event is NavigationSelectTab) {
        debugPrint("[NAVIGATION SELECT TAB] ${event.tab}");
        emit(state.copyWith(currentTab: event.tab));
      }
    });
  }

  Stream<NavigationState> mapEventToState(NavigationEvent event) async* {
    if (event is NavigationSelectTab) {
      yield NavigationState(currentTab: event.tab);
    }
  }
}
