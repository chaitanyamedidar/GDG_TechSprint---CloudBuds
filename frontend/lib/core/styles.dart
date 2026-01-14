import 'package:flutter/material.dart';

class AppleShadows {
  static const card = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.12),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  static const button = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.18),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const navbar = BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.25),
    blurRadius: 6,
    offset: Offset(0, 1),
  );
}
