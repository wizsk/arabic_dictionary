import 'dart:convert';
import 'dart:io';

import 'package:arabic_dictionay/dict/parse.dart';
import 'package:path_provider/path_provider.dart';

class Bookmark {
  final List<Entry> bookmarks = [];
  Bookmark() {
    _loadBookmarksFromFile().then((v) => bookmarks.addAll(v));
  }

  int idx(Entry e) => bookmarks.indexOf(e);

  Future<void> add(Entry e) async {
    bookmarks.add(e);
    await _saveBookmarksToFile(bookmarks);
  }

  Future<void> rm(Entry e) async {
    bookmarks.remove(e);
    await _saveBookmarksToFile(bookmarks);
  }

  Future<void> rmAt(int e) async {
    bookmarks.removeAt(e);
    await _saveBookmarksToFile(bookmarks);
  }

  Future<File> get _localBookmarkFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/bookmarks.json');
  }

  Future<void> _saveBookmarksToFile(List<Entry> entries) async {
    final b = await _localBookmarkFile;
    await b.writeAsString(
      jsonEncode(entries.map((e) => e.toJson()).toList()),
      flush: true,
    );
  }

  Future<List<Entry>> _loadBookmarksFromFile() async {
    final b = await _localBookmarkFile;
    if (!await b.exists()) {
      // print('bookmarks does not exist!: ${b.path}');
      return [];
    }

    final data = await b.readAsString();
    // print('bookmarks loaded!: ${b.path}');

    if (data.isEmpty) return [];

    return (jsonDecode(data) as List)
        .map((json) => Entry.fromJson(json))
        .toList();
  }
}

// List<Entry>? _bookMarks;
