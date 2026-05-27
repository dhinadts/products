import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({int initialIndex = 0})
    : super(DashboardState(selectedIndex: initialIndex));

  void selectTab(int index) => emit(state.copyWith(selectedIndex: index));
}
