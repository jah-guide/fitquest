import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

MemoryImage placeholderImageProvider() {
  // 1x1 transparent PNG (small bundled placeholder). Replace with a real asset if desired.
  const base64Png =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=';
  final bytes = base64Decode(base64Png);
  return MemoryImage(Uint8List.fromList(bytes));
}
