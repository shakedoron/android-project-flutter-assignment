import 'package:english_words/english_words.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'userRep.dart';

class Suggestions with ChangeNotifier {
  String _uid;
  Set<WordPair> _saved = Set<WordPair>();
  UserRep _user;

  CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  CollectionReference get suggestionsCollection => _usersCollection;

  Set<WordPair> get saved => _saved;

  void update(UserRep user) async {
    _user = user;
    _uid = user.uid;
    if (user.status == Status.Authenticated) {
      var _doc = await _usersCollection.doc(_uid).get();
      if (!_doc.exists)
        await _usersCollection.doc(_uid).set({'suggestions': []});
      _savedSuggestions();
    }
  }

  Future _addUserData(WordPair suggestion) async {
    return await _usersCollection.doc(_uid).update({
      'suggestions': FieldValue.arrayUnion([
        {
          'first': suggestion.first.toString(),
          'second': suggestion.second.toString()
        }
      ])
    });
  }

  addPair(WordPair pair) {
    _saved.add(pair);
    if (_user.status == Status.Authenticated) _addUserData(pair);
  }

  Future _removeUserData(WordPair suggestion) async {
    await _usersCollection.doc(_uid).update({
      'suggestions': FieldValue.arrayRemove([
        {
          'first': suggestion.first.toString(),
          'second': suggestion.second.toString()
        }
      ])
    });
  }

  removePair(WordPair pair) {
    _saved.remove(pair);
    if (_user.status == Status.Authenticated) _removeUserData(pair);
    notifyListeners();
  }

  Future<Set<WordPair>> _getSuggestions() {
    return _usersCollection
        .doc(_uid)
        .get()
        .then((doc) => doc.data())
        .then((data) => data == null
            ? Set<WordPair>()
            : Set<WordPair>.from(data['suggestions']
                .map((arg) => WordPair(arg['first'], arg['second']))));
  }

  _savedSuggestions() async {
    if (_uid != null) {
      await _usersCollection.doc(_uid).update({
        'suggestions': FieldValue.arrayUnion(List<dynamic>.from(
            _saved.map((pair) => {'first': pair.first, 'second': pair.second})))
      });
    }
    _saved = await _getSuggestions();
    notifyListeners();
  }

  removeSuggestions() {
    _saved.clear();
    notifyListeners();
  }
}
