import 'package:redux/redux.dart';

import '../../../../core/domain/app_state/redux/actions/actions.dart';
import '../../entities/quran_tag.dart';
import '../../entities/quran_tag_aya.dart';
import '../actions/actions.dart';
import '../tag_state.dart';

/// TAGS REDUCER
///
Reducer<TagState> tagReducer =
    combineReducers<TagState>([
  TypedReducer<TagState, FetchTagsSucceededAction>(
    _fetchTagsSuccessReducer,
  ),
  TypedReducer<TagState, AddTagSucceededAction>(
    _addTagsSuccessReducer,
  ),
  TypedReducer<TagState, AddTagFailureAction>(
    _addTagsFailureReducer,
  ),
  TypedReducer<TagState, ResetTagsStatusAction>(
    _resetTagsReducer,
  ),
  TypedReducer<TagState, CreateTagSucceededAction>(
    _createTagsSuccessReducer,
  ),
  TypedReducer<TagState, CreateTagFailureAction>(
    _createTagsFailureReducer,
  ),
]);

TagState _fetchTagsSuccessReducer(
  TagState state,
  FetchTagsSucceededAction action,
) {
  Map<String, List<String>> stateTags = {};
  for (QuranTag tag in action.fetchedTags) {
    for (QuranTagAya aya in tag.ayas) {
      String key = "${aya.suraIndex}_${aya.ayaIndex}";
      if (stateTags[key] == null) {
        stateTags[key] = [];
      }
      stateTags[key]?.add(tag.name);
    }
  }

  return state.copyWith(
    originalTags: action.fetchedTags,
    tags: stateTags,
  );
}

TagState _createTagsSuccessReducer(
    TagState state,
    CreateTagSucceededAction action,
    ) {
  return state.copyWith(
    lastActionStatus: AppStateActionStatus(
      action: action.runtimeType.toString(),
      message: action.message,
    ),
  );
}

TagState _createTagsFailureReducer(
    TagState state,
    CreateTagFailureAction action,
    ) {
  return state.copyWith(
    lastActionStatus: AppStateActionStatus(
      action: action.runtimeType.toString(),
      message: action.message,
    ),
  );
}

TagState _addTagsSuccessReducer(
  TagState state,
  AddTagSucceededAction action,
) {
  return state.copyWith(
    lastActionStatus: AppStateActionStatus(
      action: action.runtimeType.toString(),
      message: action.message,
    ),
  );
}

TagState _addTagsFailureReducer(
  TagState state,
  AddTagFailureAction action,
) {
  return state.copyWith(
    lastActionStatus: AppStateActionStatus(
      action: action.runtimeType.toString(),
      message: action.message,
    ),
  );
}

TagState _resetTagsReducer(
  TagState state,
  ResetTagsStatusAction action,
) {
  return state.copyWith(
    lastActionStatus: const AppStateActionStatus(
      action: "",
      message: "",
    ),
  );
}
