/// A loan uses local calendar dates, never UTC instants for display.
class Stuff {
  final int? id;
  final String description;
  final String contactName;
  final DateTime loanDate;
  final String? photoPath;
  final String? photoBase64;
  final String phone;
  final bool returned;

  Stuff({
    this.id,
    required String description,
    required String contactName,
    required DateTime loanDate,
    this.photoPath,
    this.photoBase64,
    this.phone = '',
    this.returned = false,
    bool validate = true,
  }) : description = description.trim(),
       contactName = contactName.trim(),
       loanDate = DateTime(loanDate.year, loanDate.month, loanDate.day) {
    if (validate) {
      if (this.description.isEmpty || this.contactName.isEmpty) {
        throw ArgumentError('Objeto e pessoa são obrigatórios.');
      }
      if (this.loanDate.isAfter(DateTime.now())) {
        throw ArgumentError('A data não pode estar no futuro.');
      }
      if (phone.isNotEmpty && !validPhone(phone)) {
        throw ArgumentError('Informe um telefone válido.');
      }
    }
  }

  static bool validPhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return RegExp(r'^\+?[\d ()-]{8,20}$').hasMatch(value) &&
        digits.length >= 8 &&
        digits.length <= 15;
  }

  factory Stuff.fromMap(Map<String, Object?> map, {required int id}) {
    final calendar = map['calendarDate'] as String?;
    return Stuff(
      id: id,
      description: map['description'] as String,
      contactName: map['contactName'] as String,
      loanDate: calendar == null
          ? DateTime.fromMillisecondsSinceEpoch(map['loanDate'] as int)
          : DateTime.parse(calendar),
      photoPath: map['photoPath'] as String?,
      photoBase64: map['photoBase64'] as String?,
      phone: map['phone'] as String? ?? '',
      returned: map['returned'] as bool? ?? false,
      // Legacy records may contain dates or empty fields accepted by the old app.
      validate: false,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'description': description,
    'contactName': contactName,
    'loanDate': loanDate.millisecondsSinceEpoch,
    'calendarDate':
        '${loanDate.year.toString().padLeft(4, '0')}-${loanDate.month.toString().padLeft(2, '0')}-${loanDate.day.toString().padLeft(2, '0')}',
    'photoPath': photoPath,
    'photoBase64': photoBase64,
    'phone': phone,
    'returned': returned,
    'schemaVersion': 2,
  };

  Stuff withIdentity(int key) => Stuff.fromMap(toMap(), id: key);
  Stuff withReturned(bool value) =>
      Stuff.fromMap({...toMap(), 'returned': value}, id: id!);
}
