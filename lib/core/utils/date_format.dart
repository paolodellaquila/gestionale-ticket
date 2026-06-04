import 'package:intl/intl.dart';

final _dateTime = DateFormat('dd/MM/yyyy HH:mm');
final _dateOnly = DateFormat('dd/MM/yyyy');

const _weekdays = [
  'lunedì',
  'martedì',
  'mercoledì',
  'giovedì',
  'venerdì',
  'sabato',
  'domenica',
];

const _months = [
  'gennaio',
  'febbraio',
  'marzo',
  'aprile',
  'maggio',
  'giugno',
  'luglio',
  'agosto',
  'settembre',
  'ottobre',
  'novembre',
  'dicembre',
];

String formatDateTime(DateTime dt) => _dateTime.format(dt);
String formatDate(DateTime dt) => _dateOnly.format(dt);

String formatFullDate(DateTime dt) {
  return '${_weekdays[dt.weekday - 1]} ${dt.day} ${_months[dt.month - 1]} ${dt.year}';
}
