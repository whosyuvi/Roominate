import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gossip/dbconnection/mongobd.dart';

class Chatlogs extends StatefulWidget {
  final String name;
  final String recieverName;
  const Chatlogs({required this.name, required this.recieverName, super.key});

  @override
  State<Chatlogs> createState() => _ChatlogsState();
}

class _ChatlogsState extends State<Chatlogs> {
  TextEditingController msg = TextEditingController();
  List<String> msgs = [];
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startPeriodicUpdate();
  }

  Future<void> _loadMessages() async {
    if (!mounted) return; // Add mounted check

    setState(() => _isLoading = true);

    try {
      await MongoDatabase.connect();
      final newMessages = await MongoDatabase.getMessagesFromUser(
        widget.name,
        widget.recieverName,
      );

      if (!mounted) return; // Check again after async operations

      setState(() => msgs = newMessages);
    } catch (e) {
      debugPrint('Error loading messages: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startPeriodicUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) async {
      try {
        String message = (await MongoDatabase.getLastMessageSentByUser(
                widget.recieverName)) ??
            '';
        debugPrint("Message: $message");
        debugPrint("database ka last: ${msgs.last}");
        if (mounted) {
          setState(() {
            if (message.substring(1, message.length - 2) !=
                msgs.last.substring(1, message.length - 2)) {
              msgs.add(message);
            }
          });
        }
      } catch (e) {
        debugPrint('Error updating messages: $e');
      }
    });
    debugPrint("Messages updated");
  }

  @override
  void dispose() {
    _timer?.cancel();
    msg.dispose(); // Dispose the text controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recieverName),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: msgs.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  mainAxisAlignment: msgs[index].startsWith('&')
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: msgs[index].startsWith("&")
                              ? Colors.cyan[200]
                              : Colors.purple,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(20)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Text(
                            msgs[index].startsWith('&')
                                ? msgs[index].substring(1)
                                : msgs[index]
                                    .substring(0, msgs[index].length - 1),
                            style: TextStyle(
                              fontFamily: 'inter',
                              fontSize: 16,
                              color: msgs[index].startsWith('&')
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: msg,
                decoration: const InputDecoration(
                  hintText: "Type your message...",
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final message = msg.text.trimRight();
                if (message.isNotEmpty) {
                  try {
                    // Update UI optimistically
                    setState(() => msgs.add("&$message"));
                    await MongoDatabase.addMessage(
                      widget.name,
                      widget.recieverName,
                      "&$message",
                    );
                    String? reciever = await MongoDatabase.getName(widget.name);
                    String? senderName =
                        await MongoDatabase.getuserName(widget.recieverName);
                    await MongoDatabase.addMessage(senderName ?? "Unknown",
                        reciever ?? "Unknown", "${msg.text}&");
                    msg.clear();
                  } catch (e) {
                    // Rollback on error
                    setState(() => msgs.removeLast());
                    debugPrint('Error sending message: $e');
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.amber,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.navigate_next),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
