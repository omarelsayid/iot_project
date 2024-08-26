import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iot_project/screens/authentication_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Reference to the 'users' collection in Firestore
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  // FirebaseAuth instance for managing user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF102DE1),
                  Color(0xCC0D6EFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Center(
            child: Text(
              'Profile',
              style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 4,
                  color: Colors.white),
            ),
          ),
        ),
      ),
      // Fetch user data from Firestore
      body: FutureBuilder<DocumentSnapshot>(
        future: users.doc(_auth.currentUser!.uid).get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // Handle any errors
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }

          // Handle case where the document doesn't exist
          if (snapshot.hasData && !snapshot.data!.exists) {
            return const Center(child: Text("Document does not exist"));
          }

          // When the snapshot is complete, display the user data
          if (snapshot.connectionState == ConnectionState.done) {
            // Get the data from Firestore
            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            return Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // Display user's profile picture
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: NetworkImage(data['imageUrl']),
                  ),
                  // Display user's full name
                  Text(
                    data['fullName'],
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  // Display user's email
                  Text(
                    FirebaseAuth.instance.currentUser!.email!,
                    style: GoogleFonts.quicksand(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Display user's phone number
                  Text(
                    data['phone'],
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  // Display user's country
                  Text(
                    data['countryValue'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Sign out button
                  InkWell(
                    onTap: () async {
                      // Sign out the user
                      await _auth.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed Out')));

                      // Redirect to the login screen after signing out
                      Future.delayed(const Duration(seconds: 2), () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false, // Prevent going back
                        );
                      });
                    },
                    child: Container(
                      width: 219,
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
                          Positioned(
                            left: 218,
                            top: -10,
                            child: Opacity(
                              opacity: 0.3,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              'Sign Out',
                              style: GoogleFonts.getFont(
                                'Lato',
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show a loading indicator while data is being fetched
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.blue,
            ),
          );
        },
      ),
    );
  }
}