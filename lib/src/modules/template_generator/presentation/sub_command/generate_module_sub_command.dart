import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:slidy/slidy.dart';
import 'package:slidy/src/core/services/yaml_service.dart';

import '../../../../core/command/command_base.dart';
import '../../domain/models/template_info.dart';
import '../../domain/usecases/create.dart';
import '../templates/module.dart';
import '../templates/widgets.dart';
import '../utils/template_file.dart';
import '../utils/utils.dart' as utils;

class GenerateModuleSubCommand extends CommandBase {
  @override
  final name = 'module';

  @override
  final description = 'Creates a module';

  GenerateModuleSubCommand() {
    argParser.addFlag('notest',
        abbr: 'n', negatable: false, help: 'Don`t create file test');
    argParser.addFlag('folder',
        abbr: 'f',
        negatable: false,
        help: 'Specific if use folder struct (module, store, page)',
        defaultsTo: false);
    // argParser.addOption('routing',
    //     abbr: 'r', help: 'Define routing path in parent module');
    argParser.addFlag('complete',
        abbr: 'c',
        negatable: true,
        help:
            'Creates a module with Page and Controller/Store files (Triple, MobX, BLoC, Cubit...)');
  }

  FutureOr runPage() async {
    var templateFile = await TemplateFile.getInstance(
        argResults?.rest.single ?? '', 'page',
        structFolder: argResults!['folder'] == true);
    templateFile = await TemplateFile.getInstance(
        '${argResults!.rest.first}/${templateFile.fileName}', 'page',
        structFolder: argResults!['folder'] == true);

    var templateFileModule = await TemplateFile.getInstance(
        argResults?.rest.single ?? '', 'module',
        structFolder: argResults!['folder'] == true);
    templateFileModule = await TemplateFile.getInstance(
        '${argResults!.rest.first}/${templateFile.fileName}', 'module',
        structFolder: argResults!['folder'] == true);
    // var result = await Modular.get<Create>().call(TemplateInfo(
    //     yaml: widgetsFile, destiny: templateFile.file, key: 'page'));
    // execute(result);

    // if (argResults!['routing'] != null) {
    //   await utils.injectParentModuleRouting(
    //       argResults!['routing'],
    //       '${templateFile.fileNameWithUppeCase}Page()',
    //       templateFile.import,
    //       templateFile.file.parent);
    // }

    if (!argResults!['notest']) {
      var result = await Modular.get<Create>().call(TemplateInfo(
          yaml: widgetsFile,
          destiny: templateFile.fileTest,
          key: 'page_test',
          args: [
            templateFile.fileNameWithUppeCase,
            templateFile.import,
            templateFileModule.import
          ]));
      execute(result);
    }
  }

  @override
  FutureOr run() async {
    if (argResults?.rest.isNotEmpty == false) {
      throw UsageException('value not passed for a module command', usage);
    }

    var templateFile = await TemplateFile.getInstance(
        argResults?.rest.single ?? '', 'module',
        structFolder: argResults!['folder'] == true);
    templateFile = await TemplateFile.getInstance(
        '${argResults!.rest.first}/${templateFile.fileName}', 'module',
        structFolder: argResults!['folder'] == true);

    var result = await Modular.get<Create>().call(TemplateInfo(
        key: 'module', destiny: templateFile.file, yaml: generateFile));
    execute(result);

    if (argResults!['complete'] != true) return;

    var command = CommandRunner('slidy', 'CLI')..addCommand(GenerateCommand());
    final yamlService = Modular.get<YamlService>();
    final node = yamlService.getValue(['dependencies']);
    final smList = [
      'flutter_triple',
      'triple',
      'flutter_bloc',
      'bloc',
      'flutter_mobx',
      'bloc',
      'rx_notifier'
    ];
    final selected = node?.value.keys
        .firstWhere((element) => smList.contains(element)) as String;

    await command.run([
      'generate',
      selected.replaceFirst('flutter_', ''),
      '${argResults!.rest.first}/${templateFile.fileName}',
      '--page',
      if (argResults!['folder'] == true) '--folder'
    ]);
    templateFile = await TemplateFile.getInstance(
        '${argResults!.rest.first}/${templateFile.fileName}', 'page',
        structFolder: argResults!['folder'] == true);

    await utils.injectParentModuleRouting(
        '/',
        '${templateFile.fileNameWithUppeCase}Page()',
        templateFile.import,
        templateFile.file.parent);
    await runPage();
  }

  @override
  String? get invocationSuffix => null;
}

class GenerateModuleAbbrSubCommand extends GenerateModuleSubCommand {
  @override
  final name = 'm';
}
