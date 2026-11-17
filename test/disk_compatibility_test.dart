import 'dart:io';

import 'package:borrowed_stuff/database/stuff_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sembast/sembast_io.dart';

void main() {
  test('legacy file survives open, update and reopen with photo and exact calendar day', () async {
    final dir = await Directory.systemTemp.createTemp('borrowed-compat-');
    final path = '${dir.path}/borrowed_stuff.db';
    final store = intMapStoreFactory.store('Stuff');
    var db = await databaseFactoryIo.openDatabase(path);
    await store.record(3).put(db, {
      'id': 42,
      'description': 'Camera',
      'contactName': 'Ana',
      'loanDate': DateTime(2020, 3, 21, 23).millisecondsSinceEpoch,
      'photoPath': '/legacy/photo.jpg',
    });
    await db.close();
    db = await databaseFactoryIo.openDatabase(path);
    final dao = StuffDao(db);
    final item = (await dao.readAll()).single;
    await dao.save(item.withReturned(true));
    await db.close();
    db = await databaseFactoryIo.openDatabase(path);
    final restored = (await StuffDao(db).readAll()).single;
    expect(restored.id, 3);
    expect(restored.loanDate, DateTime(2020, 3, 21));
    expect(restored.photoPath, '/legacy/photo.jpg');
    expect(restored.returned, true);
    await db.close();
    await dir.delete(recursive: true);
  });
}
