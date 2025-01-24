import 'package:arabic_dictionay/dict/parse.dart';
import 'package:flutter/material.dart';

final darkNotifier = ValueNotifier<bool>(true);
var firstRun = true;
var firstRunThemeTgl = true;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: darkNotifier,
        builder: (BuildContext context, bool isDark, Widget? child) {
          var app = MaterialApp(
            title: 'Arabic Dictionary',
            // TODO: Learn more about theme maybe and improve it :?
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Amiri',
                    fontSizeFactor: 1.1,
                    fontSizeDelta: 2.0,
                    bodyColor: null,
                    displayColor: null,
                  ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.white,
              useMaterial3: true,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: 'Amiri',
                    fontSizeFactor: 1.1,
                    fontSizeDelta: 2.0,
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            ),
            themeMode: firstRun
                ? ThemeMode.system
                : darkNotifier.value
                    ? ThemeMode.dark
                    : ThemeMode.light,
            home: const MyHomePage(
              title: 'Arabic Dictionary',
            ),
          );
          firstRun = false;
          return app;
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inputControler = TextEditingController();
  final dict = Dictionary();

  List<Entry>? _currentWord;

  @override
  void dispose() {
    inputControler.dispose();
    super.dispose();
  }

  void _findWords() {
    if (inputControler.text.trim().isEmpty) return;
    dict.findWordAsync(inputControler.text.trim()).then((w) {
      setState(() {
        _currentWord = w;
      });
    });
  }

  Widget _makeWordTable() {
    if (_currentWord == null) {
      return Text(
        'Search for something',
        textAlign: TextAlign.center,
      );
    } else if (_currentWord!.isEmpty) {
      return Text(
        'No result for: ${inputControler.text}',
        textAlign: TextAlign.center,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24.0,
        columns: const [
          DataColumn(label: Text('Word')),
          DataColumn(label: Text('Definition')),
          DataColumn(label: Text('Root')),
          // DataColumn(label: Text('Family')),
        ],
        rows: _currentWord!
            .map(
              (e) => DataRow(
                cells: [
                  DataCell(Text(e.word)),
                  DataCell(Text(e.def)),
                  DataCell(Text(e.root)),
                  // DataCell(Text(e.fam)),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  final paddingLTR = 8.0;
  final paddingB = 18.0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        // padding: const EdgeInsets.all(8.0),
        padding:
            EdgeInsets.fromLTRB(paddingLTR, paddingLTR, paddingLTR, paddingB),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: _makeWordTable(),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    autocorrect: false,
                    onSubmitted: (_) => _findWords(),
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    controller: inputControler,
                    decoration: InputDecoration(
                      hintText: 'اكتب هنا',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      alignLabelWithHint: true,
                      hintTextDirection: TextDirection.rtl,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _findWords,
                  icon: Icon(Icons.search),
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(width: 110),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Main menu',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Text('Theme:'),
                  SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    icon: Icon(
                      isDarkMode ? Icons.wb_sunny : Icons.bubble_chart,
                    ),
                    iconSize: 30,
                    onPressed: () {
                      if (firstRunThemeTgl) {
                        final nv = !isDarkMode;
                        if (nv == darkNotifier.value) {
                          // if the value was the same then change twise :D
                          darkNotifier.value = !nv;
                        }
                        darkNotifier.value = nv;
                        firstRunThemeTgl = false;
                      } else {
                        darkNotifier.value = !darkNotifier.value;
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
