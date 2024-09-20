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
import 'package:http/http.dart' as http;

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

  int selectedMessageIndex = -1;
  Future<String> getTimeFromServer() async {
    try {
      final response =
          await http.get(Uri.parse('http://192.168.1.6:8080//time'));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['time'];
      } else {
        throw Exception('Failed to get time: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get time: $e');
    }
  }

  // Function to send a message
  void sendGroupMessage() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final currentTime = await getTimeFromServer();
    final senderUsername = authProvider.loggedInUsername;

    final message = {
      'type': 'group_message',
      'messageId': generateUniqueId(),
      'groupId': widget.groupname,
      'groupName': widget.groupname,
      'senderId': senderUsername, // Assuming you have access to the sender's ID
      'senderName': senderUsername,
      'messageContent': _message.text,
      'timestamp': currentTime,
    };
    final messageClass = GroupMessage(
      messageId: generateUniqueId(),
      groupId: 0,
      groupName: widget.groupname,
      senderId: senderUsername!,
      senderName: senderUsername!,
      messageContent: _message.text,
      timestamp: currentTime,
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
                  bool isSentByCurrentUser =
                      message.senderName == loggedInUsername;
                  String formattedTime =
                      DateFormat.Hm().format(DateTime.parse(message.timestamp));

                  return GestureDetector(
                    onLongPress: () {
                      // Set the selected message for deletion
                      setState(() {
                        selectedMessageIndex = index;
                      });
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 70), // Adjust horizontal margin
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.7, // Adjust width as needed
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: selectedMessageIndex == index
                                ? Colors.grey.withOpacity(0.5)
                                : Colors.transparent,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Align(
                                alignment: isSentByCurrentUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8), // Adjust padding as needed
                                  decoration: BoxDecoration(
                                    color: isSentByCurrentUser
                                        ? const Color.fromARGB(
                                            188, 96, 125, 139)
                                        : const Color.fromARGB(
                                            188, 96, 125, 139),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(width: 70, height: 2),
                                      Text(
                                        '  ${message.senderName}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isSentByCurrentUser
                                              ? Color.fromARGB(
                                                  255, 21, 204, 218)
                                              : Color.fromARGB(
                                                  255, 44, 216, 130),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        message.messageContent,
                                        style: TextStyle(
                                            color: isSentByCurrentUser
                                                ? Colors.white
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (selectedMessageIndex == index)
                                Positioned(
                                  top: 4, // Adjust as needed
                                  left: isSentByCurrentUser ? -40 : null,
                                  right: !isSentByCurrentUser ? -40 : null,
                                  child: IconButton(
                                    icon: Icon(Icons.delete),
                                    color: Color.fromARGB(195, 117, 15, 15),
                                    onPressed: () {
                                      // deleteMessage(message.messageId);
                                      setState(() {
                                        selectedMessageIndex =
                                            -1; // Reset selected message index
                                      });
                                    },
                                  ),
                                ),
                              Positioned(
                                bottom: -5,
                                right: isSentByCurrentUser ? -60 : null,
                                left: !isSentByCurrentUser ? -60 : null,
                                child: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white,
                                  backgroundImage: NetworkImage(
                                    'http://192.168.1.6:8080/profile_image/${message.senderName}',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
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
