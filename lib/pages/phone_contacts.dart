import 'package:chat_app/providers/contact_provider.dart';
import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart' as contactservice;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ContactListScreen extends StatefulWidget {
  @override
  _ContactListScreenState createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  TextEditingController _searchController = TextEditingController();
  List<contactservice.Contact> _filteredContacts = [];
  List<contactservice.Contact> _contacts = [];

  @override
  void initState() {
    super.initState();
    if (Provider.of<ContactsProvider>(context, listen: false)
        .phoneContacts
        .isEmpty) {
      fetchContacts();
    } else {
      setState(() {
        _filteredContacts = _contacts =
            Provider.of<ContactsProvider>(context, listen: false).phoneContacts;
      });
    }
  }

  Future<void> fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      Iterable<contactservice.Contact>? contacts =
          await contactservice.ContactsService.getContacts();
      setState(() {
        _contacts = contacts?.toList() ?? [];
        Provider.of<ContactsProvider>(context, listen: false)
            .setPhoneContacts(contacts.toList());
        _filteredContacts = _contacts; // Initialize filtered list
      });
    }
  }

  void filterContacts(String searchText) {
    setState(() {
      _filteredContacts = _contacts.where((contact) {
        String displayName = contact.displayName ?? '';
        return displayName.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: filterContacts,
          decoration: InputDecoration(
            hintText: 'Search contacts...',
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: _filteredContacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _filteredContacts.length,
              itemBuilder: (BuildContext context, int index) {
                final contact = _filteredContacts[index];
                String? contactname = contact.displayName ?? 'Unknown';
                String phoneNumber = contact.phones?.isNotEmpty == true
                    ? contact.phones!.first.value!
                    : 'N/A';

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                  padding: EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  height: 85,
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
                    onTap: () {
                      Navigator.pop(context, [contactname, phoneNumber]);
                    },
                    leading: CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 171, 202, 216),
                      radius: 25,
                      child: Text(contact.initials()),
                    ),
                    title: Text(contactname),
                    subtitle: Text('Phone Number: $phoneNumber'),
                  ),
                );
              },
            ),
    );
  }
}
