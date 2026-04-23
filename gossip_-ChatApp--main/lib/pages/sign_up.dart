import 'package:flutter/material.dart';
import 'package:gossip/pages/components/textinputs.dart';
import 'package:gossip/pages/homescreen.dart';
import 'package:gossip/pages/index.dart';
import 'package:lottie/lottie.dart';
import 'package:gossip/dbconnection/mongobd.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  String warnings = "";

  successMessage(BuildContext context) async {
    return ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.hotel_class_outlined,
            color: Colors.white,
          ),
          SizedBox(
            width: 30,
          ),
          Text("Account created successfully")
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 132, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 132, 255, 255),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              "Let's Get Started!",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 30),
            child: Text(
              "Create an account",
              style: TextStyle(fontSize: 18),
            ),
          ),
          Stack(
            children: [
              Center(
                child: Lottie.asset('assets/animations/chat.json', height: 220),
              ),
              Positioned(
                bottom: 10,
                right: 40,
                child: Text(
                  warnings,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              )
            ],
          ),
          InputField(
              prefixIcon: const Icon(Icons.person_rounded),
              obscureText: false,
              hintText: "Username",
              controller: username),
          const SizedBox(height: 10),
          InputField(
              prefixIcon: const Icon(Icons.email_rounded),
              obscureText: false,
              hintText: "Email",
              controller: email),
          const SizedBox(height: 10),
          InputField(
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
              hintText: "Password",
              controller: password),
          const SizedBox(height: 10),
          InputField(
              prefixIcon: const Icon(Icons.lock),
              obscureText: true,
              hintText: "Confirm Password",
              controller: confirmpassword),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 3,
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.lightBlueAccent,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                    side: BorderSide(color: Colors.black)),
              ),
              onPressed: () async {
                // Validate inputs
                if (username.text.isEmpty ||
                    password.text.isEmpty ||
                    confirmpassword.text.isEmpty ||
                    email.text.isEmpty) {
                  setState(() => warnings = "All fields are required");
                  return;
                }

                // Check if username or phone exists
                if (await MongoDatabase.checkUsername(username.text)) {
                  setState(() => warnings = "Username already exists");
                  return;
                }

                if (await MongoDatabase.checkEmail(email.text)) {
                  setState(() => warnings = "Email already in use");
                  return;
                }

                if (password.text.length < 5) {
                  setState(() {
                    warnings = "Password is too short";
                  });
                  return;
                }

                await MongoDatabase.insertData(username.text, password.text,
                    email.text, confirmpassword.text);

                successMessage(context);

                await Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndexScreen(
                        name: username.text,
                      ),
                    ));
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account?"),
              const SizedBox(width: 5),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Homescreen(),
                      ));
                },
                child: const Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline),
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

  RegExp regExp = RegExp(p);

  return regExp.hasMatch(em);
}
