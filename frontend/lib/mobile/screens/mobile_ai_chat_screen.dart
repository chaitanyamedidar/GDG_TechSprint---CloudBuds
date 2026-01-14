import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A simple data model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, {this.isUser = false});
}

class MobileAIChatScreen extends StatefulWidget {
  const MobileAIChatScreen({super.key});

  @override
  State<MobileAIChatScreen> createState() => _MobileAIChatScreenState();
}

class _MobileAIChatScreenState extends State<MobileAIChatScreen> {
  final _textController = TextEditingController();
  final List<ChatMessage> _messages = [
    ChatMessage("Hello! How can I assist you with SafeLabs today?"),
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final prompt = _textController.text;
    setState(() {
      _messages.add(ChatMessage(prompt, isUser: true));
      _isLoading = true;
    });
    _textController.clear();

    try {
      final results = await FirebaseFunctions.instance.httpsCallable('generateChatResponse').call({
        'prompt': prompt,
      });

      final response = results.data['response'] as String? ?? 'Sorry, I couldn\'t process that.';
      setState(() {
        _messages.add(ChatMessage(response));
      });

    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _messages.add(ChatMessage("Error: ${e.message}"));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          if (_isLoading) const LinearProgressIndicator(),
          _buildChatInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.blue.shade600 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.inter(
            color: message.isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask about lab status...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
