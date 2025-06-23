import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

class Blocserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    debugPrint('================EventBloc: $bloc ===========================');
    debugPrint('====================Event:  $event ===========================');

    super.onEvent(bloc, event);
  }
}
