import 'package:equatable/equatable.dart';

enum NavPage { home, search, library }

class NavigationState extends Equatable {
  final NavPage page;

  const NavigationState(this.page);

  @override
  List<Object> get props => [page];
}
