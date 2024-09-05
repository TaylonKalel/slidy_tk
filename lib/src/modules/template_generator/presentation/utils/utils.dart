import 'dart:io';

import 'package:ansicolor/ansicolor.dart';
import 'package:args/command_runner.dart';
import 'package:slidy/slidy.dart';
import 'package:slidy/src/core/prints/prints.dart';
import 'package:slidy/src/modules/template_generator/domain/models/line_params.dart';
import 'package:slidy/src/modules/template_generator/domain/usecases/add_line.dart';

import 'template_file.dart';

Future injectParentModule(String injectionType, String fileNameWithUppeCase,
    String import, Directory directory) async {
  final injection = _injectionTemplate(injectionType, fileNameWithUppeCase);

  var newDirectory = directory;
  if (directory.path.contains('stores')) {
    newDirectory = Directory(directory.path.replaceAll('stores', 'modules'));
  }
  final parentModule = await getParentModule(newDirectory);

  var result = await Modular.get<AddLine>()
      .call(LineParams(parentModule, replaceLine: (line) {
    if (line.contains('void binds(i) { ')) {
      return line.replaceFirst('void binds(i) { i.addLazySingleton(.new); }',
          'void binds(i) {\n\t\t $injection \n\t}');
    } else if (line.contains('void binds(i) {')) {
      return line.replaceFirst(
          'void binds(i) {\n', 'void binds(i) {$injection,');
    }
    return line;
  }));

  execute(result);

  if (result.isRight()) {
    result = await Modular.get<AddLine>()
        .call(LineParams(parentModule, inserts: [import]));
    execute(result);
    if (result.isRight()) {
      await formatFile(parentModule);
    }
  }
}

Future injectParentModuleRouting(String path, String fileNameWithUppeCase,
    String import, Directory directory) async {
  final injection =
      'r.child(\'$path\', child: (_) => const $fileNameWithUppeCase);\n ';
  var newDirectory = directory;
  if (directory.path.contains('pages')) {
    newDirectory = Directory(directory.path.replaceAll('pages', 'modules'));
  }
  final parentModule = await getParentModule(newDirectory);

  var result = await Modular.get<AddLine>()
      .call(LineParams(parentModule, replaceLine: (line) {
    var cyan = AnsiPen()..magenta(bold: true);
    if (line.contains('void routes(r) {')) {
      return line.replaceFirst(
          'void routes(r) { r.child("", child: (_) => const ());',
          'void routes(r) {\n\t\t$injection');
    } else if (line.contains('void routes(r) {')) {
      return line.replaceFirst(
          'void routes(r) {\n', 'void routes(r) {$injection,');
    }
    return line;
  }));

  execute(result);

  if (result.isRight()) {
    result = await Modular.get<AddLine>()
        .call(LineParams(parentModule, inserts: [import]));
    execute(result);
    if (result.isRight()) {
      await formatFile(parentModule);
    }
  }
}

Future<void> addedInjectionInPage(
    {required TemplateFile templateFile,
    required String pathCommand,
    required bool noTest,
    required String type,
    bool folder = false}) async {
  var command = CommandRunner('slidy', 'CLI')..addCommand(GenerateCommand());
  await command.run([
    'generate',
    'page',
    pathCommand,
    if (noTest) '--notest',
    if (folder == true) '--folder'
  ]);
  var cyan = AnsiPen()..magenta(bold: true);
  // print(cyan('fileNameWithUppeCase: ${templateFile.fileNameWithUppeCase}'));
  // print(
  //     cyan('templateFile.file.parent.path: ${templateFile.file.parent.path}'));
  // print(cyan('templateFile.fileName: ${templateFile.fileName}'));
  final insertLine =
      ' late final ${templateFile.fileNameWithUppeCase}$type _${type.toLowerCase()};';
  final insertLine2 = '\t\t_${type.toLowerCase()} = Modular.get();';
  final pageFile = File(
      templateFile.file.parent.path.replaceFirst('stores', 'pages') +
          '/${templateFile.fileName}_page.dart');
  var result = await Modular.get<AddLine>()
      .call(LineParams(pageFile, position: 10, inserts: [insertLine, '']));
  execute(result);
  result = await Modular.get<AddLine>()
      .call(LineParams(pageFile, position: 15, inserts: [insertLine2]));
  execute(result);
  result = await Modular.get<AddLine>().call(LineParams(pageFile, inserts: [
    'import \'package:flutter_modular/flutter_modular.dart\';',
    templateFile.import
  ]));
  execute(result);
}

Future<void> formatFile(File file) async {
  await Process.run('flutter', ['format', file.absolute.path],
      runInShell: true);
}

String _injectionTemplate(String injectionType, String classInstance) {
  if (injectionType == 'lazy-singleton') {
    return 'i.addLazySingleton($classInstance);';
  } else if (injectionType == 'singleton') {
    return 'i.addSingleton($classInstance);';
  } else {
    return 'i.add($classInstance);';
  }
}

Future<File> getParentModule(Directory dir) async {
  await for (var file in dir.list()) {
    if (file.path.contains('_module.dart')) {
      return file as File;
    }
  }

  return await getParentModule(dir.parent);
}
