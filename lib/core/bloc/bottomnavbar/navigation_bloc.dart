import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigateToPage extends NavigationEvent {
  final int index;
  const NavigateToPage(this.index);

  @override
  List<Object> get props => [index];
}

// BLoC
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateToPage>(_onNavigateToPage);
  }

  void _onNavigateToPage(NavigateToPage event, Emitter<NavigationState> emit) {
    if (event.index != state.currentIndex) {
      emit(state.copyWith(isAnimating: true));
      emit(state.copyWith(
        currentIndex: event.index,
        isAnimating: false,
      ));
    }
  }
}

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object> get props => [];
}

// States
class NavigationState extends Equatable {
  final int currentIndex;
  final bool isAnimating;
  const NavigationState({
    this.currentIndex = 0,
    this.isAnimating = false,
  });

  @override
  List<Object> get props => [currentIndex, isAnimating];

  NavigationState copyWith({
    int? currentIndex,
    bool? isAnimating,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }
}
