import 'package:flutter/material.dart';

class Ikonlar {
  static const String _basePath = 'assets/icons/illustration/';

  // Helper method - tüm ikonlar için
  static Widget _buildIcon(String name, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        '$_basePath$name.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: size * 0.6,
            color: Colors.grey,
          );
        },
      ),
    );
  }

  // Beslenme
  static Widget bottle({double size = 24}) => _buildIcon('bottle', size);
  static Widget nursing({double size = 24}) => _buildIcon('nursing', size);
  static Widget breastfeeding({double size = 24}) =>
      _buildIcon('nursing', size);

  // Bez
  static Widget diaperClean({double size = 24}) =>
      _buildIcon('diaper_clean', size);
  static Widget diaperWet({double size = 24}) => _buildIcon('diaper_wet', size);
  static Widget diaperDirty({double size = 24}) =>
      _buildIcon('diaper_dirty', size);

  // Uyku
  static Widget sleep({double size = 24}) => _buildIcon('sleeping', size);
  static Widget sleeping({double size = 24}) => _buildIcon('sleeping', size);
  static Widget sleepingMoon({double size = 24}) =>
      _buildIcon('sleeping_moon', size);
  static Widget sleepingMoonnight({double size = 24}) =>
      _buildIcon('sleeping_moon', size);

  // Navigasyon
  static Widget home({double size = 24}) => _buildIcon('home', size);
  static Widget search({double size = 24}) => _buildIcon('search', size);
  static Widget favorites({double size = 24}) => _buildIcon('favorites', size);
  static Widget settings({double size = 24}) => _buildIcon('settings', size);
  static Widget notifications({double size = 24}) =>
      _buildIcon('notifications', size);

  // Diğer
  static Widget cuddle({double size = 24}) => _buildIcon('cuddle', size);
  static Widget river({double size = 24}) => _buildIcon('river', size);
  static Widget timer({double size = 24}) => _buildIcon('timer', size);

  // Büyüme
  static Widget growth({double size = 24}) => _buildIcon('growing', size);
  static Widget growing({double size = 24}) => _buildIcon('growing', size);

  // Memory
  static Widget memory({double size = 24}) => _buildIcon('favorites', size);

  // Sol/Sağ meme
  static Widget leftBreast({double size = 24}) => _buildIcon('nursing', size);
  static Widget rightBreast({double size = 24}) => _buildIcon('nursing', size);
}
