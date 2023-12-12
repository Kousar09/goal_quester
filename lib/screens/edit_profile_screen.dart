import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:goal_quester/constants/color_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

import '../main.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key, required this.userData});
  late Map<String, dynamic> userData = new Map();

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool isloading = false;
  final _formKey = GlobalKey<FormState>();
  bool _image = false;
  File? selectedImage;
  late String _firstName = widget.userData['fname'];
  late String _lastName = widget.userData['lname'];
  late String? _gender = widget.userData['gender'];
  late String profileUrl = widget.userData['purl'];
  String userId = FirebaseAuth.instance.currentUser!.uid.toString();
  Future<void> _updateUserData() async {
    try {
      String id = FirebaseAuth.instance.currentUser!.uid.toString();
      final imagesRef =
          FirebaseStorage.instance.ref().child("profile_images/$id.jpeg");
      if (selectedImage != null) {
        try {
          await imagesRef.putFile(
              selectedImage!, SettableMetadata(contentType: "images/jpeg"));
          profileUrl = (await imagesRef.getDownloadURL()).toString();
        } on FirebaseException catch (e) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.code)));
        }
      }
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fname': _firstName.trim(),
        'lname': _lastName.trim(),
        'gender': _gender,
        'purl': profileUrl,
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Profile updated sucessfully!"),
      ));
      // Navigator.pop(context);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MyHomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error Updating profile! " + e.toString()),
      ));
    }
  }

  Future getImage() async {
    var image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    _cropImage(image);
  }

  Future _cropImage(img) async {
    CroppedFile? cropfile = await ImageCropper().cropImage(
        sourcePath: img.path,
        maxWidth: 1080,
        maxHeight: 1080,
        aspectRatioPresets: [CropAspectRatioPreset.square]);
    if (cropfile != null) {
      setState(() {
        _image = true;
        selectedImage = File(cropfile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Edit profile",
          style: GoogleFonts.notoSans(
              textStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    height: 115,
                    width: 100,
                    child: Stack(children: [
                      Positioned(
                        top: 0,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _image
                                ? Image.file(
                                    selectedImage!,
                                    height: 100,
                                    width: 100,
                                  )
                                : widget.userData['purl'] == ''
                                    ? widget.userData['gender'] == 'Female'
                                        ? SvgPicture.asset(
                                            'assets/images/profile_female.svg',
                                            height: 100,
                                            width: 100,
                                          )
                                        : SvgPicture.asset(
                                            'assets/images/profile_male.svg',
                                            height: 100,
                                            width: 100,
                                          )
                                    : CachedNetworkImage(
                                        imageUrl: widget.userData['purl'],
                                        height: 100,
                                        width: 100,
                                        placeholder: (context, url) =>
                                            const SpinKitPulse(
                                          color: Colors.purpleAccent,
                                          size: 50.0,
                                        ),
                                      )),
                      ),
                      Positioned(
                          bottom: 0,
                          right: 30,
                          left: 30,
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                color: Color.fromARGB(255, 214, 56, 185),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  getImage();
                                },
                              )))
                    ]),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "First name",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: widget.userData['fname'],
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 237, 237),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        LineIcons.user,
                        color: Color.fromARGB(255, 214, 56, 185),
                      ),
                      hintText: "First Name"),
                  onChanged: (value) => _firstName = value,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Last name",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                TextFormField(
                  initialValue: widget.userData['lname'],
                  decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(20),
                      filled: true,
                      fillColor: Color.fromARGB(255, 246, 237, 237),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide.none),
                      prefixIcon: Icon(
                        LineIcons.user,
                        color: Color.fromARGB(255, 214, 56, 185),
                      ),
                      hintText: "Last Name"),
                  onChanged: (value) => _lastName = value,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Gender",
                  style: GoogleFonts.notoSans(
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 17),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 246, 237, 237)),
                  child: DropdownButtonFormField<String>(
                    value: widget.userData['gender'],
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                ),
                // TextFormField(
                //   initialValue: _profilePicture,
                //   decoration: InputDecoration(labelText: 'Profile Picture URL'),
                //   onSaved: (value) => _profilePicture = value,
                // ),
                const SizedBox(
                  height: 25,
                ),
                isloading
                    ? SpinKitThreeInOut(
                        color: color_constants.secondary,
                        size: 30.0,
                      )
                    : SizedBox(
                        width: width - 40,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState?.save();
                              setState(() {
                                isloading = true;
                              });
                              await _updateUserData();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shadowColor: Colors.transparent,
                              backgroundColor:
                                  const Color.fromARGB(255, 214, 56, 185),
                              padding: const EdgeInsets.all(15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0)),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'notoSans',
                              )),
                          child: const Text('Save',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
