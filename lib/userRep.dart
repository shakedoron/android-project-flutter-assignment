import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum Status { Unauthenticated, Authenticating, Authenticated }

class UserRep with ChangeNotifier {
  FirebaseAuth _auth;
  User _user;
  Status _status = Status.Unauthenticated;
  String _uid;
  String _email;
  String _imagePath;
  CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  UserRep.create() : _auth = FirebaseAuth.instance {
    _auth.authStateChanges().listen(_authStateChanges);
  }

  Status get status => _status;

  User get user => _user;

  String get uid => _uid;

  String get email => _email;

  String get imagePath => _imagePath;

  Future<void> _authStateChanges(User user) async {
    if (user == null) {
      _status = Status.Unauthenticated;
    } else {
      _user = user;
      _uid = user.uid;
      _email = _user.email;
      _imagePath = await _getProfileImagePath();
      _status = Status.Authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = Status.Authenticating;
      notifyListeners();
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _status = Status.Unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future signOut() async {
    _auth.signOut();
    _status = Status.Unauthenticated;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future registerUser(
      String email, String password, BuildContext context) async {
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    setProfileImagePath("https://st3.depositphotos.com/4111759/13425/v/380/depositphotos_134255626-stock-illustration-avatar-male-profile-gray-person.jpg");
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Future<String> _getProfileImagePath() {
    return _usersCollection
        .doc(_uid)
        .get()
        .then((doc) => doc.data())
        .then((data) => data == null ? "" : data['profileImagePath'] as String);
  }

  setProfileImagePath(String imagePath) async {
    await _usersCollection.doc(_uid).set({
      'profileImagePath':
          imagePath
    });
    _imagePath = imagePath;
    notifyListeners();
  }
}
