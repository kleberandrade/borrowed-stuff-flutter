import 'dart:convert';

import 'package:material_ui/material_ui.dart';

import '../models/stuff.dart';
import 'legacy_photo_stub.dart' if (dart.library.io) 'legacy_photo_io.dart';

class LoanPhoto extends StatelessWidget {
  final Stuff item;
  final double size;
  const LoanPhoto({super.key, required this.item, this.size = 100});
  @override
  Widget build(BuildContext context) {
    Widget fallback() => const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 30,
        color: Color(0xff285c4b),
      ),
    );
    Widget child = fallback();
    try {
      if (item.photoBase64 != null) {
        child = Image.memory(
          base64Decode(item.photoBase64!),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => fallback(),
        );
      } else if (item.photoPath?.isNotEmpty == true) {
        child = legacyPhoto(item.photoPath!, fallback());
      }
    } on FormatException {
      child = fallback();
    }
    return Semantics(
      label: 'Foto de ${item.description}',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: size,
          height: size,
          child: ColoredBox(color: const Color(0xffe6ede6), child: child),
        ),
      ),
    );
  }
}
