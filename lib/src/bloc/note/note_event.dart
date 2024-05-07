part of 'note_bloc.dart';

class NoteEvent extends Equatable {
  const NoteEvent();

  @override
  List<Object> get props => [];
}

class GetHomeNotesEvent extends NoteEvent {}

class GetNoteByLabelEvent extends NoteEvent {
  final String label;
  GetNoteByLabelEvent(this.label);
}

class GetRemindNotesEvent extends NoteEvent {}

class GetTrashNotesEvent extends NoteEvent {}

class GetArchivedNotesEvent extends NoteEvent {}

class CreateNoteEvent extends NoteEvent {
  final NoteModel noteModel;
  CreateNoteEvent(this.noteModel);
}

class ReadNoteEvent extends NoteEvent {
  final String noteId;
  ReadNoteEvent(this.noteId);
}

class UpdateNoteEvent extends NoteEvent {
  final String noteId;
  final NoteModel noteModel;
  UpdateNoteEvent(this.noteId, this.noteModel);
}

class DeleteNoteEvent extends NoteEvent {
  final String noteId;
  DeleteNoteEvent(this.noteId);
}
