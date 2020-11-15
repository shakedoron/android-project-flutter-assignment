import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:hello_me/favoritesScreen.dart';
import 'package:hello_me/profilePage.dart';
import 'package:hello_me/userRep.dart';
import 'package:provider/provider.dart';

import 'loginScreen.dart';
import 'suggestions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(App());
}

class App extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRep>.value(value: UserRep.create()),
        ChangeNotifierProxyProvider<UserRep, Suggestions>(
            create: (_) => Suggestions(),
            update: (_, user, data) => data..update(user))
      ],
      child: MaterialApp(
        title: 'Startup Name Generator',
        theme: ThemeData(
          primaryColor: Colors.red,
        ),
        home: RandomWords(),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  bool _isblur = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Startup Name Generator'),
        actions: [
          IconButton(icon: Icon(Icons.favorite), onPressed: _pushSaved),
          Provider.of<UserRep>(context).status == Status.Authenticated
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    Provider.of<UserRep>(context, listen: false).signOut();
                    Provider.of<Suggestions>(context, listen: false)
                        .removeSuggestions();
                  })
              : IconButton(icon: Icon(Icons.login), onPressed: _pushLogin),
        ],
      ),
      body: Stack(children: [
        _buildSuggestions(),
        _isblur
            ? BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 5.0,
                  sigmaY: 5.0,
                ),
                child: Container(color: Colors.black.withOpacity(0)),
              )
            : Container(),
        ProfilePage(changeBlur),
      ]),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext _context, int i) {
        if (i.isOdd) {
          return Divider();
        }
        final int index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget _buildRow(WordPair pair) {
    final _saved = Provider.of<Suggestions>(context).saved;
    final alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved)
            Provider.of<Suggestions>(context, listen: false).removePair(pair);
          else
            Provider.of<Suggestions>(context, listen: false).addPair(pair);
        });
      }, //onTap
    );
  }

  void _pushLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Login',
              ),
            ),
            body: LoginScreen(),
          );
        },
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                'Saved Suggestions',
              ),
            ),
            body: FavoritesScreen(),
          );
        },
      ),
    );
  }

  changeBlur(){
    setState(() {
      _isblur = !_isblur;
    });
  }
}


