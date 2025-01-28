import 'package:arabic_dictionay/store.dart';
import 'package:flutter/material.dart';

class BookMarkedList extends StatefulWidget {
  const BookMarkedList({super.key, required this.b});
  final Bookmark b;

  @override
  State<BookMarkedList> createState() => _BookMarkedListState();
}

class _BookMarkedListState extends State<BookMarkedList> {
  @override
  Widget build(BuildContext context) {
    final b = widget.b;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarked Words'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: b.bookmarks.isEmpty
            ? Center(
                child: TextButton(
                  child: Text("No bookmarks. Go Back"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            : Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: SingleChildScrollView(
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
                      rows: b.bookmarks.indexed.map((en) {
                        final indexOf = en.$1;
                        final e = en.$2;
                        return DataRow(
                          cells: [
                            DataCell(Text(e.word)),
                            DataCell(Text(e.def)),
                            DataCell(Text(e.root)),
                            DataCell(
                              IconButton(
                                icon: Icon(
                                  Icons.favorite,
                                ),
                                color: Colors.red,
                                onPressed: () {
                                  setState(() {
                                    b.rmAt(indexOf);
                                  });
                                },
                              ),
                            ),
                            // DataCell(Text(e.fam)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
