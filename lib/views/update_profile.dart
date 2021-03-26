import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:blogging_app/services/database_service.dart';
import 'package:blogging_app/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class EditProfilePage extends StatefulWidget {
  final String uid;
  final String userEmail;

  EditProfilePage({this.uid, this.userEmail});
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  QuerySnapshot userSnap;
  bool _isLoading = true;
  String _error = '';
  TextEditingController _fullNameEditingController = new TextEditingController();
  TextEditingController _location = new TextEditingController();
  File _image;
  final picker = ImagePicker();
  String newURL = '';
  String profileImage;

  @override
  void initState() {
    super.initState();
    _getUserDetails();
  }

  _updateDetails() async{
    if (_fullNameEditingController.text != '' || _location.text != '' || newURL != ''){
      await DatabaseService(uid: widget.uid).updateUserData(_fullNameEditingController.text,_location.text, newURL).then((res) {
        setState(() {
          if (res!= null) {
            _isLoading = true;
            Navigator.of(context).pop();
          }
          else {
            setState(() {
              _error = 'Error Updating';
              _isLoading = false;
            });
          }
        });
      } );
    }
  }

  _getUserDetails () async{
    await DatabaseService(uid: widget.uid).getUserData(widget.userEmail).then((res) {
      setState(() {
        userSnap = res;
        //newURL = userSnap.documents[0].data['profileImage'].toString();
        _fullNameEditingController.text = userSnap.documents[0].data['fullName'].toString();
        _location.text = userSnap.documents[0].data['location'].toString();
        profileImage = userSnap.documents[0].data['profileImage'].toString();
        _isLoading = false;
      });
    } );
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery,imageQuality: 50);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('----------------Image Selected-------------------');
      } else {
        print('----------------------No image selected.--------------------------------');
      }
    });
  }

  Future uploadPic() async{
    print('------------------upload function called===============');
    StorageReference storageReference = FirebaseStorage.instance.ref().child('profiles/${Path.basename(_image.toString())}');
    StorageUploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.onComplete;
    print('---------------File Uploaded-------------------------------');

    storageReference.getDownloadURL().then((fileURL) {
      setState(() {
        newURL = fileURL.toString();
        print(newURL);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading?Loading():Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.green,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Text(
                "Edit Profile",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 15,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(profileImage,)
                          ),
                      ),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color: Colors.green,
                          ),
                          child: GestureDetector(
                            onTap: (){
                              getImage().then((value) => uploadPic());
                              print('edit button-------------------------------------');
                            },
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _fullNameEditingController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: 'Full Name',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: userSnap.documents[0].data['fullName'].toString(),
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                    validator: (val) => val.isEmpty
                        ? 'This field cannot be blank'
                        : null
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 35.0),
                child: TextFormField(
                  controller: _location,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(bottom: 3),
                    labelText: 'Location',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    hintText: (userSnap.documents[0].data['location'] != null)?userSnap.documents[0].data['location'].toString():'',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                    validator: (val) => val.isEmpty
                        ? 'This field cannot be blank'
                        : null
                ),
              ),
              SizedBox(
                height: 35,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlineButton(
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("CANCEL",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  FlatButton(
                    onPressed: () {
                      //uploadPic();
                      _updateDetails();
                    },
                    color: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      "SAVE",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Text(
                _error,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14.0,
                  fontFamily: 'OpenSans',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}