import 'package:arabic_dictionay/dict/parse.dart';
import 'package:flutter/material.dart';

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

  void _findWords() async {
    if (inputControler.text.trim().isEmpty) return;
    // dict.findWordAsync(inputControler.text.trim()).then((w) {
    //   setState(() {
    //     _currentWord = w;
    //   });
    // });
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
    return Padding(
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
    );
  }
}
