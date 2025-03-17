import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MessagesScreen2 extends StatefulWidget {
  const MessagesScreen2({Key? key}) : super(key: key);

  @override
  _MessagesScreen2State createState() => _MessagesScreen2State();
}

class _MessagesScreen2State extends State<MessagesScreen2> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // Dummy messages list to simulate a chat
  final List<String> _messages = [];

  void _sendMessage() {
    String message = _messageController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        _messages.add(message);
      });
      _messageController.clear();

      // Optionally scroll to the bottom after sending a message.
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildMessageBubble(String message, bool isSentByUser) {
    return Align(
      alignment: isSentByUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message),
      ),
    );
  }

  InputDecoration _messageInputDecoration() {
    return InputDecoration(
      hintText: 'Type your message...',
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        // fontSize: 12,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      isDense: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // For now, we'll assume all messages are sent by the user.
                // Adjust this logic as needed.
                return _buildMessageBubble(_messages[index], true);
              },
            ),
          ),
          // Message input field with send button using report_store_page style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.camera(PhosphorIconsStyle.regular),
                  ),
                  onPressed: () {
                    // Add camera functionality if needed.
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: _messageInputDecoration(),
                  ),
                ),
                IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.paperPlaneRight(PhosphorIconsStyle.fill),
                    color: Colors.red,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
