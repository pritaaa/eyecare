import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';
import 'package:eye_care_app/theme/app_colors.dart';

class ChatbotScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        title: const Text('Eye Care Chatbot'),
        backgroundColor: AppColors.putih,
        elevation: 20,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   color: AppColors.teksgelap,
        //   onPressed: () => Navigator.pop(context),
        // ),
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
                  ? AppColors.birumuda
                  : Colors.grey.shade300,
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
