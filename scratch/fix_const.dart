import 'dart:io';

void main() {
  final libDir = Directory('c:/flutter/app_frontend/lib');

  void processFile(File file) {
    String content = file.readAsStringSync();
    bool changed = false;

    if (content.contains('const AppColors')) {
      content = content.replaceAll('const AppColors', 'AppColors');
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Fixed const issue in \${file.path}');
    }
  }

  void traverseDir(Directory dir) {
    for (final entity in dir.listSync()) {
      if (entity is Directory) {
        traverseDir(entity);
      } else if (entity is File && entity.path.endsWith('.dart')) {
        processFile(entity);
      }
    }
  }

  traverseDir(libDir);
  print('Done fixing const issues.');
}
