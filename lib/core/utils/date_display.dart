import 'package:intl/intl.dart';

String formatShortDate(DateTime d) => '\u2066${DateFormat('dd/MM/yyyy', 'en').format(d)}\u2069';
