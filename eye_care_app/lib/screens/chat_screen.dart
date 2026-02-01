import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';
import 'package:eye_care_app/theme/app_colors.dart';

class ChatbotScreen extends StatelessWidget {
  const ChatbotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        title: const Text(
          'Eye Care Assistant',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.teksgelap,
        elevation: 10,
      ),
      body: Column(
        children: const [
          Expanded(child: _ChatList()),
          _OptionSection(),
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

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser)
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.birumuda,
                child: Icon(
                  Icons.visibility,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser
                      ? AppColors.birumuda
                      : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft:
                        isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight:
                        isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  boxShadow: [
                    if (!isUser)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white
                        : AppColors.teksgelap,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class _OptionSection extends StatelessWidget {
  const _OptionSection();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    if (controller.currentOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        // color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: controller.currentOptions.map((option) {
          return OutlinedButton(
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: AppColors.birugelap),
            ),
            onPressed: () {
              controller.selectOption(option);
            },
            child: Text(
              option.text,
              style: const TextStyle(color: AppColors.birugelap),
            ),
          );
        }).toList(),
      ),
    );
  }
}
