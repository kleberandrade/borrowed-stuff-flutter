import 'package:borrowed_stuff/models/stuff.dart';
import 'package:sembast/sembast.dart';

import 'app_database.dart';

class StuffDao {
  static const String folderName = "Stuff";
  final _stuffFolder = intMapStoreFactory.store(folderName);

  Future<Database> get _db async => await AppDatabase.instance.database;

  Future create(Stuff stuff) async {
    stuff.id = await _stuffFolder.add(await _db, stuff.toMap());  

    final finder = Finder(filter: Filter.equals('description', stuff.description));
    await _stuffFolder.update(await _db, stuff.toMap(), finder: finder);
  }

  Future update(Stuff stuff) async {
    final finder = Finder(filter: Filter.byKey(stuff.id));
    await _stuffFolder.update(await _db, stuff.toMap(), finder: finder);
  }

  Future delete(Stuff stuff) async {
    final finder = Finder(filter: Filter.byKey(stuff.id));
    await _stuffFolder.delete(await _db, finder: finder);
  }

  Future<List<Stuff>> readAll() async {
    final recordSnapshot = await _stuffFolder.find(await _db);
    return recordSnapshot.map((snapshot) {
      final student = Stuff.fromMap(snapshot.value);
      return student;
    }).toList();
  }
}
