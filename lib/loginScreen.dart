import 'package:flutter/material.dart';
import 'package:hello_me/signUpUser.dart';
import 'package:hello_me/userRep.dart';
import 'package:provider/provider.dart';
import 'userRep.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _email = TextEditingController();
  TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRep>(context);
    return new Column(children: [
      _buildLoginScreen(),
      _buildLoginButton(user),
      _buildRegisterButton()
    ]);
  }

  Widget _buildLoginScreen() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          child: Text(
            "Welcome to Statup Names Generator",
            style: TextStyle(fontSize: 20),
          ),
        ),
        Container(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "please log in below",
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _email,
              decoration: InputDecoration(
                labelText: "Email",
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            )),
        Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _password,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            )),
      ],
    );
  }

  Widget _buildLoginButton(UserRep user) {
    return user.status == Status.Authenticating
        ? Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
          )
        : Container(
            padding: EdgeInsets.only(left: 20, top: 20, right: 20, bottom: 2),
            width: 360,
            child: RaisedButton(
              color: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.red),
              ),
              child: Text(
                "Log in",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () async {
                if (!await user.signIn(_email.text, _password.text)) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                    "There was an error logging into the app",
                    style: TextStyle(fontSize: 18),
                  )));
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          );
  }

  Widget _buildRegisterButton() {
    return Container(
      padding: EdgeInsets.only(left: 20, top: 5, right: 20, bottom: 20),
      width: 360,
      child: RaisedButton(
        color: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.teal),
        ),
        child: Text(
          "New user? Click to sign up",
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showModalBottomSheet(),
      ),
    );
  }

  void _showModalBottomSheet() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return SignUpUser(_email.text, _password.text);
        });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }
}
