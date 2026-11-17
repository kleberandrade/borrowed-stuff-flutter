import 'package:borrowed_stuff/database/stuff_dao.dart';
import 'package:borrowed_stuff/models/stuff.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  test('demo is idempotent and embedded photos survive reload', () async {
    final db = await newDatabaseFactoryMemory().openDatabase('photos');
    final dao = StuffDao(db);
    await dao.addDemo();
    await dao.addDemo();
    expect((await dao.readAll()).length, 3);
    final photo = await dao.save(
      Stuff(
        description: 'Foto',
        contactName: 'Ana',
        loanDate: DateTime(2020),
        photoBase64: 'aGVsbG8=',
      ),
    );
    expect(
      (await dao.readAll()).firstWhere((i) => i.id == photo.id).photoBase64,
      'aGVsbG8=',
    );
    await db.close();
  });
  test(
    'legacy keys override corrupt embedded ids; duplicate descriptions stay independent',
    () async {
      final db = await newDatabaseFactoryMemory().openDatabase('legacy');
      final store = intMapStoreFactory.store('Stuff');
      await store.record(4).put(db, {
        'id': 99,
        'description': 'Livro',
        'contactName': 'Ana',
        'loanDate': DateTime(2020).millisecondsSinceEpoch,
        'photoPath': '/old.jpg',
      });
      final dao = StuffDao(db);
      final old = (await dao.readAll()).single;
      expect(old.id, 4);
      final other = await dao.save(
        Stuff(
          description: 'Livro',
          contactName: 'Bia',
          loanDate: DateTime(2021),
        ),
      );
      await dao.save(old.withReturned(true));
      expect((await dao.readAll()).length, 2);
      expect((await store.record(4).get(db))!['photoPath'], '/old.jpg');
      expect((await store.record(4).get(db))!['schemaVersion'], 2);
      await dao.delete(other);
      expect((await dao.readAll()).single.returned, true);
      await db.close();
    },
  );
}
