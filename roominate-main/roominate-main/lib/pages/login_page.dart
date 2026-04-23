import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPart extends StatelessWidget {
  LoginPart({super.key});

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Email Text Field
          TextField(
            controller: usernameController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // Password Text Field
          TextField(
            controller: passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: '********',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Login Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: usernameController.text,
                    password: passwordController.text,
                  );
                } on FirebaseException catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'An unknown error occurred'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(),
              ),
              child: Text(
                'Login',
                style: GoogleFonts.aBeeZee(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
///
/// /// A simple registration form component./// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
/// /// A simple registration form component.
class RegisterPart extends StatelessWidget {
  RegisterPart({super.key});

  final usernameSignup = TextEditingController();
  final emailSignup = TextEditingController();
  final passwordSignup = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Username Text Field
          TextField(
            controller: usernameSignup,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'your_username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Email Text Field
          TextField(
            controller: emailSignup,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'you@example.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          // Password Text Field
          TextField(
            obscureText: true,
            controller: passwordSignup,
            decoration: InputDecoration(
              hintText: '********',
              labelText: 'Password',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Register Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailSignup.text.trim(),
                    password: passwordSignup.text.trim(),
                  );
                  final uid = FirebaseAuth.instance.currentUser!.uid;

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                        'username': usernameSignup.text.trim(),
                        'email': emailSignup.text.trim(),
                      });
                } on FirebaseException catch (e) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.message ?? 'An unknown error occurred'),
                      backgroundColor: Colors.redAccent,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 212, 212, 212),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(),
              ),
              child: Text(
                'Register',
                style: GoogleFonts.aBeeZee(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // This boolean controls which view is active: login or register.
  bool loginactive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 24),
              const Center(child: Icon(Icons.door_sliding_outlined, size: 72)),
              Center(
                child: Text(
                  "Roominate",
                  style: GoogleFonts.playfair(
                    height: 0.8,
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Center(
                child: Text(
                  "Chores Shared, Peace Declared.",
                  style: GoogleFonts.josefinSans(
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Dynamic Greeting Section
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            "Hey",
                            style: GoogleFonts.afacad(
                              height: 0.5,
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          "👋",
                          style: TextStyle(
                            fontSize: 22,
                            letterSpacing: 0,
                            height: 0.5,
                          ),
                        ),
                      ],
                    ),
                    // The vertical space between "Hey" and the next line is 0.
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        loginactive ? "Login Now!" : "Register Now!",
                        style: GoogleFonts.afacad(
                          fontSize: 32,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              // Toggle between Login and Register views
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          loginactive = true;
                        });
                      },
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeIn,
                        style: GoogleFonts.lobster(
                          fontSize: 18,
                          color: loginactive
                              ? Colors.black
                              : Colors.grey.shade600,
                          fontWeight: loginactive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        child: const Text("I am an old user"),
                      ),
                    ),
                  ),
                  Text(
                    " / ",
                    style: GoogleFonts.lobster(
                      fontSize: 28,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        loginactive = false;
                      });
                    },
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      style: GoogleFonts.lobster(
                        fontSize: 18,
                        color: !loginactive
                            ? Colors.black
                            : Colors.grey.shade600,
                        fontWeight: !loginactive
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      child: const Text("Register?"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // AnimatedSwitcher for a smooth transition between forms
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: loginactive
                    ? LoginPart(key: ValueKey('login'))
                    : RegisterPart(key: ValueKey('register')),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
