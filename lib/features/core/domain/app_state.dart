import 'package:flutter/material.dart';

import '../../../models/qr_response_model.dart';
import '../../../models/qr_user_model.dart';
import '../../../utils/logger_utils.dart';
import '../../auth/domain/auth_factory.dart';
import '../../notes/domain/entities/quran_note.dart';
import '../../notes/domain/notes_manager.dart';
import '../../tags/domain/entities/quran_tag.dart';
import '../../tags/domain/entities/quran_tag_aya.dart';
import '../../tags/domain/tags_manager.dart';
import 'package:redux/redux.dart';

/// STATE
///
@immutable
class AppState {
  final List<QuranTag> originalTags;
  final List<QuranNote> originalNotes;
  final Map<String, List<String>> tags;
  final Map<String, List<QuranNote>> notes;
  final StateError? error;
  final bool isLoading;

  const AppState({
    this.tags = const {},
    this.notes = const {},
    this.originalTags = const [],
    this.originalNotes = const [],
    this.error,
    this.isLoading = false,
  });

  AppState copyWith({
    List<QuranTag>? originalTags,
    List<QuranNote>? originalNotes,
    Map<String, List<String>>? tags,
    Map<String, List<QuranNote>>? notes,
    StateError? error,
    bool? isLoading,
  }) {
    return AppState(
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      originalTags: originalTags ?? this.originalTags,
      originalNotes: originalNotes ?? this.originalNotes,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<String>? getTags(
    int surahIndex,
    int ayaIndex,
  ) {
    String key = "${surahIndex}_$ayaIndex";

    return tags[key];
  }

  List<QuranNote>? getNotes(
    int surahIndex,
    int ayaIndex,
  ) {
    String key = "${surahIndex}_$ayaIndex";

    return notes[key];
  }

  @override
  String toString() {
    return "Tags: ${originalTags.length}, Notes: ${originalNotes.length}, Error: $error, isLoading: $isLoading";
  }
}

enum AppStateTagModifyAction { create, addAya, removeAya, delete }

/// ACTIONS
///

class AppStateAction {
  @override
  String toString() {
    return "$runtimeType";
  }
}

class AppStateInitializeAction extends AppStateAction {}

class AppStateResetAction extends AppStateAction {}

/// TAG ACTIONS
///
class AppStateFetchTagsAction extends AppStateAction {}

class AppStateLoadingAction extends AppStateAction {
  final bool isLoading;

  AppStateLoadingAction({
    required this.isLoading,
  });
}

class AppStateModifyTagAction extends AppStateAction {
  final int surahIndex;
  final int ayaIndex;
  final String tag;
  final AppStateTagModifyAction action;

  AppStateModifyTagAction({
    required this.surahIndex,
    required this.ayaIndex,
    required this.tag,
    required this.action,
  });
}

class AppStateFetchTagsSucceededAction extends AppStateAction {
  final List<QuranTag> fetchedTags;

  AppStateFetchTagsSucceededAction(
    this.fetchedTags,
  );
}

class AppStateFetchNotesSucceededAction extends AppStateAction {
  final List<QuranNote> fetchedNotes;

  AppStateFetchNotesSucceededAction(
    this.fetchedNotes,
  );
}

class AppStateModifyTagSucceededAction extends AppStateAction {}

class AppStateModifyTagFailureAction extends AppStateAction {
  final String message;

  AppStateModifyTagFailureAction({
    required this.message,
  });
}

/// NOTES ACTIONS
///
class AppStateFetchNotesAction extends AppStateAction {}

class AppStateCreateNoteAction extends AppStateAction {
  final QuranNote note;

  AppStateCreateNoteAction({
    required this.note,
  });
}

class AppStateCreateNoteSucceededAction extends AppStateAction {}

class AppStateDeleteNoteAction extends AppStateAction {
  final QuranNote note;

  AppStateDeleteNoteAction({
    required this.note,
  });
}

class AppStateDeleteNoteSucceededAction extends AppStateAction {}

class AppStateUpdateNoteAction extends AppStateAction {
  final QuranNote note;

  AppStateUpdateNoteAction({
    required this.note,
  });
}

class AppStateUpdateNoteSucceededAction extends AppStateAction {}

class AppStateNotesFailureAction extends AppStateAction {
  final String message;

  AppStateNotesFailureAction({
    required this.message,
  });
}

/// REDUCER
///

AppState appStateReducer(
  AppState state,
  dynamic action,
) {
  if (action is AppStateFetchTagsSucceededAction) {
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
  } else if (action is AppStateResetAction) {
    // Reset Tag
    return const AppState(tags: {});
  } else if (action is AppStateModifyTagFailureAction) {
    return state.copyWith(error: StateError(action.message));
  } else if (action is AppStateLoadingAction) {
    return state.copyWith(isLoading: action.isLoading);
  } else if (action is AppStateFetchNotesSucceededAction) {
    Map<String, List<QuranNote>> stateNotes = {};
    for (QuranNote note in action.fetchedNotes) {
      String key = "${note.suraIndex}_${note.ayaIndex}";
      if (stateNotes[key] == null) {
        stateNotes[key] = [];
      }
      stateNotes[key]?.add(note);
    }

    return state.copyWith(
      originalNotes: action.fetchedNotes,
      notes: stateNotes,
    );
  }

  return state;
}

/// MIDDLEWARE
///

void appStateMiddleware(
  Store<AppState> store,
  dynamic action,
  NextDispatcher next,
) async {
  if (action is AppStateInitializeAction) {
    // Initialization actions
    store.dispatch(AppStateFetchTagsAction());
    store.dispatch(AppStateFetchNotesAction());
  } else if (action is AppStateFetchTagsAction) {
    // Fetch tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      List<QuranTag> tags = await QuranTagsManager.instance.fetchAll(
        user.uid,
      );
      store.dispatch(AppStateFetchTagsSucceededAction(tags));
    }
  } else if (action is AppStateModifyTagAction) {
    // Modify tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      String userId = user.uid;
      switch (action.action) {
        case AppStateTagModifyAction.create:
          QuranResponse response = await QuranTagsManager.instance.create(
            userId,
            action.tag,
          );
          if (response.isSuccessful) {
            store.dispatch(AppStateModifyTagSucceededAction());
          } else {
            store.dispatch(AppStateModifyTagFailureAction(
              message: "Error creating tag - ${action.tag}",
            ));
          }
          break;

        case AppStateTagModifyAction.removeAya:
          try {
            QuranTag masterTag = store.state.originalTags
                .firstWhere((element) => element.name == action.tag);
            masterTag.ayas.removeWhere((element) =>
                element.suraIndex == action.surahIndex &&
                element.ayaIndex == action.ayaIndex);
            if (await QuranTagsManager.instance.update(
              userId,
              masterTag,
            )) {
              store.dispatch(AppStateModifyTagSucceededAction());
            } else {
              store.dispatch(
                AppStateModifyTagFailureAction(message: "Error updating"),
              );
            }
          } catch (error) {
            print(error);
          }
          break;

        case AppStateTagModifyAction.addAya:
          try {
            QuranTag masterTag = store.state.originalTags
                .firstWhere((element) => element.name == action.tag);
            masterTag.ayas.removeWhere((element) =>
                element.suraIndex == action.surahIndex &&
                element.ayaIndex == action.ayaIndex);
            masterTag.ayas.add(QuranTagAya(
              suraIndex: action.surahIndex,
              ayaIndex: action.ayaIndex,
            ));
            if (await QuranTagsManager.instance.update(
              userId,
              masterTag,
            )) {
              store.dispatch(AppStateModifyTagSucceededAction());
            } else {
              store.dispatch(
                AppStateModifyTagFailureAction(message: "Error updating"),
              );
            }
          } catch (error) {
            print(error);
          }
          break;

        case AppStateTagModifyAction.delete:
          // TODO: Not implemented
          break;
      }

      store.dispatch(AppStateFetchTagsAction());
    }
  } else if (action is AppStateFetchNotesAction) {
    // Fetch tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      List<QuranNote> notes = await QuranNotesManager.instance.fetchAll(
        user.uid,
      );
      store.dispatch(AppStateFetchNotesSucceededAction(notes));
    }
  } else if (action is AppStateCreateNoteAction) {
    // Fetch tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      QuranResponse response = await QuranNotesManager.instance.create(
        user.uid,
        action.note,
      );
      if (response.isSuccessful) {
        store.dispatch(AppStateCreateNoteSucceededAction());
      } else {
        store.dispatch(
          AppStateNotesFailureAction(message: "Error creating note"),
        );
      }
    }
    store.dispatch(AppStateFetchNotesAction());
  } else if (action is AppStateDeleteNoteAction) {
    // Fetch tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      bool status = await QuranNotesManager.instance.delete(
        user.uid,
        action.note,
      );
      if (status) {
        store.dispatch(AppStateDeleteNoteSucceededAction());
      } else {
        store.dispatch(
          AppStateNotesFailureAction(message: "Error deleting note"),
        );
      }
    }
    store.dispatch(AppStateFetchNotesAction());
  } else if (action is AppStateUpdateNoteAction) {
    // Fetch tags
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      bool status = await QuranNotesManager.instance.update(
        user.uid,
        action.note,
      );
      if (status) {
        store.dispatch(AppStateUpdateNoteSucceededAction());
      } else {
        store.dispatch(
          AppStateNotesFailureAction(message: "Error updating note"),
        );
      }
    }
    store.dispatch(AppStateFetchNotesAction());
  }
  next(action);
}

class LoggerMiddleware<State> implements MiddlewareClass<State> {
  @override
  void call(
    Store<State> store,
    dynamic action,
    NextDispatcher next,
  ) {
    next(action);

    QuranLogger.log("Logger: Action: $action, State: {${store.state}}");
  }
}
