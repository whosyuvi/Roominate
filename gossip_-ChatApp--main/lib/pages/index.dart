import 'package:flutter/material.dart';
import 'package:gossip/pages/components/chatList.dart';
import 'package:gossip/pages/components/navbar.dart';

class IndexScreen extends StatefulWidget {
  final String name;
  const IndexScreen({required this.name, super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        toolbarHeight: 5,
      ),
      body: ListView(
        children: [
          const SizedBox(
            child: Navbar(),
          ),
          const SizedBox(
            height: 10,
          ),
          Chatlist(
            name: widget.name,
          ),
        ],
      ),
    );
  }
}
