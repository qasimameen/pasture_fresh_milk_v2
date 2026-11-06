import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlMadinaDairyApp());
}
// import 'package:flutter/foundation.dart'; // Provides kIsWeb
// import 'package:flutter/material.dart';
// import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'; // Web database factory
// import 'package:sqflite/sqflite.dart';

// import 'app.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize the database ONLY when running in a web browser like Chrome
//   if (kIsWeb) {
//     databaseFactory = databaseFactoryFfiWeb;
//   }

//   runApp(const AlMadinaDairyApp());
// }
