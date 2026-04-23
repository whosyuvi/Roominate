import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskName = TextEditingController();
  late Future<String> usernameFuture;

  @override
  void initState() {
    super.initState();
    usernameFuture = fetchUsername();
  }

  Future<String> fetchUsername() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('User not signed in');

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (!doc.exists || !doc.data()!.containsKey('username')) {
      throw Exception('Username not found');
    }

    return doc['username'];
  }

  Stream<List<Map<String, dynamic>>> taskStream() {
    return FirebaseFirestore.instance
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // include ID for update
            return data;
          }).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder<String>(
                    future: usernameFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                          'Hi! User',
                          style: GoogleFonts.lobster(fontSize: 28),
                        );
                      } else {
                        return Text(
                          'Hey! ${snapshot.data}',
                          style: GoogleFonts.lobster(fontSize: 32, height: 0.2),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Log Out",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SearchBar(
                    controller: _taskName,
                    side: const WidgetStatePropertyAll(BorderSide()),
                    shape: const WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                    leading: const Icon(Icons.add, color: Colors.black26),
                    hintText: 'Add Task',
                    autoFocus: false,
                    constraints: BoxConstraints.tight(Size(250, 50)),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    final user = await usernameFuture;
                    if (_taskName.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('tasks').add({
                        'task': _taskName.text.trim(),
                        'createdBy': user,
                        'createdAt': FieldValue.serverTimestamp(),
                        'volunteeredBy': 'None',
                      });
                      _taskName.clear();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.add_circle),
                              Text(
                                "  Task Successfully Added",
                                style: GoogleFonts.roboto(),
                              ),
                            ],
                          ),
                          duration: Duration(seconds: 2),
                          backgroundColor: Colors.blueAccent,
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Add Job",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: taskStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading tasks"));
                  }

                  final tasks = snapshot.data ?? [];

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      final Timestamp? timestamp = task['createdAt'];
                      final DateTime dateTime =
                          timestamp?.toDate() ?? DateTime.now();
                      final String relative = timeago.format(dateTime);
                      DateFormat('EEE, MMM d, h:mm a').format(dateTime);

                      return InkWell(
                        onDoubleTap: () async {
                          final username = await usernameFuture;
                          if (task['volunteeredBy'] == "None") {
                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(task['id'])
                                .update({'volunteeredBy': username});
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.warning),

                                    Text("You have volunteered for the task"),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.cyan,
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(Icons.done_rounded),
                                    Text("Task has been finished"),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.amber,
                              ),
                            );
                            await Future.delayed(Duration(seconds: 1));

                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(task['id'])
                                .delete();
                          }
                        },

                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            task['volunteeredBy'] == "None"
                                                ? Icons.hourglass_top_rounded
                                                : Icons.construction_rounded,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            task['task'],
                                            style: GoogleFonts.roboto(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.brown,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Text(
                                        relative,
                                        style: GoogleFonts.robotoSlab(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Assigned by: ${task['createdBy']}',
                                        style: GoogleFonts.robotoFlex(
                                          fontWeight: FontWeight.w100,
                                          color: Colors.black54,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        'Volunteer: ${task['volunteeredBy']}',
                                        style: GoogleFonts.robotoSlab(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
