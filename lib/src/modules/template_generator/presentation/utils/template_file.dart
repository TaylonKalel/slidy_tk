import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:recase/recase.dart';
import 'package:slidy/slidy.dart';
import 'package:slidy/src/core/services/yaml_service.dart';
import 'package:yaml/yaml.dart';

class TemplateFile {
  late final File file;
  late final File fileTest;
  late final String fileName;
  late final String structFolder;
  late final fileNameWithUppeCase;
  final String packageName;
  late final import;

  TemplateFile._(String path, String type, this.packageName,
      {bool structFolder = false}) {
    var cyan = AnsiPen()..magenta(bold: true);

    if (structFolder == true) {
      // print(cyan('INIT PATH: $path'));
      var pathSplited = path.split('/');
      var newPath = '';
      for (var i = 0; i < pathSplited.length; i++) {
        if (i == (pathSplited.length - 1)) {
          newPath += '${type.replaceAll("_", "")}s/${pathSplited[i]}';
        } else {
          newPath += '${pathSplited[i]}/';
        }
        // print(cyan('NEWPATH[$i]: $newPath'));
      }
      path = newPath;
    }
    file = File('lib/app/$path$type.dart');
    fileTest = File('test/app/$path${type}_test.dart');
    fileName = ReCase(Uri.parse(path).pathSegments.last).camelCase;
    fileNameWithUppeCase = fileName[0].toUpperCase() + fileName.substring(1);
    import = 'import \'package:$packageName/app/$path$type.dart\';';
  }

  static Future<TemplateFile> getInstance(String path, String? type,
      {bool structFolder = false}) async {
    final pubspec = Modular.get<YamlService>();
    return TemplateFile._(
        path, type == null ? '' : '_$type', (pubspec.getValue(['name']))?.value,
        structFolder: structFolder);
  }

  Future<bool> checkDependencyIsExist(String dependency,
      [bool isDev = false]) async {
    try {
      final dependenciesLine = isDev ? 'dev_dependencies' : 'dependencies';
      final pubspec = Modular.get<YamlService>();
      final map = (pubspec.getValue([dependenciesLine]))?.value as YamlMap;
      return map.containsKey(dependency);
    } catch (e) {
      return false;
    }
  }
}
