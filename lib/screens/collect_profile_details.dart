import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:goal_quester/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icons.dart';

class ProfileDetails extends StatefulWidget {
  const ProfileDetails({super.key, required this.email, required this.pass});
  final String email;
  final String pass;
  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final storageRef = FirebaseStorage.instance.ref();
  List<String> GenderCategories = ['Male', 'Female', 'other'];
  bool _image = false;
  String _fname = '';
  String _lname = '';
  String gender = 'Male';
  String profileUrl = '';
  bool loading = false;
  File? selectedImage;
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

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loading = true;
      });
      try {
        final newUser = await _auth.createUserWithEmailAndPassword(
            email: widget.email, password: widget.pass);
        String id = newUser.user!.uid.toString();
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
        DatabaseReference ref =
            FirebaseDatabase.instance.ref("myapp/users/" + newUser.user!.uid);
        ref.set({"goals": 0, "completed": 0, "pending": 0});

        await _firestore.collection('users').doc(newUser.user!.uid).set({
          'fname': _fname,
          'lname': _lname,
          'email': widget.email,
          'gender': gender,
          'purl': profileUrl
        });
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MyHomePage()));
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign up successfull')));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('The account already exists for that email.')),
          );
        }
      } catch (e) {
        setState(() {
          loading = false;
        });
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text(e.toString()),
                actions: <Widget>[
                  ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }),
                ],
              );
            });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          "Set up your profile",
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
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                : SvgPicture.asset(
                                    'assets/profile_male.svg',
                                    height: 100,
                                    width: 100,
                                  ),
                          ),
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
                  Text(
                    "First name",
                    style: GoogleFonts.notoSans(
                        textStyle: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  SizedBox(
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter First name.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _fname = value;
                      },
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: Color.fromARGB(255, 246, 237, 237),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            LineIcons.user,
                            color: const Color.fromARGB(255, 214, 56, 185),
                          ),
                          hintText: "First Name"),
                    ),
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
                  SizedBox(
                    child: TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Last name.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _lname = value;
                      },
                      decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(20),
                          filled: true,
                          fillColor: Color.fromARGB(255, 246, 237, 237),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none),
                          prefixIcon: Icon(
                            LineIcons.user,
                            color: const Color.fromARGB(255, 214, 56, 185),
                          ),
                          hintText: "Last Name"),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 5,
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
                    child: DropdownButton(
                      isExpanded: true,

                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      hint: const Text(
                          'Select Your Gender'), // Not necessary for Option 1
                      value: gender,
                      onChanged: (newValue) {
                        setState(() {
                          gender = newValue!;
                        });
                      },
                      items: GenderCategories.map((location) {
                        return DropdownMenuItem(
                          child: new Text(location),
                          value: location,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(height: 10.0),
                  loading
                      ? const SpinKitThreeInOut(
                          color: const Color.fromARGB(255, 214, 56, 185),
                          size: 30.0,
                        )
                      : SizedBox(
                          width: width - 40,
                          child: ElevatedButton(
                            onPressed: _submit,
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
                            child: const Text('Signup',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
