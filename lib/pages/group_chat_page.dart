import 'package:chat_app/model/group_message.dart';
import 'package:chat_app/pages/group_message_page.dart';
import 'package:chat_app/providers/auth_provider.dart';
import 'package:chat_app/providers/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({Key? key, required this.channel}) : super(key: key);
  final WebSocketChannel channel;

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    List<String> groupNames = groupProvider.groupNames;

    // Sort groupNames based on the timestamp of the latest message
    groupNames.sort((a, b) {
      final latestMessageA = groupProvider.getLatestMessageForGroup(a);
      final latestMessageB = groupProvider.getLatestMessageForGroup(b);

      if (latestMessageA == null && latestMessageB == null) {
        return 0;
      } else if (latestMessageA == null) {
        return 1;
      } else if (latestMessageB == null) {
        return -1;
      } else {
        return latestMessageB.timestamp.compareTo(latestMessageA.timestamp);
      }
    });

    return Scaffold(
      body: ListView.builder(
        itemCount: groupNames.length,
        itemBuilder: (context, index) {
          final GroupMessage? latestgroupmessage =
              groupProvider.getLatestMessageForGroup(groupNames[index]);

          String formattedTime =
              latestgroupmessage != null && latestgroupmessage.timestamp != null
                  ? DateFormat.Hm()
                      .format(DateTime.parse(latestgroupmessage.timestamp))
                  : '';
          final maxMessageLength = 25;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: EdgeInsets.only(right: 12, top: 5, bottom: 12),
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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return GroupMessagePage(
                      groupname: groupNames[index], channel: channel);
                }));
              },
              leading: CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  'http://192.168.1.6:8080/group_image/${groupNames[index]}',
                ),
              ),
              title: Text(
                groupNames[index],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                latestgroupmessage?.messageContent != null
                    ? latestgroupmessage!.messageContent.length >
                            maxMessageLength
                        ? latestgroupmessage.messageContent
                                .substring(0, maxMessageLength) +
                            '...'
                        : latestgroupmessage.messageContent
                    : '',
              ),
              trailing: Text(
                formattedTime,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.lightBlue),
              ),
              // You can add more information about the group here if needed
            ),
          );
        },
      ),
    );
  }
}
