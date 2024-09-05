import 'package:slidy/src/core/models/custom_file.dart';

final _widgetsTemplate = r''' 
page: |
  import 'package:flutter/material.dart';
  import 'package:flutter/foundation.dart';
  
  class $fileName|pascalcase extends StatefulWidget {
    final String title;
    const $fileName|pascalcase({super.key, this.title = '$fileName|pascalcase'});
    @override
    $fileName|pascalcaseState createState() => $fileName|pascalcaseState();
  }
  class $fileName|pascalcaseState extends State<$fileName|pascalcase> {
    @override
    void initState() {
      super.initState();
      if (kDebugMode) {
        print("INIT PAGE: $fileName|pascalcase");
      }
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Column(
          children: <Widget>[
            Text(_store.value.toString())
          ],
        ),
      );
    }
    @override
    void dispose() {
      if (kDebugMode) {
        print("INIT PAGE: $fileName|pascalcase");
      }
      super.dispose();
    }
  }
page_test: |
  $arg2
  $arg3
  import 'package:flutter_test/flutter_test.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_modular/flutter_modular.dart';
    
  main() {
    group('$arg1', () {
      testWidgets('has a title and message', (WidgetTester tester) async {        
        await tester.pumpWidget(ModularApp(module: $arg1Module(), child: const MaterialApp(home: $arg1Page(title: 'T'))),);
        final titleFinder = find.text('T');
        expect(titleFinder, findsOneWidget);
      });
    });
  }
widget: |
  import 'package:flutter/material.dart';
  
  class $fileName|pascalcase extends StatelessWidget {
    final String title;
    const $fileName|pascalcase({Key? key, this.title = "$fileName|pascalcase"}) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      return Container(child: Text(title));
    }
  }
''';

final widgetsFile = CustomFile(yaml: _widgetsTemplate);
