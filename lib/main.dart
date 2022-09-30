import 'package:fatec/app/pages/home_page.dart';
import 'package:fatec/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  //! Adiciono a inicialização do Firebase no aplicativo
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //! Mudar o nome do aplicativo
      title: 'Curso - FATEC',
      //! Retirar o banner de debug
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        //! Corrigir a cor dos icones do aplicativo
        iconTheme: const IconThemeData(
          color: Colors.blue,
        ),
      ),
      home: const HomePage(),
    );
  }
}
