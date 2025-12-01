import 'package:equatable/equatable.dart';

enum NavPage { home, search, library, about }

class NavigationState extends Equatable {
  final NavPage page;

  const NavigationState(this.page);

  @override
  List<Object> get props => [page];
}
