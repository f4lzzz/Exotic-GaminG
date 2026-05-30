import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'splash_screen.dart';
import 'state/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize locale Indonesia
  await initializeDateFormatting('id_ID', null);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ExoticApp(),
    ),
  );
}

class ExoticApp extends StatelessWidget {
  const ExoticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exotic Gaming & Cafe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const SplashScreen(),
    );
  }
}
