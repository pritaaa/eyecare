import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';

class ChatbotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Care Chatbot'),
      ),
      body: Column(
        children: const [
          Expanded(child: _ChatList()),
          _QuickReplySection(),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  const _ChatList();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final msg = controller.messages[index];
        final isUser = msg.sender == Sender.user;

        return Align(
          alignment:
              isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: isUser
                  ? Colors.blue
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _QuickReplySection extends StatelessWidget {
  const _QuickReplySection();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    if (controller.quickReplies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        children: controller.quickReplies.map((reply) {
          return OutlinedButton(
            onPressed: () {
              controller.selectReply(reply);
            },
            child: Text(reply),
          );
        }).toList(),
      ),
    );
  }
}
