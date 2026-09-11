import 'package:bloc/bloc.dart';
import 'package:map_to_poster/screens/layout_selection.dart';
import 'package:meta/meta.dart';

part 'layout_state.dart';

class LayoutCubit extends Cubit<LayoutState> {
  LayoutCubit() : super(LayoutState(layout: PosterLayout.full));

  void setLayout(PosterLayout layout) {
    emit(LayoutState(layout: layout));
  }
}
