import 'package:borrowed_stuff/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emprestei?',
      theme: _buildTheme(),
      home: HomePage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
        const Locale('en', 'US'),
      ],
    );
  }

  // Ciando um tema para o projeto
  _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: Color(0xFF212121),
      accentColor: Colors.deepOrange,
      primarySwatch: Colors.deepOrange,
    );
  }
}
