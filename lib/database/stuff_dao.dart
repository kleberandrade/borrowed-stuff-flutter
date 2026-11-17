import 'package:sembast/sembast.dart';
import '../models/stuff.dart';

abstract interface class LoanRepository {
  Future<Stuff> save(Stuff item);
  Future<void> delete(Stuff item);
  Future<List<Stuff>> readAll();
  Future<void> addDemo();
}

class StuffDao implements LoanRepository {
  final Database database;
  final store = intMapStoreFactory.store('Stuff');
  StuffDao(this.database);

  @override
  Future<Stuff> save(Stuff item) async {
    if (item.id == null) {
      final key = await store.add(database, item.toMap());
      return item.withIdentity(key);
    }
    await store.record(item.id!).put(database, item.toMap());
    return item;
  }

  @override
  Future<void> delete(Stuff item) async {
    await store.record(item.id!).delete(database);
  }

  @override
  Future<List<Stuff>> readAll() async {
    final records = await store.find(database);
    final items = records
        .map((r) => Stuff.fromMap(r.value, id: r.key))
        .toList();
    items.sort((a, b) => b.loanDate.compareTo(a.loanDate));
    return items;
  }

  @override
  Future<void> addDemo() async {
    await database.transaction((txn) async {
      if (await store.count(txn) != 0) return;
      for (final entry in [
        ('O Hobbit', 'Marina Costa', 3),
        ('Câmera instantânea', 'Lucas Santos', 7),
        ('Furadeira', 'Rafael Lima', 12),
      ]) {
        final item = Stuff(
          description: entry.$1,
          contactName: entry.$2,
          loanDate: DateTime.now().subtract(Duration(days: entry.$3)),
        );
        await store.add(txn, item.toMap());
      }
    });
  }
}
