import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/note_model.dart';
import '../../data/services/note_svc.dart';

part 'note_event.dart';
part 'note_state.dart';

class HomeNoteBloc extends NoteBloc {
  HomeNoteBloc(super.service) {
    on<GetHomeNotesEvent>(_getHomeNotes);
  }

  Future<void> _getHomeNotes(
    GetHomeNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoadingState());
    try {
      final pinnedNotes = await service.getNotesByCriteriaStream(
        criteria: Criteria.pinnedHome,
      );
      final homeNotes = await service.getNotesByCriteriaStream(
        criteria: Criteria.home,
      );
      emit(HomeNotesLoadedState(pinnedNotes, homeNotes));
    } on Exception catch (e) {
      emit(NoteLoadErrorState(e.toString()));
    }
  }
}

class RemindNoteBloc extends NoteBloc {
  RemindNoteBloc(super.service) {
    on<GetRemindNotesEvent>(_getRemindNotes);
  }

  Future<void> _getRemindNotes(
    GetRemindNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final sentRemind = await service.getNotesByCriteriaStream(
        criteria: Criteria.sentRemind,
      );
      final upcommingRemind = await service.getNotesByCriteriaStream(
        criteria: Criteria.upcommingRemind,
      );
      emit(RemindNotesLoadedState(sentRemind, upcommingRemind));
    } on Exception catch (e) {
      emit(NoteLoadErrorState(e.toString()));
    }
  }
}

class ArchiveNoteBloc extends NoteBloc {
  ArchiveNoteBloc(super.service) {
    on<GetArchivedNotesEvent>(_getArchivedNotes);
  }

  Future<void> _getArchivedNotes(
    GetArchivedNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      final archiveNotes = await service.getNotesByCriteriaStream(
        criteria: Criteria.archive,
      );
      emit(ArchiveNotesLoadedState(archiveNotes));
    } on Exception catch (e) {
      emit(NoteLoadErrorState(e.toString()));
    }
  }
}

class TrashNoteBloc extends NoteBloc {
  TrashNoteBloc(super.service) {
    on<GetTrashNotesEvent>(_getTrashNotes);
  }

  Future<void> _getTrashNotes(
    GetTrashNotesEvent event,
    Emitter<NoteState> emit,
  ) async {
    await service.deleteOldTrashNotes();
    try {
      final trashNotes = await service.getNotesByCriteriaStream(
        criteria: Criteria.trash,
      );
      emit(TrashNotesLoadedState(trashNotes));
    } on Exception catch (e) {
      emit(NoteLoadErrorState(e.toString()));
    }
  }
}

class LabelNoteBloc extends NoteBloc {
  LabelNoteBloc(super.service) {
    on<GetNoteByLabelEvent>(_getNotesbyLabel);
  }

  Future<void> _getNotesbyLabel(
    GetNoteByLabelEvent event,
    Emitter<NoteState> emit,
  ) async {
    emit(NoteLoadingState());
    try {
      final notesByLabel = await service.getNotesByCriteriaStream(
        criteria: Criteria.byLabel,
        label: event.label,
      );
      emit(LabelNotesLoadedState(notesByLabel));
    } on Exception catch (e) {
      emit(NoteLoadErrorState(e.toString()));
    }
  }
}

class NoteViewBloc extends NoteBloc {
  NoteViewBloc(super.service) {
    on<UpdateNoteEvent>(_updateNote);
    on<DeleteNoteEvent>(_deleteNote);
    on<CreateNoteEvent>(_createNote);
  }

  Future<void> _createNote(
    CreateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await service.createNote(event.noteModel);
    } catch (e) {
      emit(NoteErrorState(e.toString()));
    }
  }

  Future<void> _deleteNote(
    DeleteNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await service.moveNoteToTrash(event.noteId);
    } catch (e) {
      emit(NoteErrorState(e.toString()));
    }
  }

  Future<void> _updateNote(
    UpdateNoteEvent event,
    Emitter<NoteState> emit,
  ) async {
    try {
      await service.updateNote(event.noteId, event.noteModel);
    } catch (e) {
      emit(NoteErrorState(e.toString()));
    }
  }
}

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  final NoteService service;
  NoteBloc(this.service) : super(NoteStateInital()) {}
}
