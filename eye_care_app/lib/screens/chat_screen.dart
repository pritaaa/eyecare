
import 'package:flutter/material.dart';

enum Sender { bot, user }

class ChatMessage {
  final String text;
  final Sender sender;
  final List<String>? options;

  ChatMessage({
    required this.text,
    required this.sender,
    this.options,
  });
}



class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> messages = [];
  int step = 0;

  @override
  void initState() {
    super.initState();
    startChat();
  }

  void startChat() {
    messages.add(
      ChatMessage(
        text: "Hi! 👋 How can I help you today?",
        sender: Sender.bot,
        options: [
          "Book Eye Check",
          "Vision Tips",
          "Find Clinic",
        ],
      ),
    );
  }

  void onOptionSelected(String option) {
    // tampilkan pilihan user sebagai bubble
    messages.add(
      ChatMessage(
        text: option,
        sender: Sender.user,
      ),
    );

    // LOGIC FLOW
    Future.delayed(const Duration(milliseconds: 300), () {
      handleBotResponse(option);
    });

    setState(() {});
  }

  void handleBotResponse(String option) {
    messages.removeWhere((m) => m.options != null);

    if (step == 0) {
      step = 1;

      messages.add(
        ChatMessage(
          text: "Great! When are you available?",
          sender: Sender.bot,
          options: [
            "Today 11:30",
            "Today 13:00",
            "Tomorrow 09:00",
          ],
        ),
      );
    } else if (step == 1) {
      step = 2;

      messages.add(
        ChatMessage(
          text: "✅ Appointment booked at $option.\nAnything else I can help?",
          sender: Sender.bot,
          options: [
            "Find Clinic",
            "Vision Tips",
            "No, thanks",
          ],
        ),
      );
    } else {
      messages.add(
        ChatMessage(
          text: "Thanks for chatting! 👀💙",
          sender: Sender.bot,
        ),
      );
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Chatty"),
      ),
      body: Column(
        children: [
          Expanded(child: buildMessages()),
          buildInputArea(),
        ],
      ),
    );
  }

  Widget buildMessages() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return Column(
          crossAxisAlignment: msg.sender == Sender.bot
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.end,
          children: [
            chatBubble(msg),
            if (msg.options != null) quickReplies(msg.options!),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget chatBubble(ChatMessage msg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: msg.sender == Sender.bot
            ? Colors.white
            : Colors.deepPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        msg.text,
        style: TextStyle(
          color: msg.sender == Sender.bot ? Colors.black : Colors.white,
        ),
      ),
    );
  }

  Widget quickReplies(List<String> options) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        return OutlinedButton(
          onPressed: () => onOptionSelected(opt),
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
          ),
          child: Text(opt),
        );
      }).toList(),
    );
  }

  Widget buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enabled: false,
              decoration: InputDecoration(
                hintText: "Use buttons to reply",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.send, color: Colors.white),
          )
        ],
      ),
    );
  }
}
