import 'package:flutter/foundation.dart';
import '../database/stuff_dao.dart';
import '../models/stuff.dart';

class HomeController extends ChangeNotifier {
  final LoanRepository dao;
  HomeController(this.dao);
  List<Stuff> items = [];
  bool busy = false;
  String? error;

  Future<void> load() async {
    await run(() async {});
  }

  Future<bool> run(Future<void> Function() operation) async {
    if (busy) return false;
    busy = true;
    error = null;
    notifyListeners();
    try {
      await operation();
      items = await dao.readAll();
      return true;
    } catch (_) {
      error = 'Não foi possível acessar os dados. Tente novamente.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
