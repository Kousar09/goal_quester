import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class OneToOneChat extends StatefulWidget {
  final String userId;
  final Map userData;

  const OneToOneChat({super.key, required this.userId, required this.userData});

  @override
  _OneToOneChatState createState() => _OneToOneChatState();
}

class _OneToOneChatState extends State<OneToOneChat> {
  final TextEditingController _messageController = TextEditingController();
  final String myUserId = FirebaseAuth.instance.currentUser!.uid;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildUserProfile(),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _firestore
                  .collection('messages/$myUserId/${widget.userId}')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var messages = snapshot.data!.docs.reversed;
                List<Widget> messageWidgets = [];
                for (var message in messages) {
                  var messageText = message['text'];
                  var messageType = message['type'];
                  var timestamp = message['timestamp'];

                  var messageWidget = MessageWidget(
                      id: message.id,
                      path1: 'messages/$myUserId/${widget.userId}',
                      path2: 'messages/${widget.userId}/$myUserId',
                      type: messageType,
                      text: messageText,
                      timestamp: timestamp);
                  messageWidgets.add(messageWidget);
                }

                return ListView(
                  reverse: true,
                  children: messageWidgets,
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Transform(
      transform: Matrix4.translationValues(-25, 0, 0),
      child: GestureDetector(
        onTap: () {
          // Handle user profile tap
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userData['purl'],
              ), // Replace with the user's profile image URL
            ),
            const SizedBox(width: 12.0),
            Text(
              widget.userData['name'], // Replace with the user's name
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              keyboardType: TextInputType.text,
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              _sendMessage();
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    String messageText = _messageController.text.trim();

    if (messageText.isNotEmpty) {
      var messageId = Uuid().v1();
      _firestore
          .collection('messages/$myUserId/${widget.userId}')
          .doc(messageId)
          .set({
        'text': messageText,
        'type': 'sent',
        'timestamp': DateTime.now().toString(),
      });
      _firestore
          .collection('messages/${widget.userId}/$myUserId')
          .doc(messageId)
          .set({
        'text': messageText,
        'type': 'recieved',
        'timestamp': DateTime.now().toString(),
      });

      _messageController.clear();
    }
  }
}

class MessageWidget extends StatelessWidget {
  MessageWidget({
    super.key,
    required this.id,
    required this.path1,
    required this.path2,
    required this.type,
    required this.text,
    required this.timestamp,
  });
  final String id;
  final String path1;
  final String path2;
  final String type;
  final String text;
  final String timestamp;
  var _tapPosition;

  @override
  Widget build(BuildContext context) {
    void _showCustomMenu() {
      final RenderObject? overlay =
          Overlay.of(context).context.findRenderObject();

      showMenu(
          context: context,
          items: [
            PopupMenuItem(
                onTap: () => _showDeleteConfirmationDialog(context),
                child: const Text('delete'))
          ],
          position: RelativeRect.fromRect(
              _tapPosition & const Size(20, 20), // smaller rect, the touch area
              Offset.zero &
                  overlay!.semanticBounds.size // Bigger rect, the entire screen
              ));
    }

    void _storePosition(TapDownDetails details) {
      _tapPosition = details.globalPosition;
    }

    bool isSent = type == 'sent';
    return GestureDetector(
      onLongPress: _showCustomMenu,
      onTapDown: _storePosition,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
              decoration: BoxDecoration(
                color: isSent
                    ? Colors.blue
                    : const Color.fromARGB(255, 215, 215, 215),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: isSent ? Colors.white : Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _formatTimestamp(timestamp),
              style: const TextStyle(
                fontSize: 10.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    // You can format the timestamp as per your requirement.
    DateTime dateTime = DateTime.parse(timestamp);
    return DateFormat('hh:mm a').format(dateTime);
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _handleDelete();
              },
              child: const Text('Delete for Me'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the confirmation dialog
                _handleDeleteForEveryone();
              },
              child: const Text('Delete for Everyone'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _handleDelete() async {
    await FirebaseFirestore.instance.collection(path1).doc(id).delete();
  }

  void _handleDeleteForEveryone() async {
    await FirebaseFirestore.instance.collection(path1).doc(id).delete();
    await FirebaseFirestore.instance.collection(path2).doc(id).delete();
  }
}
