import 'package:redux/redux.dart';
import '../../../../../notes/domain/redux/reducers/reducer.dart';
import '../../../../../tags/domain/redux/reducers/reducer.dart';
import '../../app_state.dart';

/// REDUCER
///
Reducer<AppState> appStateReducer = combineReducers<AppState>([
  TypedReducer<AppState, AppStateInitializeAction>(
    _initializeAppStateReducer,
  ),
  TypedReducer<AppState, AppStateResetAction>(
    _resetAppStateReducer,
  ),
  TypedReducer<AppState, AppStateLoadingAction>(
    _loadingAppStateReducer,
  ),
  TypedReducer<AppState, AppStateResetStatusAction>(
    _resetAppStateStatusReducer,
  ),
  TypedReducer<AppState, dynamic>(
    _allOtherReducer,
  ),
]);

// redirect everything else to child states
AppState _allOtherReducer(
  AppState state,
  dynamic action,
) {
  return state.copyWith(
    tags: tagReducer(
      state.tags,
      action,
    ),
    notes: notesReducer(
      state.notes,
      action,
    ),
  );
}

AppState _initializeAppStateReducer(
  AppState state,
  AppStateInitializeAction action,
) {
  return state.copyWith(
    tags: tagReducer(
      state.tags,
      action,
    ),
    notes: notesReducer(
      state.notes,
      action,
    ),
  );
}

AppState _resetAppStateReducer(
  AppState state,
  AppStateResetAction action,
) {
  return const AppState();
}

AppState _loadingAppStateReducer(
  AppState state,
  AppStateLoadingAction action,
) {
  return state.copyWith(isLoading: action.isLoading);
}

AppState _resetAppStateStatusReducer(
  AppState state,
  AppStateResetStatusAction action,
) {
  return state.copyWith(
    lastActionStatus: const AppStateActionStatus(
      action: "",
      message: "",
    ),
  );
}
