// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:chat_app/model/group_message.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:intl/intl.dart';

class GroupMessagePage extends StatefulWidget {
  GroupMessagePage({Key? key, required this.groupname, required this.channel})
      : super(key: key);

  final String groupname;

  final WebSocketChannel channel;

  @override
  State<GroupMessagePage> createState() => _GroupMessagePageState();
}

class _GroupMessagePageState extends State<GroupMessagePage> {
  final TextEditingController _message = TextEditingController();

  // Function to send a message
  void sendGroupMessage() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);

    final senderUsername = authProvider.loggedInUsername;

    final message = {
      'type': 'group_message',
      'messageId': generateUniqueId(),
      'groupId': widget.groupname,
      'groupName': widget.groupname,
      'senderId': senderUsername, // Assuming you have access to the sender's ID
      'senderName': senderUsername,
      'messageContent': _message.text,
      'timestamp': DateTime.now().toIso8601String(),
    };
    final messageClass = GroupMessage(
      messageId: generateUniqueId(),
      groupId: 0,
      groupName: widget.groupname,
      senderId: senderUsername!,
      senderName: senderUsername!,
      messageContent: _message.text,
      timestamp: DateTime.now().toString(),
    );

    final channel = widget.channel;
    groupProvider.addGroupMessage(messageClass);
    channel.sink.add(jsonEncode(message));

    _message.clear();
    FocusScope.of(context).unfocus();
  }

  // Function to delete a message
  // void deleteMessage(String messageId) {
  //   final messageProvider =
  //       Provider.of<MessageProvider>(context, listen: false);
  //   messageProvider.deleteMessage(messageId);

  //   final deleteData = {
  //     'type': 'delete',
  //     'messageId': messageId,
  //   };

  //   widget.channel.sink.add(jsonEncode(deleteData));
  // }

  // Function to generate a unique message ID
  int generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    final groupProvier = Provider.of<GroupProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? loggedInUsername = authProvider.loggedInUsername;
    List<GroupMessage> groupMessages = groupProvier.groupMessages;
    List<GroupMessage> filteredMessages = groupMessages
        .where((message) => message.groupName == widget.groupname)
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text(
          widget.groupname,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text('Option 1')),
                PopupMenuItem(child: Text('Option 2')),
                PopupMenuItem(child: Text('Option 3')),
              ];
            },
          )
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 151, 191, 211),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, int index) {
                GroupMessage message = filteredMessages[index];
                bool isSentByCurrentUser = message.senderId == loggedInUsername;

                return Align(
                  alignment: isSentByCurrentUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 1, horizontal: 75),
                    padding: EdgeInsets.only(
                        left: 18, right: 15, top: 15, bottom: 15),
                    decoration: BoxDecoration(
                      color: isSentByCurrentUser
                          ? const Color.fromARGB(188, 96, 125, 139)
                          : const Color.fromARGB(188, 96, 125, 139),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                        bottomLeft: isSentByCurrentUser
                            ? Radius.circular(12)
                            : Radius.circular(0),
                        bottomRight: isSentByCurrentUser
                            ? Radius.circular(0)
                            : Radius.circular(12),
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.senderName,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSentByCurrentUser
                                    ? Color.fromARGB(255, 21, 204, 218)
                                    : Color.fromARGB(255, 44, 216, 130),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              message.messageContent,
                              style: TextStyle(
                                  color: isSentByCurrentUser
                                      ? Colors.white
                                      : Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        Positioned(
                          bottom: -20, // Adjust the value to move it up or down
                          right: isSentByCurrentUser
                              ? -80
                              : null, // Adjust the value to move it left or right
                          left: !isSentByCurrentUser
                              ? -80
                              : null, // Adjust the value to move it left or right
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            backgroundImage: NetworkImage(
                              'http://192.168.1.6:8080/profile_image/${message.senderName}',
                            ), // Replace URL with your image URL
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )),
            SizedBox(
              height: 5,
            ),
            Container(
              color: Colors.blueGrey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _message,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Message",
                          labelStyle: TextStyle(color: Colors.white),
                          hintStyle: TextStyle(
                            color: Color.fromARGB(190, 243, 243, 243),
                            fontSize: 16.0,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        size: 30,
                        color: Color.fromARGB(190, 243, 243, 243),
                      ),
                      onPressed: sendGroupMessage,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Function to format timestamp to a readable format
  String formatTimestamp(String timestamp) {
    final dateTime = DateTime.parse(timestamp);
    final formattedTime = DateFormat.Hm().format(dateTime);
    return formattedTime;
  }
}
