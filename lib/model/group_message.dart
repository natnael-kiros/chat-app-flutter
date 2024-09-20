class GroupMessage {
  final int messageId;
  final int groupId;
  final String groupName;
  final String senderId;
  final String senderName;
  final String messageContent;
  final String timestamp;

  GroupMessage({
    required this.messageId,
    required this.groupId,
    required this.groupName,
    required this.senderId,
    required this.senderName,
    required this.messageContent,
    required this.timestamp,
  });
}
