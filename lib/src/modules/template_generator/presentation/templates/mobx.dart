import 'package:slidy/src/core/models/custom_file.dart';

final _mobxTemplate = r''' 
mobx: |
  import 'package:mobx/mobx.dart';
  
  part '$fileName.g.dart';
  
  class $fileName|pascalcase = Abstract$fileName|pascalcase with _$$fileName|pascalcase;
  abstract class Abstract$fileName|pascalcase with Store {
  
    @observable
    int value = 0;
  
    @action
    void increment() {
      value++;
    } 
  }
mobx_test: |
  import 'package:flutter_test/flutter_test.dart';
  $arg2
   
  void main() {
    late $arg1 store;
  
    setUpAll(() {
      store = $arg1();
    });
  
    test('increment count', () async {
      expect(store.value, equals(0));
      store.increment();
      expect(store.value, equals(1));
    });
  }
''';

final mobxFile = CustomFile(yaml: _mobxTemplate);
