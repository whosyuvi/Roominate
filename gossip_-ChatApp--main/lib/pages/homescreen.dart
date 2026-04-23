import 'package:flutter/material.dart';
import 'package:gossip/dbconnection/mongobd.dart';
import 'package:gossip/pages/components/textinputs.dart';
import 'package:gossip/pages/index.dart';
import 'package:gossip/pages/sign_up.dart';
import 'package:lottie/lottie.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  String isCorrect = "";

  @override
  void dispose() {
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 132, 255, 255),
      body: ListView(
        children: [
          Stack(
            children: [
              const SizedBox(
                height: 260,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Center(
                      child: Text(
                        "lingo",
                        style: TextStyle(
                          fontFamily: 'Shine',
                          letterSpacing: 2,
                          color: Colors.lightBlueAccent,
                          fontSize: 54,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 4,
                              color: Color.fromRGBO(0, 0, 0, 0.5),
                            )
                          ],
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Lottie.asset(
                  'assets/animations/chat.json',
                  height: 240,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          InputField(
            controller: username,
            prefixIcon: const Icon(Icons.person),
            hintText: 'Username',
            obscureText: false,
          ),
          const SizedBox(height: 12),
          InputField(
            controller: password,
            prefixIcon: const Icon(Icons.lock),
            hintText: 'Password',
            obscureText: true,
          ),
          SizedBox(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Forgot password?",
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    isCorrect,
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.w500),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
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
                if (await MongoDatabase.validateUser(
                    username.text, password.text)) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndexScreen(name: username.text),
                    ),
                  );
                } else {
                  setState(() {
                    isCorrect = "Invalid username or password!";
                  });
                }
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                  boxShadow: const [
                    BoxShadow(
                        color: Color.fromARGB(255, 182, 182, 182),
                        blurRadius: 5,
                        offset: Offset(3, 3))
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.black)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/google.png',
                    height: 30,
                  ),
                  const Text(
                    " Sign in with Google",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              const SizedBox(width: 5),
              InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUp(),
                  ),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
