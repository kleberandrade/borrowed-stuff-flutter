import 'package:borrowed_stuff/database/stuff_dao.dart';
import 'package:borrowed_stuff/models/stuff.dart';

class HomeController {
  final _stuffDao = StuffDao();
  final stuffList = [];

  void create(Stuff stuff) {
    _stuffDao.create(stuff);
    stuffList.add(stuff);
  }

  Future<void> readAll() async {
    final list = await _stuffDao.readAll();
    stuffList.addAll(list);
  }

  void update(int index, Stuff stuff) {
    _stuffDao.update(stuff);
    stuffList[index] = stuff;
  }

  void delete(Stuff stuff) {
    _stuffDao.delete(stuff);
    stuffList.remove(stuff);
  }
}
