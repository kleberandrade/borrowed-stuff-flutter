import 'package:borrowed_stuff/main.dart';
import 'package:borrowed_stuff/controllers/home_controller.dart';
import 'package:borrowed_stuff/database/stuff_dao.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:borrowed_stuff/models/stuff.dart';

void main() {
  testWidgets(
    'empty state, validation, create, return and persistence at mobile width',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final dao = _MemoryLoans();
      await tester.pumpWidget(MyApp(controller: HomeController(dao)));
      await tester.pumpAndSettle();
      expect(find.text('Seu próximo empréstimo começa aqui'), findsOneWidget);
      await tester.tap(find.text('Novo empréstimo'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Salvar empréstimo'));
      await tester.tap(find.text('Salvar empréstimo'));
      await tester.pumpAndSettle();
      expect(find.text('Campo obrigatório'), findsNWidgets(2));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'Livro de teste',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'Ana');
      await tester.ensureVisible(find.text('Salvar empréstimo'));
      await tester.tap(find.text('Salvar empréstimo'));
      await tester.pumpAndSettle();
      expect((await dao.readAll()).single.description, 'Livro de teste');
      await tester.ensureVisible(find.text('Marcar devolução'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marcar devolução'));
      await tester.pumpAndSettle();
      expect((await dao.readAll()).single.returned, true);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _MemoryLoans implements LoanRepository {
  final List<Stuff> items = [];
  @override
  Future<List<Stuff>> readAll() async => List.of(items);
  @override
  Future<Stuff> save(Stuff item) async {
    final saved = item.id == null ? item.withIdentity(items.length + 1) : item;
    items.removeWhere((i) => i.id == saved.id);
    items.add(saved);
    return saved;
  }

  @override
  Future<void> delete(Stuff item) async =>
      items.removeWhere((i) => i.id == item.id);
  @override
  Future<void> addDemo() async {}
}
