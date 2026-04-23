import 'package:flutter/foundation.dart';
import 'package:gossip/dbconnection/constants.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class MongoDatabase {
  static Db? _db;
  static DbCollection? _collection;
  static bool _isConnected = false;

  /// Connect to MongoDB.
  static Future<void> connect() async {
    if (!_isConnected) {
      try {
        _db = await Db.create(MONGO_URL);
        await _db!.open();
        _collection = _db!.collection(CollectionName);
        _isConnected = true;
        debugPrint('MongoDB connection successful.');
      } catch (e) {
        _isConnected = false;
        debugPrint('MongoDB connection failed: $e');
      }
    } else {
      debugPrint('MongoDB already connected.');
    }
  }

  /// Hash passwords using SHA-256.
  static String hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// Validate user credentials.
  static Future<bool> validateUser(String username, String password) async {
    try {
      await connect();
      String hashedPassword = hashPassword(password);
      final document = await _collection!
          .findOne({"username": username, "password": hashedPassword});
      return document != null;
    } catch (e) {
      debugPrint('User validation error: $e');
      return false;
    }
  }

  /// Check if a username exists.
  static Future<bool> checkUsername(String username) async {
    try {
      await connect();
      final document = await _collection!.findOne({"username": username});
      return document != null;
    } catch (e) {
      debugPrint('Username check error: $e');
      return false;
    }
  }

  /// Check if an email exists.
  static Future<bool> checkEmail(String email) async {
    try {
      await connect();
      final document = await _collection!.findOne({"email": email});
      return document != null;
    } catch (e) {
      debugPrint('Email check error: $e');
      return false;
    }
  }

  /// Insert new user data.
  static Future<void> insertData(
      String username, String password, String email, String name) async {
    try {
      await connect();
      String hashedPassword = hashPassword(password);
      await _collection!.insertOne({
        "username": username,
        "password": hashedPassword,
        "email": email,
        "name": name,
      });
      debugPrint('User data inserted successfully.');
    } catch (e) {
      debugPrint('Failed to insert user data: $e');
    }
  }

  /// Fetch all usernames except the logged-in user.
  static Future<List<String>> getUsernames(String name) async {
    try {
      await connect();
      final cursor = await _collection!
          .find(where.ne("username", name).fields(["name"]))
          .toList();

      if (cursor.isEmpty) {
        return [];
      }

      return cursor.map((doc) => doc['name'].toString()).toList();
    } catch (e) {
      debugPrint('Failed to get usernames: $e');
      return [];
    }
  }

  /// Get messages from user to target user.
  static Future<List<String>> getMessagesFromUser(
      String username, String targetUser) async {
    try {
      await connect();
      final user = await _collection!.findOne(where.eq('username', username));

      if (user == null ||
          user['messages'] == null ||
          user['messages'][targetUser] == null) {
        return [];
      }

      final messages = (user['messages'][targetUser] as List<dynamic>)
          .map((item) => item.toString())
          .toList();

      return messages;
    } catch (error) {
      debugPrint('Error retrieving messages: $error');
      return [];
    }
  }

  static Future<void> addMessage(
      String senderName, String receiverName, String message) async {
    try {
      await connect();
      final filter = where.eq('username', senderName);
      final update = {
        r'$push': {
          'messages.$receiverName': message,
        },
      };

      await _collection!.updateOne(filter, update);
      debugPrint('Message added successfully.');
    } catch (e) {
      debugPrint('Failed to add message: $e');
    }
  }

  static Future<String?> getName(String username) async {
    try {
      await connect();
      final document = await _collection!.findOne({"username": username});
      if (document != null && document['name'] != null) {
        return document['name'].toString();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Failed to get name: $e');
      return null;
    }
  }

  static Future<String?> getuserName(String name) async {
    try {
      await connect();
      final document = await _collection!.findOne({"name": name});
      if (document != null && document['username'] != null) {
        return document['username'].toString();
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Failed to get username: $e');
      return null;
    }
  }

  static Future<String?> getLastMessageSentByUser(String username) async {
    try {
      await connect();
      String? lastMessage;

      await _collection!.find().forEach((user) {
        if (user.containsKey('messages') && user['messages'] is Map) {
          Map<String, dynamic> messages =
              user['messages'] as Map<String, dynamic>;
          if (messages.containsKey(username) && messages[username] is List) {
            List<dynamic> userMessages = messages[username] as List<dynamic>;
            if (userMessages.isNotEmpty) {
              lastMessage = userMessages.last.toString();
            }
          }
        }
      });

      return lastMessage;
    } catch (error) {
      debugPrint('Error finding last message by $username: $error');
      return null;
    }
  }
}
