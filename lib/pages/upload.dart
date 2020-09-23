import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_chat/model/user.dart';
import 'package:social_chat/pages/home.dart';
import 'package:social_chat/widgets/header.dart';
import 'package:social_chat/widgets/progress.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as Im;
import 'package:firebase_storage/firebase_storage.dart';

var uuid = Uuid();

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  User user;

  // File file; // for camera and gallery
  File _image; // for camera and gallery
  final picker = ImagePicker();
  TextEditingController textPost = TextEditingController();
  TextEditingController textGeolocator = TextEditingController();
  bool isUploading = false;
  String postId = uuid.v4();

  handleCamera() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, maxHeight: 675, maxWidth: 960);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  handleGallery() async {
    Navigator.pop(context);
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, maxHeight: 675, maxWidth: 960);
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(_image.readAsBytesSync());
    final compressImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 90));
    setState(() {
      _image = compressImageFile;
    });
  }

  uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageReference.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
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

  createImage({String mediaUrl, String location, String description}) {
    postsRef
        .doc(widget.currentUser.id)
        .collection("usersPosts")
        .doc(postId)
        .set({
      "postId": postId,
      "ownerId": widget.currentUser.id,
      "username": widget.currentUser.username,
      "medialUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": [],
    });
  }

  getUserLocation() async {
    Position position = await Geolocator()
        .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks = await Geolocator()
        .placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    print("placemark is $placemark");
    String fullAddress = "${placemark.locality}" + "," + "${placemark.country}";
    print("fullAddress is $fullAddress");
    textGeolocator.text = fullAddress;
  }

  buildSplachScreen() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/images/upload.svg",
            height: 260,
          ),
          SizedBox(
            height: 15,
          ),
          RaisedButton(
            onPressed: () => chooseImage(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
            color: Colors.yellow[800],
            child: Text(
              "Upload Image",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ],
      ),
    );
  }
  handleSubmit() async {
    setState(() {
      isUploading = true ;
      return linearProgress();
    });
    await compressImage();
    String mediaUrl = await uploadImage(_image);
    createImage(mediaUrl:mediaUrl , location: textGeolocator.text,description: textPost.text);
    textGeolocator.clear();
    textPost.clear();
    setState(() {
      isUploading = false;
      postId = uuid.v4();
    });
  }
  buildForm() {
    return Scaffold(
      appBar: AppBar(
        actions: [
          FlatButton(
            onPressed: () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
        title: Text(
          "UploadPost",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () => Navigator.pop(context)),
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress() : Text(""),
          Container(
            padding: EdgeInsets.only(left: 15, right: 15),
            height: MediaQuery.of(context).size.height * .3,
            width: MediaQuery.of(context).size.width * .7,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(_image),
                  )),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: TextField(
              controller: textPost,
              decoration: InputDecoration(
                  hintText: "Write here post", border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.deepOrangeAccent,
              size: 35,
            ),
            title: TextField(
              controller: textGeolocator,
              decoration: InputDecoration(
                  hintText: "Where was this token", border: InputBorder.none),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * .55,
            padding: EdgeInsets.all(50),
            child: RaisedButton.icon(
                onPressed: () => getUserLocation(),
                color: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  "Use current location",
                  style: TextStyle(color: Colors.white),
                )),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _image == null ? buildSplachScreen() : buildForm();
  }
}
