import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:noble_quran/models/surah_title.dart';
import 'package:noble_quran/noble_quran.dart';
import 'package:redux/redux.dart';
import '../../../misc/enums/quran_status_enum.dart';
import '../../../models/qr_user_model.dart';
import '../../../utils/utils.dart';
import '../../auth/domain/auth_factory.dart';
import '../../ayats/presentation/widgets/ayat_display_translation_widget.dart';
import '../../ayats/presentation/widgets/full_ayat_row_widget.dart';
import '../../core/domain/app_state/app_state.dart';
import '../domain/entities/quran_note.dart';
import '../domain/redux/actions/actions.dart';
import 'widgets/notes_create_controls_widget.dart';
import 'widgets/notes_update_controls_widget.dart';
import 'widgets/offline_header_widget.dart';

class QuranCreateNotesScreen extends StatefulWidget {
  final int suraIndex;
  final int ayaIndex;
  final QuranNote? note;

  const QuranCreateNotesScreen({
    Key? key,
    required this.suraIndex,
    required this.ayaIndex,
    this.note,
  }) : super(key: key);

  @override
  State<QuranCreateNotesScreen> createState() => _QuranCreateNotesScreenState();
}

class _QuranCreateNotesScreenState extends State<QuranCreateNotesScreen> {
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QuranOfflineHeaderWidget(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                5,
              ),
              child: Text(
                "Enter your notes for ${widget.suraIndex}:${widget.ayaIndex}",
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                10,
                10,
                5,
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: QuranFullAyatRowWidget(
                  futureMethodThatReturnsSelectedSurah:
                      NobleQuran.getSurahArabic(
                    widget.suraIndex - 1,
                  ),
                  ayaIndex: widget.ayaIndex,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                10,
                0,
                10,
                10,
              ),
              child: QuranAyatDisplayTranslationWidget(
                currentlySelectedSurah: NQSurahTitle(
                  number: widget.suraIndex,
                  name: '',
                  transliterationEn: '',
                  translationEn: '',
                  totalVerses: 0,
                  revelationType: RevelationType.MECCAN,
                ),
                currentlySelectedAya: widget.ayaIndex,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _notesController..text = widget.note?.note ?? "",
                maxLines: 10,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 0.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            widget.note == null
                ? QuranNotesCreateControlsWidget(
                    onConfirmation: () => {
                      _createButtonPressed(),
                    },
                  )
                : QuranUpdateControlsWidget(
                    onDelete: () => {
                      _deleteButtonPressed(),
                    },
                    onUpdate: () => _updateButtonPressed(),
                  ),
            const SizedBox(
              height: 20,
            ),
            StoreBuilder<AppState>(
              onDidChange: (
                old,
                updated,
              ) =>
                  _onStoreDidChange(),
              builder: (
                BuildContext context,
                Store<AppState> store,
              ) {
                if (store.state.notes.isLoading || store.state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }

  ///
  ///  BUTTON ACTIONS
  ///
  void _createButtonPressed() {
    if (_notesController.text.isNotEmpty) {
      QuranUser? user = QuranAuthFactory.engine.getUser();
      if (user != null) {
        QuranNote note = QuranNote(
          suraIndex: widget.suraIndex,
          ayaIndex: widget.ayaIndex,
          note: _notesController.text,
          createdOn: DateTime.now().millisecondsSinceEpoch,
          localId: QuranUtils.uniqueId(),
          status: QuranStatusEnum.created,
        );
        StoreProvider.of<AppState>(context).dispatch(CreateNoteAction(
          note: note,
        ));
      }
    } else {
      _showMessage("Sorry 😔, please enter a note");
    }
  }

  void _deleteButtonPressed() async {
    QuranUser? user = QuranAuthFactory.engine.getUser();
    if (user != null) {
      Widget okButton = TextButton(
        style: TextButton.styleFrom(foregroundColor: Colors.red),
        child: const Text("Delete"),
        onPressed: () => {
          if (_deleteNote())
            {
              Navigator.of(context).pop(),
            },
        },
      );

      Widget cancelButton = TextButton(
        child: const Text("Cancel"),
        onPressed: () => {Navigator.of(context).pop()},
      );

      AlertDialog alert = AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure?"),
        actions: [
          okButton,
          cancelButton,
        ],
      );

      showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      );
    }
  }

  bool _deleteNote() {
    QuranNote? noteParam = widget.note;
    if (noteParam != null) {
      StoreProvider.of<AppState>(context).dispatch(DeleteNoteAction(
        note: noteParam,
      ));

      return true;
    }

    return false;
  }

  void _updateButtonPressed() async {
    if (_notesController.text.isNotEmpty) {
      QuranUser? user = QuranAuthFactory.engine.getUser();
      if (user != null) {
        QuranNote? noteParam = widget.note;
        if (noteParam != null) {
          QuranNote note = noteParam.copyWith(
            createdOn: DateTime.now().millisecondsSinceEpoch,
            note: _notesController.text,
          );
          StoreProvider.of<AppState>(context).dispatch(UpdateNoteAction(
            note: note,
          ));
        } else {
          _showMessage("Sorry 😔, unable to update the note at the moment.");
        }
      }
    } else {
      _showMessage("Sorry 😔, please enter a note");
    }
  }

  void _showMessage(String message) {
    QuranUtils.showMessage(
      context,
      message,
    );
  }

  void _onStoreDidChange() {
    Store<AppState> store = StoreProvider.of<AppState>(context);
    AppStateActionStatus status = store.state.notes.lastActionStatus;
    if (status.action == (CreateNoteSucceededAction).toString()) {
      Navigator.of(context).pop();
      store.dispatch(ResetNotesStatusAction());
    } else if (status.action == (UpdateNoteSucceededAction).toString()) {
      QuranUtils.showMessage(
        context,
        status.message,
      );
      Navigator.of(context).pop();
      store.dispatch(ResetNotesStatusAction());
    } else if (status.action == (DeleteNoteSucceededAction).toString()) {
      QuranUtils.showMessage(
        context,
        status.message,
      );
      Navigator.of(context).pop();
      store.dispatch(ResetNotesStatusAction());
    } else if (status.action == (NotesFailureAction).toString()) {
      QuranUtils.showMessage(
        context,
        status.message,
      );
      store.dispatch(ResetNotesStatusAction());
    }
  }
}
