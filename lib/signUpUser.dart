import 'package:flutter/material.dart';
import 'package:hello_me/userRep.dart';
import 'package:provider/provider.dart';
import 'userRep.dart';

class SignUpUser extends StatefulWidget {
  final String _email;
  final String _password;

  SignUpUser(this._email, this._password);

  @override
  _SignUpUserState createState() => _SignUpUserState();
}

class _SignUpUserState extends State<SignUpUser> {
  TextEditingController _validatePassword = TextEditingController();
  bool _matchingPasswords = true;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Wrap(children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Center(
                    child: Text(
                  "Please confirm your password below:",
                  style: TextStyle(fontSize: 16),
                )),
              ),
              Divider(endIndent: 20, indent: 20,),
              Container(
                  padding: EdgeInsets.only(bottom: 2, left: 16, right: 16),
                  child: TextField(
                    controller: _validatePassword,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      errorText:
                          _matchingPasswords ? null : "Passwords must match",
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                  )),
              Divider(endIndent: 20, indent: 20,),
              Container(
                padding: EdgeInsets.only(bottom: 20),
                child: FlatButton(
                    color: Colors.teal,
                    textColor: Colors.white,
                    onPressed: () async {
                      widget._password == _validatePassword.text
                          ? await Provider.of<UserRep>(context, listen: false)
                              .registerUser(
                                  widget._email, widget._password, context)
                          : _showError();
                    },
                    child: Text(
                      "Confirm",
                      style: TextStyle(fontSize: 14),
                    )),
              ),
            ],
          )
        ]));
  }

  _showError() {
    setState(() {
      _matchingPasswords = false;
    });
  }

  @override
  void dispose() {
    _validatePassword.dispose();
    super.dispose();
  }
}
