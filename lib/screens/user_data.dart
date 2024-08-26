import 'dart:developer';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iot_project/screens/main_screen.dart';

class UserDataScreen extends StatefulWidget {
  const UserDataScreen({super.key});

  @override
  State<UserDataScreen> createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  late String fullName; // Variable to store the user's full name
  late String countryValue; // Variable to store the selected country
  late String stateValue; // Variable to store the selected state
  late String cityValue; // Variable to store the selected city
  late String phone; // Variable to store the user's phone number
  Uint8List? _image; // Variable to store the selected profile image

  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Firebase Authentication instance
  final FirebaseStorage _storage =
      FirebaseStorage.instance; // Firebase Storage instance
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Firestore instance

  final _formKey = GlobalKey<FormState>(); // Key for form validation

  // Function to upload user data to Firestore
  Future<void> uploadUserData(
    String fullName,
    String countryValue,
    String cityValue,
    String stateValue,
  ) async {
    EasyLoading.show(status: 'Uploading...'); // Show loading indicator

    try {
      // Upload profile image and get the URL
      String imageUrl = await uploadProfileImageToStorage(_image!);

      // Save user data to Firestore
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        'fullName': fullName,
        'countryValue': countryValue,
        'cityValue': cityValue,
        'stateValue': stateValue,
        'imageUrl': imageUrl,
        'phone': phone,
        'userId': _auth.currentUser!.uid,
      });

      EasyLoading.showSuccess(
          'User data uploaded successfully!'); // Show success message
    } catch (e) {
      log('Error uploading user data: $e'); // Log the error
      EasyLoading.showError('Error uploading user data'); // Show error message
    } finally {
      EasyLoading.dismiss(); // Dismiss the loading indicator
    }
  }

  // Function to upload the profile image to Firebase Storage
  Future<String> uploadProfileImageToStorage(Uint8List? image) async {
    Reference ref = _storage
        .ref()
        .child('profilePics')
        .child(_auth.currentUser!.uid); // Reference to the storage path

    UploadTask uploadTask = ref.putData(image!); // Upload the image data
    TaskSnapshot snapshot = await uploadTask; // Wait for the upload to complete
    String downLoadUrl =
        await snapshot.ref.getDownloadURL(); // Get the download URL
    log('............');
    return downLoadUrl; // Return the download URL
  }

  // Function to pick an image from the gallery
  Future<void> pickImage() async {
    try {
      ImagePicker _picker = ImagePicker();

      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery); // Pick image from gallery
      if (image != null) {
        _image = await image.readAsBytes(); // Read the image as bytes
        log(_image.toString()); // Log the image data
        setState(() {}); // Update the state
      } else {
        log('No image was selected.'); // Log if no image was selected
      }
    } catch (e) {
      log('An error occurred while picking the image: $e'); // Log the error
    }
  }

  // Function to pick an image using the camera
  Future<void> pickImageFromCamera() async {
    try {
      ImagePicker _picker = ImagePicker();

      final XFile? image = await _picker.pickImage(
          source: ImageSource.camera); // Pick image from camera
      if (image != null) {
        _image = await image.readAsBytes(); // Read the image as bytes
        setState(() {}); // Update the state
      } else {
        log('No image was selected.'); // Log if no image was selected
      }
    } catch (e) {
      log('An error occurred while picking the image: $e'); // Log the error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevent resizing when the keyboard appears
      backgroundColor:
          Colors.white.withOpacity(0.95), // Set background color with opacity
      body: Center(
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.start, // Align widgets to the top
            children: [
              Stack(
                children: [
                  // Background container with gradient
                  Container(
                    height: 250,
                    width: MediaQuery.sizeOf(context).width,
                    decoration: const BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF102DE1),
                          Color(0xCC0D6EFF),
                        ],
                      ),
                    ),
                  ),
                  // Positioned container for image selection
                  Positioned(
                    left: 155,
                    top: 80,
                    child: Container(
                      height: 130,
                      width: 100,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(15))),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Icon button to pick image from gallery
                          IconButton(
                            onPressed: () async {
                              await pickImage();
                            },
                            icon: const Icon(Icons.image),
                          ),
                          const Divider(),
                          // Icon button to pick image from camera
                          IconButton(
                            onPressed: () async {
                              await pickImageFromCamera();
                            },
                            icon: const Icon(Icons.camera),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50), // Spacer

              // Full name input field
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Full Name',
                  style: GoogleFonts.getFont(
                    'Nunito Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  fullName = value; // Update the fullName variable
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name'; // Validate input
                  }
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  labelText: 'Enter your full name',
                  labelStyle: GoogleFonts.getFont(
                    'Nunito Sans',
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/icons/email.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacer

              // Phone number input field
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Phone',
                  style: GoogleFonts.getFont(
                    'Nunito Sans',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  phone = value; // Update the phone variable
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number'; // Validate input
                  } else if (value.length < 10) {
                    return 'Please enter a valid phone number'; // Validate phone number length
                  }
                  return null;
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  labelText: 'Enter your phone',
                  labelStyle: GoogleFonts.getFont(
                    'Nunito Sans',
                    fontSize: 14,
                    letterSpacing: 0.1,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      'assets/icons/email.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Spacer

              // Country, State, and City Picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: SelectState(
                  style: GoogleFonts.lato(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                  onCountryChanged: (value) {
                    setState(() {
                      countryValue = value; // Update the country value
                    });
                  },
                  onStateChanged: (value) {
                    setState(() {
                      stateValue = value; // Update the state value
                    });
                  },
                  onCityChanged: (value) {
                    setState(() {
                      cityValue = value; // Update the city value
                    });
                  },
                ),
              ),
              const SizedBox(height: 30), // Spacer

              // Save button
              InkWell(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    await uploadUserData(fullName, countryValue, cityValue,
                        stateValue); // Upload user data
                    EasyLoading.showSuccess(
                        'Great Success!'); // Show success message
                    EasyLoading.dismiss();

                    // Navigate to the MainScreen and remove all previous routes
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                      (Route<dynamic> route) =>
                          false, // Predicate that removes all routes
                    );
                  }
                },
                child: Container(
                  width: 319,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF102DE1),
                        Color(0xCC0D6EFF),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circle with gradient
                      Positioned(
                        left: 278,
                        top: 19,
                        child: Opacity(
                          opacity: 0.5,
                          child: Container(
                            width: 60,
                            height: 60,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 12,
                                color: const Color(0xFF103DE5),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      // Decorative small circle
                      Positioned(
                        left: 311,
                        top: 36,
                        child: Opacity(
                          opacity: 0.3,
                          child: Container(
                            width: 5,
                            height: 5,
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(3),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // Save button text
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Save',
                          style: GoogleFonts.getFont(
                            'Lato',
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
