part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const home = '/home';
  static const auth = '/auth';
  static const resetPass = '/auth/reset-password';
  static const archive = '/archive';
  static const trash = '/trash';
  static const label = '/label';
  static const editLabels = '/label/edit-labels';
  static const selectLabels = '/label/select-labels';
  static const note = '/note';
  static const remind = '/remind';
  static const search = '/search';
  static const settings = '/settings';
  static const drawPad = '/drawPad';
}
