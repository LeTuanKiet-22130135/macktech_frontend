import 'dart:io';

void main() {
  final directory = Directory('c:/flutter/app_frontend/lib');
  final patternRs = RegExp(r'Rs\.');
  final patternDollarEscaped = RegExp(r'\\\$');
  final patternDecimals = RegExp(r'\.toStringAsFixed\(2\)');

  int filesChanged = 0;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      bool changed = false;
      String content = entity.readAsStringSync();

      if (content.contains(patternRs)) {
        content = content.replaceAll(patternRs, '₫');
        changed = true;
      }
      
      // We only care about \$ used for prices, not interpolation. 
      // e.g. "\$50.00 OFF" -> "₫50.00 OFF"
      // e.g. "\$42,800" -> "₫42,800"
      // e.g. '\$${rod.toY.round()}k' -> '₫${rod.toY.round()}k'
      if (content.contains(patternDollarEscaped)) {
        // We ensure we only change \$ if it looks like it denotes money.
        // Wait, \$ is literal $ symbol. In our code all string literals of $ are actually money right now! (e.g. "\$50.00 OFF")
        content = content.replaceAll(patternDollarEscaped, '₫');
        changed = true;
      }
      
      if (content.contains(patternDecimals)) {
        content = content.replaceAll(patternDecimals, '.toStringAsFixed(0)');
        changed = true;
      }

      if (changed) {
        entity.writeAsStringSync(content);
        filesChanged++;
        print('Updated ${entity.path}');
      }
    }
  }
  
  print('Total files updated: $filesChanged');
}
