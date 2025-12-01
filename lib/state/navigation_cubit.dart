import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_state.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState(NavPage.home));

  void goToHome() => emit(const NavigationState(NavPage.home));
  void goToSearch() => emit(const NavigationState(NavPage.search));
  void goToLibrary() => emit(const NavigationState(NavPage.library));
}
