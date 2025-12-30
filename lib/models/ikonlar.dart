import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Ikonlar {
  static Widget add({double size = 32, Color? color}) {
    return _icon('add-48', size, color);
  }

  static Widget bottle({double size = 32, Color? color}) {
    return _icon('bottle-48', size, color);
  }

  static Widget breastfeeding({double size = 32, Color? color}) {
    return _icon('breastfeeding-48', size, color);
  }

  static Widget diaperClean({double size = 32, Color? color}) {
    return _icon('diaper-clean-48', size, color);
  }

  static Widget diaperDirty({double size = 32, Color? color}) {
    return _icon('diaper-dirty-48', size, color);
  }

  static Widget diaperWet({double size = 32, Color? color}) {
    return _icon('diaper-wet-48', size, color);
  }

  static Widget growth({double size = 32, Color? color}) {
    return _icon('growth-48', size, color);
  }

  static Widget leftBreast({double size = 32, Color? color}) {
    return _icon('left-breast-48', size, color);
  }

  static Widget rightBreast({double size = 32, Color? color}) {
    return _icon('right-breast-48', size, color);
  }

  static Widget memory({double size = 32, Color? color}) {
    return _icon('memory-48', size, color);
  }

  static Widget settings({double size = 32, Color? color}) {
    return _icon('settings-48', size, color);
  }

  static Widget sleep({double size = 32, Color? color}) {
    return _icon('sleep-48', size, color);
  }

  static Widget timer({double size = 32, Color? color}) {
    return _icon('timer-48', size, color);
  }

  static Widget _icon(String name, double size, Color? color) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }
}
