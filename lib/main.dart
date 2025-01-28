import 'package:arabic_dictionay/dict/parse.dart';
import 'package:arabic_dictionay/pages/bookmarked.dart';
import 'package:arabic_dictionay/store.dart';
import 'package:flutter/material.dart';

const paddingLTR = 8.0;
const paddingB = 18.0;
const fontFam = 'Kitab';

List<Entry>? _currentWord;
final currentTheme = ValueNotifier<ThemeMode>(ThemeMode.system);
// when it's value is == 1 then switch to system theme
int currentThemeSwitchCount = 0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: currentTheme,
        builder: (BuildContext context, ThemeMode th, Widget? child) {
          return MaterialApp(
            title: 'Arabic Dictionary',
            // TODO: Learn more about theme maybe and improve it :?
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
              textTheme: Theme.of(context).textTheme.apply(
                    fontFamily: fontFam,
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
                    fontFamily: fontFam,
                    fontSizeFactor: 1.1,
                    fontSizeDelta: 2.0,
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  ),
            ),
            themeMode: th,
            home: const MyHomePage(
              title: 'Arabic Dictionary',
            ),
          );
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
  final bkmrk = Bookmark();

  // @override
  // void initState() {
  //   super.initState();
  // }

  @override
  void dispose() {
    inputControler.dispose();
    super.dispose();
  }

  void _findWords() async {
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
          DataColumn(label: Text('Bookmark')),
          // DataColumn(label: Text('Family')),
        ],
        rows: _currentWord!.map((e) {
          final indexOf = bkmrk.idx(e);
          return DataRow(
            cells: [
              DataCell(Text(e.word)),
              DataCell(Text(e.def)),
              DataCell(Text(e.root)),
              DataCell(
                IconButton(
                  icon: Icon(
                    indexOf > -1 ? Icons.favorite : Icons.favorite_border,
                  ),
                  color: Colors.red,
                  onPressed: () {
                    setState(() {
                      if (indexOf > -1) {
                        bkmrk.rmAt(indexOf);
                      } else {
                        bkmrk.add(e);
                      }
                    });
                  },
                ),
              ),
              // DataCell(Text(e.fam)),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      prefixIcon: IconButton(
                        onPressed: () => setState(() {
                          inputControler.clear();
                        }),
                        icon: Icon(Icons.clear),
                      ),
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
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // Removes the border radius
        ),
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
              leading: Icon(Icons.subject_rounded),
              title: Text('Choose theme'),
              onTap: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Theme'),
                  content: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          child: Text('System'),
                          onPressed: () => setState(() {
                            currentTheme.value = ThemeMode.system;
                            Navigator.pop(context);
                          }),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          child: Text('Light'),
                          onPressed: () => setState(() {
                            currentTheme.value = ThemeMode.light;
                            Navigator.pop(context);
                          }),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          child: Text('Dark'),
                          onPressed: () => setState(() {
                            currentTheme.value = ThemeMode.dark;
                            Navigator.pop(context);
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.bookmark),
              title: Text('Bookmarked words'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookMarkedList(b: bkmrk),
                  ),
                ).then((_) => setState(() {})); // rerendering the main page
              },
            ),
          ],
        ),
      ),
    );
  }
}
