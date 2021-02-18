import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:thrive_pilot/utils/app_colors.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

final TextEditingController phnctlr = new TextEditingController();
final TextEditingController emailctlr = new TextEditingController();

class _EditProfileState extends State<EditProfile> {
  var username;
  bool edit = false;
  String joindate;
  String mail;
  var photourl;
  // var transaction = [];
  var uploadedFileURL;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool isLoading = true;
  File _image;

  @override
  void initState() {
    super.initState();
    currentuser();
  }

  Future getImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future uploadFile(BuildContext context) async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    var user = _firebaseAuth.currentUser;
    Reference storageReference =
        FirebaseStorage.instance.ref().child('users/${user.uid}/myimage.jpg');
    UploadTask uploadTask = storageReference.putFile(_image);
    if (uploadTask.snapshot.state == TaskState.running) {
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(' Uploading....'),
      ));
    }
    uploadTask.then((snapshot) {
      if (uploadTask.snapshot.state == TaskState.success) {
        print("here");
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          duration: Duration(seconds: 2),
          content: Text(' Uploaded successfully'),
        ));
        storageReference.getDownloadURL().then((fileURL) async {
          print("here");
          uploadedFileURL = fileURL;
          try {
            await FirebaseFirestore.instance
                .collection("fl_content")
                .doc(user.uid)
                .set({
              "email": emailctlr.text,
              "phone": phnctlr.text,
              "photoUrl": uploadedFileURL,
            }, SetOptions(merge: true));
          } catch (err) {
            print("Error: $err");
          }
          currentuser();
          _image = null;
        });
      }
    });
  }

  updatedata() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    var user = _firebaseAuth.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection("fl_content")
          .doc(user.uid)
          .set({
        "email": emailctlr.text,
        "phone": phnctlr.text,
      }, SetOptions(merge: true));
      _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text("Profile updated."),
        duration: Duration(seconds: 5),
      ));
      currentuser();
    } catch (err) {
      print("Error: $err");
    }
  }

  currentuser() async {
    FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    var user = _firebaseAuth.currentUser;
    FirebaseFirestore.instance
        .collection("fl_content")
        .doc("${user.uid}")
        .snapshots()
        .listen((onData) async {
      print(onData.data());
      if (this.mounted)
        setState(() {
          username = onData.data()["name"] == null
              ? ""
              : onData.data()["name"].toString();
          mail = onData.data()["email"] == null
              ? ""
              : onData.data()["email"].toString();
          emailctlr.text = mail;
          photourl = onData.data()["photoUrl"].toString().length <= 0
              ? null
              //"https://source.unsplash.com/random/300×300/?profile"
              : onData.data()["photoUrl"];
          phnctlr.text = onData.data()["phone"] == null
              ? ""
              : onData.data()["phone"].toString();
          joindate = onData.data()["joiningDate"] == null
              ? ""
              : DateFormat.yMMMEd()
                  .format(DateTime.parse(onData.data()["joiningDate"]))
                  .toString();
          // transaction =
          //     onData["transaction"] == null ? [] : onData["transaction"];
        });
    });

    return user;
  }

  Container buildProfile(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .31,
      //width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: <Widget>[
                Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.only(bottomRight: Radius.circular(20)),
                        image: DecorationImage(
                            image: _image != null
                                ? FileImage(_image)
                                : photourl != null
                                    ? NetworkImage(
                                        photourl.replaceAll("s96-c", "s400-c"))
                                    : AssetImage("assets/images/dummy.png"),
                            fit: BoxFit.cover))),
                edit
                    ? Container(
                        alignment: Alignment.bottomRight,
                        height: MediaQuery.of(context).size.height * .31,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.add_a_photo,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: Text("Select one"),
                                      children: <Widget>[
                                        SimpleDialogOption(
                                          child: Text(
                                            "Gallery",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          onPressed: () {
                                            getImage();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SimpleDialogOption(
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                          ),
                        ))
                    : SizedBox(),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2 - 20,
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.only(left: 10, bottom: 30),
            child: Text(
              "$username",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: AnimatedOpacity(
        opacity: 1.0,
        duration: Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: FloatingActionButton(
            elevation: 10,
            child: BackButton(
              color: Colors.black,
            ),
            backgroundColor: Colors.white38,
            onPressed: () {
              dispose();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      body: Center(
        child: Container(
          child: joindate == null && username == null
              ? CircularProgressIndicator(
                  valueColor:
                      new AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                )
              : SafeArea(
                  child: Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          buildProfile(context),
                          const SizedBox(height: 20),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Form(
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                      title: Text("User information"),
                                      trailing: !edit
                                          ? FlatButton.icon(
                                              splashColor: Colors.blue,
                                              icon: Icon(
                                                Icons.edit,
                                                color: AppColors.primaryColor,
                                              ),
                                              label: Text("edit"),
                                              onPressed: () {
                                                setState(() {
                                                  edit = true;
                                                });
                                              },
                                            )
                                          : SizedBox()),
                                  Divider(),
                                  edit
                                      ? ListTile(
                                          title: TextFormField(
                                            style: TextStyle(
                                                color: Colors.black54),
                                            readOnly: mail.length != 0
                                                // !edit || emailctlr.text.length != 0
                                                ? true
                                                : false,
                                            decoration: InputDecoration(
                                                hintText: "abc@gmail.com",
                                                helperText:
                                                    "Immutable if set once.",
                                                labelText: "Email",
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                            controller: emailctlr,
                                            onSaved: (value) {
                                              emailctlr.text = value;
                                            },
                                          ),
                                          leading: Icon(Icons.email),
                                        )
                                      : ListTile(
                                          leading: Icon(Icons.email),
                                          title: Text("Email"),
                                          subtitle: Text("${emailctlr.text}"),
                                        ),
                                  edit
                                      ? ListTile(
                                          title: TextFormField(
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                                color: Colors.black54),
                                            readOnly: !edit ? true : false,
                                            decoration: InputDecoration(
                                                labelText: "Phone",
                                                labelStyle: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20)),
                                            controller: phnctlr,
                                            onSaved: (value) {
                                              phnctlr.text = value;
                                            },
                                          ),
                                          leading: Icon(Icons.phone),
                                        )
                                      : ListTile(
                                          title: Text("Phone"),
                                          leading: Icon(Icons.phone),
                                          subtitle: Text("${phnctlr.text}"),
                                        ),
                                  ListTile(
                                    title: Text("Joined Date"),
                                    subtitle: Text("$joindate"),
                                    leading: Icon(Icons.calendar_view_day),
                                  ),
                                  edit
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Builder(builder:
                                                (BuildContext context) {
                                              return FlatButton.icon(
                                                splashColor: Colors.blue,
                                                icon: Icon(
                                                  Icons.done,
                                                  color: Colors.green,
                                                ),
                                                label: Text("Submit"),
                                                onPressed: () async {
                                                  _image == null
                                                      ? updatedata()
                                                      : await uploadFile(
                                                          context);

                                                  setState(() {
                                                    edit = false;
                                                  });
                                                },
                                              );
                                            }),
                                            FlatButton.icon(
                                              splashColor: Colors.blue,
                                              icon: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                              ),
                                              label: Text("Cancel"),
                                              onPressed: () {
                                                //for on cancel editing to show data as it is
                                                setState(() {
                                                  currentuser();
                                                  _image = null;

                                                  edit = false;
                                                });
                                              },
                                            ),
                                          ],
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                          Divider(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
