import 'dart:io';

import 'package:flutter/widgets.dart';

Widget legacyPhoto(String path, Widget fallback) => Image.file(
  File(path),
  fit: BoxFit.cover,
  errorBuilder: (_, _, _) => fallback,
);
