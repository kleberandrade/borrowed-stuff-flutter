import 'package:borrowed_stuff/models/stuff.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('phone needs digits, not just formatting characters', () {
    expect(
      () => Stuff(
        description: 'Livro',
        contactName: 'Ana',
        loanDate: DateTime(2020),
        phone: '--------',
      ),
      throwsArgumentError,
    );
  });
  test('rejects whitespace names and future calendar dates', () {
    expect(
      () =>
          Stuff(description: ' ', contactName: 'Ana', loanDate: DateTime(2020)),
      throwsArgumentError,
    );
    expect(
      () => Stuff(
        description: 'Livro',
        contactName: ' ',
        loanDate: DateTime(2020),
      ),
      throwsArgumentError,
    );
    expect(
      () => Stuff(
        description: 'Livro',
        contactName: 'Ana',
        loanDate: DateTime.now().add(const Duration(days: 2)),
      ),
      throwsArgumentError,
    );
  });
  test(
    'reads legacy milliseconds and preserves photo path without timezone shifting',
    () {
      final date = DateTime(2020, 3, 12, 18);
      final item = Stuff.fromMap({
        'description': 'Livro',
        'contactName': 'Ana',
        'loanDate': date.millisecondsSinceEpoch,
        'photoPath': '/old/photo.jpg',
      }, id: 7);
      expect(item.id, 7);
      expect(item.loanDate, DateTime(2020, 3, 12));
      expect(item.photoPath, '/old/photo.jpg');
      expect(Stuff.fromMap(item.toMap(), id: 7).loanDate, item.loanDate);
    },
  );
}
