// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/contact_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key, required this.selectedContacts});
  final List<Contact> selectedContacts;

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _groupname = TextEditingController();
  late List<String> groupMembers = [];
  File? _image;

  Future<void> _getImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    for (Contact contact in widget.selectedContacts) {
      groupMembers.add(contact.username);
      groupMembers.add(authProvider.loggedInUsername!);
    }
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 52, 68, 77),
        title: Text(
          'New Group',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(children: [
        SizedBox(
          height: 20,
        ),
        GestureDetector(
          onTap: () async {
            await _getImage(); // Call corrected image picker method
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.blueGrey, // Set the border color
                width: 2.0, // Set the border width
              ),
            ),
            child: _image == null
                ? CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color.fromARGB(255, 88, 159, 194),
                    child: Icon(
                      Icons.camera_alt,
                      size: 40,
                      color: Colors.white,
                    ),
                  )
                : CircleAvatar(
                    radius: 50,
                    backgroundImage: FileImage(File(_image!.path)),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 70, right: 70),
          child: TextField(
            controller: _groupname,
            decoration: InputDecoration(
              hintText: 'Group name',
              hintStyle: TextStyle(color: Color.fromARGB(255, 231, 230, 230)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 52, 68, 77),
                  width: 2, // Change the color here
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 52, 68, 77),
                  width: 3, // Change the color here
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 80,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 28.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.selectedContacts.length}',
                style: TextStyle(
                    color: Color.fromARGB(255, 35, 63, 78),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: widget.selectedContacts.length,
                itemBuilder: (context, int index) {
                  final contact = widget.selectedContacts[index];
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.symmetric(vertical: 0),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                      color: Color.fromARGB(255, 78, 101, 114),
                    ))),
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
                      title: Text(
                        contact.username,
                        style: TextStyle(
                            color: Color.fromARGB(255, 218, 217, 217)),
                      ),
                      subtitle: Text('last seen recently'),
                    ),
                  );
                })),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 52, 68, 77),
        onPressed: () async {
          final groupProvider =
              Provider.of<GroupProvider>(context, listen: false);
          await groupProvider.createGroup(_groupname.text,
              authProvider.loggedInUsername!, _image!.path, groupMembers);
          groupProvider.addCreatedGroupName(_groupname.text);
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        },
        child: Icon(
          Icons.check,
          color: Colors.white,
          size: 30,
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
        width: 1.0,
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
        width: 1.0,
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
