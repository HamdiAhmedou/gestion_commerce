import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestion_commerce/app.dart';
import 'package:gestion_commerce/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile (optional — remove for tablet/desktop)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Init SQLite
  await DatabaseService().database;

  runApp(const App());
}