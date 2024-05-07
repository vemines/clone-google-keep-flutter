part of 'note_bloc.dart';

abstract class NoteState {
  const NoteState();
}

class NoteStateInital extends NoteState {}

class NoteLoadingState extends NoteState {}

class NoteLoaded extends NoteState {
  final NoteModel note;
  NoteLoaded(this.note);
}

class NoteLoadErrorState extends NoteState {
  final String message;
  NoteLoadErrorState(this.message);
}

class NoteErrorState extends NoteState {
  final String message;
  NoteErrorState(this.message);
}

class ArchiveNotesLoadedState extends NoteState {
  final Stream<List<NoteModel>> notes;
  ArchiveNotesLoadedState(this.notes);
}

class TrashNotesLoadedState extends NoteState {
  final Stream<List<NoteModel>> notes;
  TrashNotesLoadedState(this.notes);
}

class LabelNotesLoadedState extends NoteState {
  final Stream<List<NoteModel>> notes;
  LabelNotesLoadedState(this.notes);
}

class HomeNotesLoadedState extends NoteState {
  final Stream<List<NoteModel>> notes1;
  final Stream<List<NoteModel>> notes2;
  HomeNotesLoadedState(this.notes1, this.notes2);
}

class RemindNotesLoadedState extends NoteState {
  final Stream<List<NoteModel>> notes1;
  final Stream<List<NoteModel>> notes2;
  RemindNotesLoadedState(this.notes1, this.notes2);
}
