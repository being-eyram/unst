import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:unst/myapp.dart';
import 'package:unst/outfit_screen/outfit_screen.dart';
// import 'package:unst/outfit_notifier/outfit_notifier.dart';
import 'firebase_options.dart';


import 'services/gemini_services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final geminiService = GeminiService();

  runApp(
    MultiProvider(
      providers: [
        Provider<GeminiService>(create: (_) => geminiService),
        // ChangeNotifierProvider<OutfitNotifier>(
        //   create: (ctx) => OutfitNotifier(geminiService),
        // ),
      ],
      child: const PromptScreen(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Outfit Generator',
      home: PromptScreen(),
    );
  }
}
