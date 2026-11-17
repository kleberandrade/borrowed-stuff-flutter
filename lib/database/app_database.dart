import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

Future<Database> openAppDatabase() async {
  if (kIsWeb) return databaseFactoryWeb.openDatabase('borrowed_stuff.db');
  final dir = await getApplicationDocumentsDirectory();
  return databaseFactoryIo.openDatabase(p.join(dir.path, 'borrowed_stuff.db'));
}
