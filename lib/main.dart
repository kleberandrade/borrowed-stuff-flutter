import 'package:material_ui/material_ui.dart';

import 'controllers/home_controller.dart';
import 'database/app_database.dart';
import 'database/stuff_dao.dart';
import 'pages/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  final HomeController? controller;
  const MyApp({super.key, this.controller});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Emprestei?',
    locale: const Locale('pt', 'BR'),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    supportedLocales: const [Locale('pt', 'BR')],
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff285c4b)),
      scaffoldBackgroundColor: const Color(0xfff6f5f0),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: Color(0xfff6f5f0)),
    ),
    home: controller == null
        ? const _Bootstrap()
        : HomePage(controller: controller!),
  );
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  late Future<HomeController> future;
  @override
  void initState() {
    super.initState();
    future = open();
  }

  Future<HomeController> open() async =>
      HomeController(StuffDao(await openAppDatabase()));
  @override
  Widget build(BuildContext context) => FutureBuilder<HomeController>(
    future: future,
    builder: (context, snapshot) {
      if (snapshot.hasData) return HomePage(controller: snapshot.data!);
      return Scaffold(
        body: Center(
          child: snapshot.hasError
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Não foi possível abrir o diário.'),
                    FilledButton(
                      onPressed: () => setState(() {
                        future = open();
                      }),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                )
              : const CircularProgressIndicator(),
        ),
      );
    },
  );
}
