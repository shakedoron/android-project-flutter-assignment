import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:hello_me/userRep.dart';
import 'package:provider/provider.dart';
import 'package:snapping_sheet/snapping_sheet.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback changeBlur;

  @override
  _ProfilePageState createState() => _ProfilePageState();

  ProfilePage(this.changeBlur);
}

class _ProfilePageState extends State<ProfilePage> {
  var _controller = SnappingSheetController();
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRep>(context);
    return user.status == Status.Authenticated
        ? SnappingSheet(
            sheetBelow: SnappingSheetContent(
                child: _sheetProfile(user),
                heightBehavior: SnappingSheetHeight.fit()),
            grabbing: InkWell(
                child: Container(
                  color: Colors.blueGrey[200],
                  child: ListTile(
                    title: Text(
                      "Welcome back, " + user?.email ?? "",
                      style: TextStyle(fontSize: 16),
                    ),
                    trailing: Icon(Icons.keyboard_arrow_up),
                  ),
                ),
                onTap: () {
                  if (_controller.snapPositions.last !=
                      _controller.currentSnapPosition) {
                    _controller.snapToPosition(_controller.snapPositions.last);
                    widget.changeBlur();
                  } else {
                    _controller.snapToPosition(_controller.snapPositions.first);
                    widget.changeBlur();
                  }
                }),
            grabbingHeight: 50,
            snappingSheetController: _controller,
            snapPositions: const [
              SnapPosition(
                  positionPixel: 0.0,
                  snappingCurve: Curves.elasticOut,
                  snappingDuration: Duration(milliseconds: 750)),
              SnapPosition(positionFactor: 0.20),
            ],
          )
        : Container();
  }

  Widget _sheetProfile(UserRep user) {
    return Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Column(children: [
              Flexible(
                child: _isUploading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(user.imagePath),
                        backgroundColor: Colors.grey[200],
                        radius: 35,
                      ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                //mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      user?.email ?? "",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Flexible(
                    child: FlatButton(
                        height: 30,
                        color: Colors.teal,
                        textColor: Colors.white,
                        onPressed: () => _uploadImage(user),
                        child: Text(
                          "Change avatar",
                          style: TextStyle(fontSize: 14),
                        )),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  _uploadImage(UserRep user) async {
    FirebaseStorage _storage = FirebaseStorage.instance;

    FilePickerResult _result = await FilePicker.platform.pickFiles();

    if (_result != null) {
      File file = File(_result.files.single.path);
      await _storage.ref('profile-pics/${user.uid}.png').putFile(file);
      setState(() {
        _isUploading = true;
      });
      String _newPath =
          await _storage.ref('profile-pics/${user.uid}.png').getDownloadURL();
      await user.setProfileImagePath(_newPath);
      setState(() {
        _isUploading = false;
      });
    } else {
      Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(
        "No image selected",
        style: TextStyle(fontSize: 18),
      )));
    }
  }
}
