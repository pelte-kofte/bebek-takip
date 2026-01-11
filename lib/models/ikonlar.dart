import 'package:flutter/material.dart';

class Ikonlar {
  // Basit Material Icons kullanıyoruz - her zaman net!

  static Widget _buildIcon(IconData icon, double size, Color color) {
    return Icon(icon, size: size, color: color);
  }

  // BESLENME
  static Widget bottle({double size = 24, Color? color}) => _buildIcon(
    Icons.baby_changing_station,
    size,
    color ?? const Color(0xFFFF9800),
  );

  static Widget nursing({double size = 24, Color? color}) =>
      _buildIcon(Icons.child_care, size, color ?? const Color(0xFFE91E63));

  static Widget breastfeeding({double size = 24, Color? color}) =>
      nursing(size: size, color: color);
  static Widget leftBreast({double size = 24, Color? color}) =>
      nursing(size: size, color: color);
  static Widget rightBreast({double size = 24, Color? color}) =>
      nursing(size: size, color: color);

  // UYKU
  static Widget sleep({double size = 24, Color? color}) => _buildIcon(
    Icons.nightlight_round,
    size,
    color ?? const Color(0xFF673AB7),
  );

  static Widget sleeping({double size = 24, Color? color}) =>
      sleep(size: size, color: color);
  static Widget sleepingMoon({double size = 24, Color? color}) =>
      sleep(size: size, color: color);
  static Widget sleepingMoonnight({double size = 24, Color? color}) =>
      sleep(size: size, color: color);

  // BEZ
  static Widget diaperClean({double size = 24, Color? color}) =>
      _buildIcon(Icons.clean_hands, size, color ?? const Color(0xFF03A9F4));

  static Widget diaperWet({double size = 24, Color? color}) =>
      _buildIcon(Icons.water_drop, size, color ?? const Color(0xFF03A9F4));

  static Widget diaperDirty({double size = 24, Color? color}) =>
      _buildIcon(Icons.delete_outline, size, color ?? const Color(0xFFFF9800));

  // BÜYÜME
  static Widget growth({double size = 24, Color? color}) =>
      _buildIcon(Icons.trending_up, size, color ?? const Color(0xFF4CAF50));

  static Widget growing({double size = 24, Color? color}) =>
      growth(size: size, color: color);
  static Widget river({double size = 24, Color? color}) =>
      growth(size: size, color: color);

  // DİĞER
  static Widget timer({double size = 24, Color? color}) =>
      _buildIcon(Icons.timer, size, color ?? const Color(0xFFFF9800));

  static Widget cuddle({double size = 24, Color? color}) =>
      _buildIcon(Icons.favorite, size, color ?? const Color(0xFFE91E63));
      
  static Widget parents({double size = 24, Color? color}) =>
      _buildIcon(Icons.favorite, size, color ?? const Color(0xFFE91E63));  

  static Widget notifications({double size = 24, Color? color}) =>
      _buildIcon(Icons.notifications, size, color ?? const Color(0xFFE91E63));

  static Widget home({double size = 24, Color? color}) =>
      _buildIcon(Icons.home, size, color ?? const Color(0xFF673AB7));

  static Widget search({double size = 24, Color? color}) =>
      _buildIcon(Icons.search, size, color ?? const Color(0xFF03A9F4));

  static Widget favorites({double size = 24, Color? color}) =>
      _buildIcon(Icons.favorite, size, color ?? const Color(0xFFE91E63));

  static Widget settings({double size = 24, Color? color}) =>
      _buildIcon(Icons.settings, size, color ?? const Color(0xFF757575));

  static Widget memory({double size = 24, Color? color}) =>
      favorites(size: size, color: color);
}
