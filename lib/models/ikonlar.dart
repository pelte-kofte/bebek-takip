import 'package:flutter/material.dart';

class Ikonlar {
  static const String _basePath = 'assets/icons/illustration/';

  static Widget _buildIcon(String name, double size, Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.12),
      child: Image.asset(
        '$_basePath$name.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.error, size: size * 0.5, color: Colors.white);
        },
      ),
    );
  }

  // BESLENME
  static Widget bottle({double size = 24}) =>
      _buildIcon('bottle', size, const Color(0xFFFFB74D));

  static Widget nursing({double size = 24}) =>
      _buildIcon('nursing', size, const Color(0xFFFF8A80));

  static Widget breastfeeding({double size = 24}) => nursing(size: size);
  static Widget leftBreast({double size = 24}) => nursing(size: size);
  static Widget rightBreast({double size = 24}) => nursing(size: size);

  // UYKU
  static Widget sleep({double size = 24}) =>
      _buildIcon('sleeping', size, const Color(0xFFB39DDB));

  static Widget sleeping({double size = 24}) => sleep(size: size);

  static Widget sleepingMoon({double size = 24}) =>
      _buildIcon('sleeping_moon', size, const Color(0xFFB39DDB));

  static Widget sleepingMoonnight({double size = 24}) =>
      sleepingMoon(size: size);

  // BEZ
  static Widget diaperClean({double size = 24}) =>
      _buildIcon('diaper_clean', size, const Color(0xFF81D4FA));

  static Widget diaperWet({double size = 24}) =>
      _buildIcon('diaper_wet', size, const Color(0xFF4FC3F7));

  static Widget diaperDirty({double size = 24}) =>
      _buildIcon('diaper_dirty', size, const Color(0xFFFFCC80));

  // BÜYÜME
  static Widget growth({double size = 24}) =>
      _buildIcon('growing', size, const Color(0xFFA5D6A7));

  static Widget growing({double size = 24}) => growth(size: size);
  static Widget river({double size = 24}) => growth(size: size);

  // DİĞER
  static Widget timer({double size = 24}) =>
      _buildIcon('timer', size, const Color(0xFFFFB74D));

  static Widget cuddle({double size = 24}) =>
      _buildIcon('cuddle', size, const Color(0xFFFF8A80));

  // notification (s yok!)
  static Widget notifications({double size = 24}) =>
      _buildIcon('notification', size, const Color(0xFFFF8A80));

  static Widget home({double size = 24}) =>
      _buildIcon('home', size, const Color(0xFFB39DDB));

  static Widget search({double size = 24}) =>
      _buildIcon('search', size, const Color(0xFF81D4FA));

  static Widget favorites({double size = 24}) =>
      _buildIcon('favorites', size, const Color(0xFFFF8A80));

  static Widget settings({double size = 24}) =>
      _buildIcon('settings', size, const Color(0xFFBDBDBD));

  static Widget memory({double size = 24}) => favorites(size: size);
}
