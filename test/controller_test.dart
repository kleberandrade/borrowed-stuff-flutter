import 'package:borrowed_stuff/controllers/home_controller.dart';
import 'package:borrowed_stuff/database/stuff_dao.dart';
import 'package:borrowed_stuff/models/stuff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('failed write reports error and leaves visible state intact; retry recovers', () async {
    final repo = _FailingLoans();
    final controller = HomeController(repo);
    await controller.load();
    final ok = await controller.run(() async {
      throw StateError('disk full');
    });
    expect(ok, false);
    expect(controller.busy, false);
    expect(controller.error, contains('Tente novamente'));
    expect(controller.items.single.description, 'Livro');
    await controller.load();
    expect(controller.error, isNull);
    expect(controller.items.length, 1);
  });
}

class _FailingLoans implements LoanRepository {
  @override
  Future<List<Stuff>> readAll() async => [
    Stuff(description: 'Livro', contactName: 'Ana', loanDate: DateTime(2020)),
  ];
  @override
  Future<void> addDemo() async {}
  @override
  Future<void> delete(Stuff item) async {}
  @override
  Future<Stuff> save(Stuff item) async => item;
}
