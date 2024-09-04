import 'package:slidy/src/core/models/custom_file.dart';

final _generateTemplate = r'''
module: |
  import 'package:flutter_modular/flutter_modular.dart';
  
  class $fileName|pascalcase extends Module {    
    @override
    void binds(i) { i.addLazySingleton(.new); }
      
    @override
    void routes(r) { r.child("", child: (_) => const ()); }
  }
module_test: |
  import 'package:flutter_modular/flutter_modular.dart';
  import 'package:modular_test/modular_test.dart';
  import 'package:flutter_test/flutter_test.dart';
  $arg2
   
  void main() {
  
    setUpAll(() {
      ///initModule($arg1());
    });
  }
''';

final generateFile = CustomFile(yaml: _generateTemplate);
