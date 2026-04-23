import 'package:flutter/material.dart';
import 'package:gossip/dbconnection/mongobd.dart';
import 'package:gossip/pages/chatlogs.dart';
import 'package:lottie/lottie.dart';

class Chatlist extends StatefulWidget {
  final String name;
  const Chatlist({required this.name, super.key});

  @override
  _ChatlistState createState() => _ChatlistState();
}

class _ChatlistState extends State<Chatlist> {
  List<String> usernames = [];
  bool isLoading = true;
  String? errorMessage;
  Map<String, String?> lastMessages = {}; // Store last message for each user

  @override
  void initState() {
    super.initState();
    _loadUsernamesAndLastMessages();
    // Polling mechanism to update last messages every 5 seconds
    _startPolling();
  }

  /// Fetch usernames and their last messages asynchronously
  Future<void> _loadUsernamesAndLastMessages() async {
    try {
      List<String> fetchedUsernames =
          await MongoDatabase.getUsernames(widget.name);
      setState(() {
        usernames = fetchedUsernames;
      });

      Map<String, String?> fetchedLastMessages = {};
      for (final username in usernames) {
        // Fetch last message sent by the correct user
        final lastMessage =
            await MongoDatabase.getLastMessageSentByUser(username);
        fetchedLastMessages[username] = lastMessage;
      }

      setState(() {
        lastMessages = fetchedLastMessages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  /// Polling mechanism to update last messages every 5 seconds
  void _startPolling() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _updateLastMessages();
        _startPolling(); // Repeat polling
      }
    });
  }

  /// Update last messages
  Future<void> _updateLastMessages() async {
    try {
      Map<String, String?> updatedLastMessages = {};
      for (final username in usernames) {
        final lastMessage =
            await MongoDatabase.getLastMessageSentByUser(username);
        setState(() {
          updatedLastMessages[username] = lastMessage;
        });
      }

      setState(() {
        lastMessages = updatedLastMessages;
      });
    } catch (e) {
      // Handle update error if needed
      debugPrint('Error updating last messages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: Lottie.asset('assets/animations/loading.json'));
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    if (usernames.isEmpty) {
      return const Center(child: Text('No users available to chat with.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: usernames.length,
      itemBuilder: (context, index) {
        final otherUsername = usernames[index];
        final lastMessage = lastMessages[otherUsername];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chatlogs(
                      name: widget.name,
                      recieverName: otherUsername,
                    ),
                  ));
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      'assets/images/Profile.jpg',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              otherUsername,
                              style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0),
                            ),
                            Text(
                              lastMessage != null && lastMessage.isNotEmpty
                                  ? lastMessage[0] == "&"
                                      ? "You: ${lastMessage.substring(1, lastMessage.length > 20 ? 20 : lastMessage.length)}${lastMessage.length > 20 ? "..." : ""}"
                                      : "$otherUsername: ${lastMessage.substring(0, lastMessage.length > 20 ? 20 : (lastMessage[lastMessage.length - 1] == '&' ? lastMessage.length - 1 : lastMessage.length))} ${lastMessage.length > 20 ? "..." : ""} "
                                  : "Say hello to ${usernames[index]}",
                              style: TextStyle(
                                  fontFamily: 'inter',
                                  letterSpacing: 0,
                                  color: lastMessage != null &&
                                          lastMessage.isNotEmpty &&
                                          lastMessage[lastMessage.length - 1] ==
                                              '&'
                                      ? Colors.black
                                      : Colors.black45,
                                  fontWeight: lastMessage != null &&
                                          lastMessage.isNotEmpty &&
                                          lastMessage[lastMessage.length - 1] ==
                                              '&'
                                      ? FontWeight.w600
                                      : FontWeight.w200),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
