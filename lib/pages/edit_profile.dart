import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/pages/profile.dart';
import 'package:social_chat/widgets/progress.dart';
import 'package:image/image.dart' as Im;
import 'upload.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;

  EditProfile({this.currentUserId});

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  User user;
  bool isLoading = false;
  bool _validBio = true;
  bool _validDisplayname = true;
  String downloadUrl = '';
  bool _validImage = true;
  TextEditingController controllerDisplayName = TextEditingController();
  TextEditingController controllerBio = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  File _image; // for camera and gallery
  final picker = ImagePicker();
  String imageId = uuid.v4();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }

  handleCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.camera,
    );
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  handleGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  chooseImage(parentContext) {
    return showDialog(
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Text("Photo with camera"),
                onPressed: () => handleCamera(),
              ),
              SimpleDialogOption(
                child: Text("Photo from gallery"),
                onPressed: () => handleGallery(),
              ),
              SimpleDialogOption(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        },
        context: parentContext);
  }
  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressImageFile = File('$path/img_$imageId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 90));
    setState(() {
      _image = compressImageFile;
    });
  }

  Future sendPhoto(String photo) async{
    downloadUrl = await photo;
  }
  uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
    storageReference.child("imageProfile_$imageId.jpg").putFile(imageFile);
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    downloadUrl = await snapshot.ref.getDownloadURL();
    print(downloadUrl);
    userRef.doc(widget.currentUserId).update({
      "photoUrl" : downloadUrl,
    });
    return sendPhoto(downloadUrl);
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await userRef.doc(widget.currentUserId).get();
    user = User.fromDocument(doc);
    controllerDisplayName.text = user.displayName;
    controllerBio.text = user.bio;
    setState(() {
      isLoading = false;
    });
  }

  textFieldDisplayName() {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Display Name",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: controllerDisplayName,
            decoration: InputDecoration(
                hintText: "Display Name",
                errorText:
                    _validDisplayname ? null : "Display Name too short "),
          )
        ],
      ),
    );
  }

  textFieldBio() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              "Bio",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: controllerBio,
            decoration: InputDecoration(
                hintText: "Bio", errorText: _validBio ? null : "Bio too Long"),
          )
        ],
      ),
    );
  }

  updateProfileData() {
    setState(() {
      controllerDisplayName.text.trim().length < 3 ||
              controllerDisplayName.text.isEmpty
          ? _validDisplayname = false
          : _validDisplayname = true;
      controllerBio.text.trim().length > 100
          ? _validBio = false
          : _validBio = true;
      _image == null ? _validImage = false : _validImage = true;
      uploadImage(_image);
    });
    print("ssssxxxx $downloadUrl");
    if (_validDisplayname && _validBio) {
      userRef.doc(widget.currentUserId).update({
        "displayName": controllerDisplayName.text,
        "bio": controllerBio.text,
      //  "photoUrl" : downloadUrl
      });

      SnackBar snackBar = SnackBar(content: Text("Profile Update"));
      _scaffoldKey.currentState.showSnackBar(snackBar);

    }
  }

  _logOutAccount() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("EditProfile"),
        actions: [
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.green,
              ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => Profile(
                            profileId: user.id,
                          )))),
        ],
      ),
      body: isLoading
          ? circleProgress()
          : ListView(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      child: InkWell(
                        onTap: () => chooseImage(context),
                        child: CircleAvatar(
                          radius: 50.0,
                          backgroundImage: _image == null
                              ? CachedNetworkImageProvider(user.photoUrl)
                              : FileImage(_image),
                        ),
                      ),
                    ),
                    textFieldDisplayName(),
                    textFieldBio(),
                    Padding(padding: EdgeInsets.all(10)),
                    RaisedButton(
                      onPressed: () => updateProfileData(),
                      child: Text(
                        "Update Profile",
                        style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    FlatButton.icon(
                        onPressed: () => _logOutAccount(),
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                        label: Text(
                          "Logout",
                          style: TextStyle(color: Colors.red, fontSize: 25.0),
                        ))
                  ],
                )
              ],
            ),
    );
  }
}
