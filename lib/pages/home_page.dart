// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:chat_app/model/group_message.dart';
import 'package:chat_app/pages/add_user_to_group_t.dart';
import 'package:chat_app/pages/group_chat_page.dart';
import 'package:chat_app/pages/test_page.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:chat_app/pages/chat_history_page.dart';
import 'package:chat_app/pages/login_page.dart';
import 'package:flutter/material.dart';
import "package:provider/provider.dart";
import 'package:chat_app/pages/contacts_page.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    // Establish WebSocket connection
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final senderUsername = authProvider.loggedInUsername;
    final contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);

    // groupProvider.getGroupsForUser(authProvider.loggedInUsername!);
    contactsProvider.loadContacts(senderUsername!);
    channel = IOWebSocketChannel.connect(
      'ws://192.168.1.6:8080/websocket',
    );

    // Include username in the initial "connect" message payload
    channel.sink
        .add(jsonEncode({'type': 'connect', 'username': senderUsername}));

    channel.stream.listen((message) {
      handleMessage(message);
    });
  }

  void handleMessage(message) {
    print('toptopttptptoptoptoptpotopt');
    // Parse the incoming message
    Map<String, dynamic> data = jsonDecode(message);

    String messageType = data['type'];
    switch (messageType) {
      case 'chat_message':
        handleChatMessage(data);
        break;
      case 'group_names':
        handleGroupNames(data);
        break;
      case 'group_message':
        print(
            'eeeeeeeeeeee\neeeeeeeee\neeeeeeeeeeee\neeeeeeeeeeee\neeeeeeeeeeee\neeeeeee');
        handleGroupMessages(data);
        break;
      // Add more cases as needed for other message types
      default:
        print('Unhandled message type: $messageType');
    }
  }

  void handleGroupMessages(Map<String, dynamic> messageData) {
    print(
        'fffffffffffffff\nfffffffffff\nffffffffffffffffff\nffffffffffffffffff\nfffffffffffffff');
    print(messageData);
    GroupMessage message = GroupMessage(
      messageId: messageData['messageId'],
      groupId: messageData['groupId'],
      groupName: messageData['groupName'],
      senderId: messageData['senderId'],
      senderName: messageData['senderName'],
      messageContent: messageData['messageContent'],
      timestamp: messageData['timestamp'],
    );
    Provider.of<GroupProvider>(context, listen: false).addGroupMessage(message);
  }

  void handleChatMessage(Map<String, dynamic> data) {
    // Extract data from the message
    String messageId = data['messageId'];
    String senderUsername = data['senderUsername'];
    String recipientUsername = data['recipientUsername'];
    String content = data['content'];
    String timestamp = data['timestamp'];
    bool isRead = data['isRead'];
    bool isSent = data['isSent'];

    // Process the chat message
    // For example, add it to your message provider
    Provider.of<MessageProvider>(context, listen: false).addMessage({
      'messageId': messageId,
      'senderUsername': senderUsername,
      'recipientUsername': recipientUsername,
      'content': content,
      'timestamp': timestamp,
      'isRead': isRead,
      'isSent': isSent,
    });
  }

  void handleGroupNames(Map<String, dynamic> data) {
    // Extract group names from the message
    List<String> groupNames = List<String>.from(data['group_names']);

    Provider.of<GroupProvider>(context, listen: false)
        .addGroupNames(groupNames);

    print(
        'qqqqqqqqqq\nqqqqqqqqqqqqqq\nqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqq\nqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqqqqqqqqqqqqq\nqqqqqqqqqqqqqqqqqqqq');
    print(groupNames);
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    final loggedInUsername = authProvider.loggedInUsername;
    final phoneNo = authProvider.loggedInUserPhoneNo;
    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: Colors.blueGrey),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return ContactsPage(channel: channel);
          }));
        },
        child: Icon(
          Icons.edit,
          color: Colors.white,
        ),
        backgroundColor: Colors.blueGrey, // Set your custom background color
        shape: CircleBorder(),
      ),
      body: Column(
        children: [
          BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.group),
                label: 'Group Chat',
              ),
            ],
          ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                ChatHistoryPage(
                  channel: channel,
                ),
                GroupChatPage(channel: channel),
              ],
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 180, 208, 223),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blueGrey),
              child: Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                        'http://192.168.1.6:8080/profile_image/$loggedInUsername',
                      ),
                      radius: 40,
                    ),
                    SizedBox(
                        height: 5), // Adjust spacing between image and text
                    Text(
                      loggedInUsername ?? 'FallbackUsername',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '0${phoneNo.toString()}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                child: ListView(
                  padding: EdgeInsets.zero, // Remove ListView default padding
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ContactsPage(
                            channel: channel,
                          );
                        }));
                      },
                      leading: Icon(
                        Icons.account_circle,
                        color: Colors.blueGrey,
                      ),
                      title: Text("Contacts"),
                    ),
                    ListTile(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AddGroupChatPage();
                        }));
                      },
                      leading: Icon(
                        Icons.people,
                        color: Colors.blueGrey,
                      ),
                      title: Text("New Group"),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.settings,
                        color: Colors.blueGrey,
                      ),
                      title: Text("Setting"),
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.info_outline,
                        color: Colors.blueGrey,
                      ),
                      title: Text("About"),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Color.fromARGB(255, 152, 176, 189),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  onTap: () {
                    final messageProvider =
                        Provider.of<MessageProvider>(context, listen: false);
                    messageProvider.clearMessages();
                    final groupProvider =
                        Provider.of<GroupProvider>(context, listen: false);
                    Provider.of<ContactsProvider>(context, listen: false)
                        .clearPhoneContact();
                    groupProvider.clearGroups();

                    authProvider.logout();
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ));
                  },
                  leading: Icon(
                    Icons.logout,
                    color: Colors.blueGrey,
                  ),
                  title: Text(
                    "logout",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
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
