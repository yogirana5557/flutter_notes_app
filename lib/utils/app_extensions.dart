
import 'dart:ui';

extension ColorExtension on String {
  Color colorFromText() {
    var hash = 0;
    for (var i = 0; i < this.length; i++) {
      hash = this.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final finalHash = hash.abs() % (256 * 256 * 256);
    // print(finalHash);
    final red = ((finalHash & 0xFF0000) >> 16);
    final blue = ((finalHash & 0xFF00) >> 8);
    final green = ((finalHash & 0xFF));
    var p = 0.5;
    final color = Color.fromARGB(
      255,
      red + ((255 - red) * p).round(),
      green + ((255 - green) * p).round(),
      blue + ((255 - blue) * p).round(),
    );

    return color;
  }
}