// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/message_provider.dart';
import 'package:chat_app/pages/message_page.dart';
import 'package:chat_app/pages/phone_contacts.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:contacts_service/contacts_service.dart' as contacts_service;
import 'package:chat_app/pages/phone_contacts.dart';

class ContactsPage extends StatefulWidget {
  ContactsPage({Key? key, required this.channel}) : super(key: key);
  final WebSocketChannel channel;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  TextEditingController _username = TextEditingController();
  TextEditingController _phoneno = TextEditingController();
  Future<bool> checkUserExists(String username) async {
    final response =
        await http.get(Uri.parse('http://192.168.1.6:8080/user/$username'));

    if (response.statusCode == 200) {
      // User exists on the server
      return true;
    } else {
      // User does not exist on the server
      return false;
    }
  }

  void _openContactListScreen(BuildContext context) async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (context) => ContactListScreen()),
    );
    if (result != null && result.length == 2) {
      setState(() {
        _username.text = result[0]; // Username
        _phoneno.text = result[1]; // Phone number
      });
    }
  }

// Call _openContactListScreen() when you want to navigate to the contact list screen
  @override
  Widget build(BuildContext context) {
    final contactsProvider = Provider.of<ContactsProvider>(context);
    final loggedInUsername =
        Provider.of<AuthProvider>(context, listen: false).loggedInUsername;

    List<Contact> contacts = contactsProvider.contacts;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Contacts",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          String imageUsername = contacts[index].username;

          return GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return MessagePage(
                    username: contacts[index].username,
                    channel: widget.channel);
              }));
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: EdgeInsets.only(right: 12, top: 12, bottom: 12),
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
                leading: FutureBuilder(
                  future: http.get(Uri.parse(
                      'http://192.168.1.6:8080/profile_image/$imageUsername')),
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
                      return _buildAvatarWithImage(imageUsername);
                    }
                  },
                ),
                title: Text(
                  contacts[index].username,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                subtitle: Text(
                  contacts[index].contactPhone,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Color.fromARGB(255, 133, 145, 151),
                  ),
                  onPressed: () {
                    contactsProvider.removeContact(
                        loggedInUsername!, contacts[index].username);
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: Stack(
        children: [
          Positioned(
            bottom: 30,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Add Contacts",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      content: Container(
                        height: 285,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _username,
                              decoration: InputDecoration(
                                hintText: 'User Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            TextField(
                              controller: _phoneno,
                              decoration: InputDecoration(
                                hintText: 'Phone No',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            TextButton(
                              onPressed: () {
                                _openContactListScreen(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Text(
                                  'Select From Phone',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.blueGrey),
                                shape:
                                    MaterialStateProperty.all<OutlinedBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () async {
                                    bool userExists =
                                        await checkUserExists(_username.text);
                                    if (userExists == true) {
                                      contactsProvider.addContact(
                                          loggedInUsername!,
                                          _username.text,
                                          _phoneno.text);
                                      Navigator.pop(context);
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Row(
                                              children: [
                                                Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  'Error',
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            content: Text(
                                              "The User doesn't exist in Chat App",
                                              style: TextStyle(
                                                color: Colors.red,
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Text(
                                      'Add',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blueGrey),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.blueGrey),
                                    shape: MaterialStateProperty.all<
                                        OutlinedBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Icon(Icons.person_add, color: Colors.white),
              backgroundColor: Colors.blueGrey,
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithImage(String imageUsername) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Color.fromARGB(255, 133, 145, 151),
          width: 4.0,
        ),
      ),
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.transparent,
        backgroundImage: NetworkImage(
          'http://192.168.1.6:8080/profile_image/$imageUsername',
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
}
