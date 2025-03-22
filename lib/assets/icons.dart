import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIcons {
  // Custom SVG icons as strings
  static const String _farmerIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 4C10.89 4 10 4.89 10 6C10 7.11 10.89 8 12 8C13.11 8 14 7.11 14 6C14 4.89 13.11 4 12 4Z" fill="currentColor"/>
  <path d="M12 14C9.33 14 4 15.34 4 18V20H20V18C20 15.34 14.67 14 12 14Z" fill="currentColor"/>
  <path d="M12 9C10.3 9 9 10.3 9 12C9 13.7 10.3 15 12 15C13.7 15 15 13.7 15 12C15 10.3 13.7 9 12 9Z" fill="currentColor"/>
  <path d="M4 4V8H8V4H4ZM7 7H5V5H7V7Z" fill="currentColor"/>
  <path d="M16 4V8H20V4H16ZM19 7H17V5H19V7Z" fill="currentColor"/>
  <path d="M7 16H5C4.45 16 4 16.45 4 17V19H8V17C8 16.45 7.55 16 7 16Z" fill="currentColor"/>
  <path d="M19 16H17C16.45 16 16 16.45 16 17V19H20V17C20 16.45 19.55 16 19 16Z" fill="currentColor"/>
</svg>
''';

  static const String _consumerIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 12C14.21 12 16 10.21 16 8C16 5.79 14.21 4 12 4C9.79 4 8 5.79 8 8C8 10.21 9.79 12 12 12ZM12 14C9.33 14 4 15.34 4 18V20H20V18C20 15.34 14.67 14 12 14Z" fill="currentColor"/>
  <path d="M19 8C19.55 8 20 7.55 20 7C20 6.45 19.55 6 19 6H17.14C17.37 6.6 17.5 7.28 17.5 8C17.5 8.72 17.37 9.4 17.14 10H19C19.55 10 20 9.55 20 9C20 8.45 19.55 8 19 8Z" fill="currentColor"/>
</svg>
''';

  static const String _organicIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M15.5 8C14.9 8 14.32 8.11 13.78 8.28C13.94 7.7 14 7.06 14 6.5C14 5.74 13.88 5 13.66 4.34C15.18 4.9 16.36 6.08 16.93 7.6C16.53 7.84 16.03 8 15.5 8Z" fill="currentColor"/>
  <path d="M12 10C9.79 10 8 11.79 8 14C8 16.21 9.79 18 12 18C14.21 18 16 16.21 16 14C16 11.79 14.21 10 12 10ZM12 16C10.9 16 10 15.1 10 14C10 12.9 10.9 12 12 12C13.1 12 14 12.9 14 14C14 15.1 13.1 16 12 16Z" fill="currentColor"/>
  <path d="M10.22 8.28C9.68 8.11 9.1 8 8.5 8C7.97 8 7.47 7.84 7.07 7.6C7.64 6.08 8.82 4.9 10.34 4.34C10.12 5 10 5.74 10 6.5C10 7.06 10.06 7.7 10.22 8.28Z" fill="currentColor"/>
  <path d="M15.5 6C14.67 6 14 5.33 14 4.5C14 3.67 14.67 3 15.5 3C16.33 3 17 3.67 17 4.5C17 5.33 16.33 6 15.5 6Z" fill="currentColor"/>
  <path d="M8.5 6C7.67 6 7 5.33 7 4.5C7 3.67 7.67 3 8.5 3C9.33 3 10 3.67 10 4.5C10 5.33 9.33 6 8.5 6Z" fill="currentColor"/>
  <path d="M8.5 10C7.67 10 7 9.33 7 8.5C7 7.67 7.67 7 8.5 7C9.33 7 10 7.67 10 8.5C10 9.33 9.33 10 8.5 10Z" fill="currentColor"/>
  <path d="M15.5 10C14.67 10 14 9.33 14 8.5C14 7.67 14.67 7 15.5 7C16.33 7 17 7.67 17 8.5C17 9.33 16.33 10 15.5 10Z" fill="currentColor"/>
  <path d="M12 21C13.1 21 14 20.1 14 19H10C10 20.1 10.9 21 12 21Z" fill="currentColor"/>
</svg>
''';

  static const String _cartIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M7 18C5.9 18 5.01 18.9 5.01 20C5.01 21.1 5.9 22 7 22C8.1 22 9 21.1 9 20C9 18.9 8.1 18 7 18ZM1 2V4H3L6.6 11.59L5.25 14.04C5.09 14.32 5 14.65 5 15C5 16.1 5.9 17 7 17H19V15H7.42C7.28 15 7.17 14.89 7.17 14.75L7.2 14.63L8.1 13H15.55C16.3 13 16.96 12.59 17.3 11.97L20.88 5.48C20.96 5.34 21 5.17 21 5C21 4.45 20.55 4 20 4H5.21L4.27 2H1ZM17 18C15.9 18 15.01 18.9 15.01 20C15.01 21.1 15.9 22 17 22C18.1 22 19 21.1 19 20C19 18.9 18.1 18 17 18Z" fill="currentColor"/>
</svg>
''';

  static const String _qrCodeIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M3 11H11V3H3V11ZM5 5H9V9H5V5Z" fill="currentColor"/>
  <path d="M3 21H11V13H3V21ZM5 15H9V19H5V15Z" fill="currentColor"/>
  <path d="M13 3V11H21V3H13ZM19 9H15V5H19V9Z" fill="currentColor"/>
  <path d="M21 19H19V21H21V19Z" fill="currentColor"/>
  <path d="M15 13H13V15H15V13Z" fill="currentColor"/>
  <path d="M17 15H15V17H17V15Z" fill="currentColor"/>
  <path d="M15 17H13V19H15V17Z" fill="currentColor"/>
  <path d="M17 19H15V21H17V19Z" fill="currentColor"/>
  <path d="M19 17H17V19H19V17Z" fill="currentColor"/>
  <path d="M19 13H17V15H19V13Z" fill="currentColor"/>
  <path d="M21 15H19V17H21V15Z" fill="currentColor"/>
</svg>
''';

  static const String _productsIconSvg = '''
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M17.21 9L12.83 4.63C12.64 4.43 12.36 4.43 12.17 4.63L7.79 9H17.21Z" fill="currentColor"/>
  <path d="M11 14V19.18C11 19.52 11.43 19.7 11.7 19.47L15.88 15.88C15.96 15.8 16 15.69 16 15.58V14H11Z" fill="currentColor"/>
  <path d="M8 13V15.58C8 15.69 8.04 15.8 8.12 15.88L12.3 19.47C12.57 19.7 13 19.52 13 19.18V13H8Z" fill="currentColor"/>
  <path d="M12 10.5L7.2 9.5L3.51 16.27C3.34 16.57 3.56 16.95 3.9 16.95H10L12 10.5Z" fill="currentColor"/>
  <path d="M12 10.5L16.8 9.5L20.49 16.27C20.66 16.57 20.44 16.95 20.1 16.95H14L12 10.5Z" fill="currentColor"/>
</svg>
''';

  // SVG to Widget conversion using flutter_svg
  static Widget svgIcon(String svgString, {double? size, Color? color}) {
    return SvgPicture.string(
      svgString,
      width: size,
      height: size,
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
    );
  }

  // App Icon getters
  static Widget farmerIcon({double? size, Color? color}) {
    return svgIcon(_farmerIconSvg, size: size, color: color);
  }

  static Widget consumerIcon({double? size, Color? color}) {
    return svgIcon(_consumerIconSvg, size: size, color: color);
  }

  static Widget organicIcon({double? size, Color? color}) {
    return svgIcon(_organicIconSvg, size: size, color: color);
  }

  static Widget cartIcon({double? size, Color? color}) {
    return svgIcon(_cartIconSvg, size: size, color: color);
  }

  static Widget qrCodeIcon({double? size, Color? color}) {
    return svgIcon(_qrCodeIconSvg, size: size, color: color);
  }

  static Widget productsIcon({double? size, Color? color}) {
    return svgIcon(_productsIconSvg, size: size, color: color);
  }
}
