import 'package:flutter/material.dart';
import 'models.dart';
import 'chatbot_node.dart';


enum Sender { bot, user }

class ChatMessage {
  final String text;
  final Sender sender;

  ChatMessage({
    required this.text,
    required this.sender,
  });
}

class ChatbotController extends ChangeNotifier {
  final List<ChatMessage> messages = [];
  List<ChatbotOption> currentOptions = [];

  String _currentNodeId = "start";

  ChatbotController() {
    _loadNode(_currentNodeId);
  }

  void _loadNode(String nodeId) {
    final node = eyeChatbotFlow[nodeId];
    if (node == null) return;

    messages.add(
      ChatMessage(text: node.message, sender: Sender.bot),
    );

    currentOptions = node.options;
    _currentNodeId = nodeId;

    notifyListeners();
  }

  void selectOption(ChatbotOption option) {
    // tampilkan pilihan user
    messages.add(
      ChatMessage(text: option.text, sender: Sender.user),
    );

    currentOptions = [];
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 300), () {
      _loadNode(option.nextNodeId);
    });
  }
}
