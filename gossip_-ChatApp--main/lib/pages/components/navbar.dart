import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 227, 216, 255),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              "lingo",
              style: TextStyle(fontFamily: 'shine', fontSize: 38),
            ),
          ),
          SizedBox(
            width: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 22,
                ),
                Icon(
                  Icons.qr_code,
                  size: 22,
                ),
                Icon(
                  Icons.person_2_outlined,
                  size: 22,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
