import 'package:arabic_dictionay/dict/parse.dart';
import 'package:arabic_dictionay/pages/bookmarked.dart';
import 'package:arabic_dictionay/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

const paddingLTR = 8.0;
const paddingB = 18.0;
const fontFam = 'Kitab';

const searchWordTEXT = 'Search word';
const readerModeTEXT = 'Reader Mode';

final currentTheme = ValueNotifier<ThemeMode>(ThemeMode.system);

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
            title: 'Arabic to English Dictionay',
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

  String currentModeAppbarTittle = searchWordTEXT;

  bool _wordSearchMode = true;
  bool _diableInput = false;

  List<Entry>? _currentWord;
  List<WordAndEntries>? _wordEntries;

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
    final inpt = inputControler.text.trim();
    if (inpt.isEmpty) return;

    if (!_wordSearchMode) {
      dict.findWords(inpt).then((v) {
        setState(() {
          _diableInput = true;
          _wordEntries = v;
        });
      });
    } else {
      dict.findWordAsync(inpt).then((w) {
        setState(() {
          _currentWord = w;
        });
      });
    }
  }

  Widget _makeWordTable() {
    if (_currentWord == null && _wordEntries == null) {
      return Text(
        'Search for something',
        textAlign: TextAlign.center,
      );
    } else if (_wordSearchMode && _currentWord!.isEmpty) {
      return Text(
        'No result for: ${inputControler.text}',
        textAlign: TextAlign.center,
      );
    }

    if (!_wordSearchMode && _wordEntries != null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return RichText(
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        text: TextSpan(
          style: TextStyle(
            fontFamily: fontFam,
            color: isDark ? Colors.white : Colors.black,
            fontSize: 20,
          ),
          children: _wordEntries!.map((v) {
            return TextSpan(
              text: '${v.word} ',
              style: TextStyle(
                color:
                    !v.isPunctuation && v.entries.isEmpty ? Colors.red : null,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (v.entries.isEmpty) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Woooooords(
                        b: v.entries,
                        bkmr: bkmrk,
                      ),
                    ),
                  ).then((_) => setState(() {})); // rerendering the main page
                },
            );
          }).toList(),
        ),
      );
    }
    // if it's in wordsearh mode
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 24.0,
        columns: const [
          DataColumn(label: Text('Word')),
          DataColumn(label: Text('Definition')),
          DataColumn(label: Text('Root')),
          DataColumn(label: Text('Bookmark')),
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
        title: Text(currentModeAppbarTittle),
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
                    enabled: !_diableInput,
                    autocorrect: false,
                    onSubmitted: (_) => _findWords(),
                    maxLines: _wordSearchMode
                        ? 1
                        : _diableInput
                            ? 1
                            : 4,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    controller: inputControler,
                    decoration: InputDecoration(
                      prefixIcon: _diableInput
                          ? null
                          : IconButton(
                              onPressed: () => setState(() {
                                _diableInput = false;
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
                  onPressed: () {
                    if (_diableInput) {
                      setState(() {
                        _diableInput = false;
                      });
                      return;
                    }
                    _findWords();
                  },
                  icon: Icon(_diableInput ? Icons.edit : Icons.search),
                  iconSize: 30,
                ),
              ],
            ),
            SizedBox(
              width: 110,
            ),
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
              leading: Icon(Icons.eco),
              title: Text(
                  'Theme: ${currentTheme.value == ThemeMode.system ? 'System' : currentTheme.value == ThemeMode.dark ? 'Dark' : 'Light'}'),
              onTap: () {
                Navigator.pop(context);
                showDialog<String>(
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
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.text_fields_sharp),
              title: Text(
                  'Mode: ${_wordSearchMode ? searchWordTEXT : readerModeTEXT}'),
              onTap: () {
                setState(() {
                  currentModeAppbarTittle =
                      _wordSearchMode ? readerModeTEXT : searchWordTEXT;
                  inputControler.clear();
                  _wordSearchMode = !_wordSearchMode;
                  _diableInput = false;
                  _wordEntries = null;
                  _currentWord = null;
                });
                Navigator.pop(context);
              },
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
