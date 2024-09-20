// ignore_for_file: prefer_const_constructors

import 'package:chat_app/pages/create_group_page.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddGroupChatPage extends StatefulWidget {
  AddGroupChatPage({Key? key}) : super(key: key);

  @override
  _AddGroupChatPageState createState() => _AddGroupChatPageState();
}

class _AddGroupChatPageState extends State<AddGroupChatPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Contact> _selectedContacts = [];

  @override
  void initState() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    super.initState();
  }

  void _toggleContactSelection(Contact contact) {
    setState(() {
      if (_selectedContacts.contains(contact)) {
        _selectedContacts.remove(contact);
      } else {
        _selectedContacts.add(contact);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsProvider =
        Provider.of<ContactsProvider>(context, listen: false);
    List<Contact> contacts = contactsProvider.contacts;

    List<Contact> filteredContacts = contacts.where((contact) {
      return contact.username
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 184, 214, 230),
      appBar: AppBar(
        title: Text(
          'New Group',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              'Select Contacts to add to group',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color.fromARGB(255, 61, 61, 61)),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: 320,
              height: 60,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 2.5, // Change the color here
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color.fromARGB(255, 238, 238, 238),
                      width: 2, // Change the color here
                    ),
                  ),
                  hintText: 'Search for contacts...',
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredContacts.length,
                itemBuilder: (context, int index) {
                  final contact = filteredContacts[index];
                  final bool isSelected = _selectedContacts.contains(contact);
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.only(right: 12, top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(
                          255, 139, 168, 189), // Lighter shade of blueGrey
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
                            'http://192.168.1.6:8080/profile_image/${contact.username}')),
                        builder: (BuildContext context,
                            AsyncSnapshot<http.Response> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // While the Future is loading, return a CircularProgressIndicator or placeholder
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            // If there's an error loading the image, display the Icon
                            return _buildAvatarWithIcon(Icons.person);
                          } else {
                            // If the image exists, display the CircleAvatar with the NetworkImage
                            return _buildAvatarWithImage(contact.username);
                          }
                        },
                      ),
                      title: Text(contact.username),
                      trailing: isSelected
                          ? Container(
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: Colors.white),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                            )
                          : null,
                      onTap: () {
                        _toggleContactSelection(contact);
                      },
                    ),
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FloatingActionButton(
                  backgroundColor: Colors.blueGrey,
                  onPressed: () {
                    if (_selectedContacts.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return CreateGroupPage(
                              selectedContacts: _selectedContacts);
                        }),
                      );
                    }
                  },
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
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
