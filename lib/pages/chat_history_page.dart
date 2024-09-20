// ignore_for_file: prefer_interpolation_to_compose_strings, prefer_const_constructors

import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:chat_app/pages/message_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatHistoryPage extends StatelessWidget {
  ChatHistoryPage({Key? key, required this.channel});
  final WebSocketChannel channel;

  @override
  Widget build(BuildContext context) {
    final messageProvider = Provider.of<MessageProvider>(context);
    List<Message> messages = messageProvider.messages;
    String? loggedInUsername =
        Provider.of<AuthProvider>(context).loggedInUsername;

    Map<String, List<Message>> messagesByContact = {};
    for (Message message in messages) {
      String contact = message.senderUsername == loggedInUsername
          ? message.recipientUsername
          : message.senderUsername;
      messagesByContact.putIfAbsent(contact, () => []);
      messagesByContact[contact]!.add(message);
    }

    Widget _buildAvatarWithImage(String contactUsername) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromARGB(255, 133, 145, 151),
            width: 2.0,
          ),
        ),
        child: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          backgroundImage: NetworkImage(
            'http://192.168.1.6:8080/profile_image/$contactUsername',
          ),
        ),
      );
    }

    Widget _buildAvatarWithIcon(IconData iconData) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blueGrey,
            width: 4.0,
          ),
        ),
        child: CircleAvatar(
          radius: 40,
          child: Icon(
            iconData,
            size: 40,
          ),
        ),
      );
    }

    // Create a list of contacts with their latest message timestamp
    List<ContactWithTimestamp> contacts =
        messagesByContact.entries.map((entry) {
      String contact = entry.key;
      List<Message> messages = entry.value;
      DateTime latestMessageTimestamp = messages
          .map((message) => DateTime.parse(message.timestamp))
          .reduce((value, element) => value.isAfter(element) ? value : element);
      String latestMessageContent = messages
          .firstWhere(
            (message) =>
                message.timestamp == latestMessageTimestamp.toIso8601String(),
          )
          .content;

      // Calculate unread message count (only for messages received by the current user)
      // Calculate unread message count, excluding messages sent by the logged-in user
// Calculate unread message count, excluding messages sent by the logged-in user
      // Calculate unread message count, excluding messages sent by the logged-in user
      // Calculate unread message count, excluding all sent messages

      int unreadMessageCount = messages
          .where((message) =>
              !message.isSent && // Exclude all sent messages
              !message.isRead) // Include unread messages
          .length;
      print('Messages for $contact:');
      for (Message message in messages) {
        print('Message: ${message.content}');
        print('Is Read: ${message.isRead}');
        print('Is Sent: ${message.isSent}');
      }
      print('Unread message count: $unreadMessageCount');

      return ContactWithTimestamp(
        contactUsername: contact,
        latestMessageTimestamp: latestMessageTimestamp,
        latestMessage: latestMessageContent,
        unreadMessageCount: unreadMessageCount,
      );
    }).toList();

    // Sort contacts by their latest message timestamp
    contacts.sort(
        (a, b) => b.latestMessageTimestamp.compareTo(a.latestMessageTimestamp));

    return Container(
      child: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          ContactWithTimestamp contact = contacts[index];
          int unreadMessageCount = contact.unreadMessageCount;
          String formattedTime = DateFormat.Hm().format(
              DateTime.parse(contact.latestMessageTimestamp.toString()));

          int maxMessageLength = 25;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.only(right: 12, top: 6, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50], // Lighter shade of blueGrey
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              leading: FutureBuilder(
                future: http.head(Uri.parse(
                    'http://192.168.1.6:8080/profile_image/${contact.contactUsername}')),
                builder: (BuildContext context,
                    AsyncSnapshot<http.Response> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // While the Future is loading, return a CircularProgressIndicator or placeholder
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // If there's an error loading the image, display the Icon
                    return _buildAvatarWithIcon(Icons.person);
                  } else {
                    // If the image exists, display the CircleAvatar with the NetworkImage
                    return _buildAvatarWithImage(contact.contactUsername);
                  }
                },
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    contact.contactUsername,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                  Container(
                    width: 20,
                    child: unreadMessageCount != 0
                        ? CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              unreadMessageCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              subtitle: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    contact.latestMessage != null
                        ? contact.latestMessage.length > maxMessageLength
                            ? contact.latestMessage
                                    .substring(0, maxMessageLength) +
                                '...'
                            : contact.latestMessage
                        : '',
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.lightBlue),
                  ),
                ],
              ),
              onTap: () {
                messageProvider.markMessagesAsRead(
                    contact.contactUsername, loggedInUsername!);
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return MessagePage(
                      username: contact.contactUsername, channel: channel);
                }));
              },
            ),
          );
        },
      ),
    );
  }
}

class ContactWithTimestamp {
  final String contactUsername;
  final String latestMessage;
  final DateTime latestMessageTimestamp;
  final int unreadMessageCount;

  ContactWithTimestamp({
    required this.contactUsername,
    required this.latestMessage,
    required this.latestMessageTimestamp,
    required this.unreadMessageCount,
  });
}
