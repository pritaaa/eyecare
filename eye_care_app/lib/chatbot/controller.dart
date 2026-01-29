import 'package:flutter/material.dart';
import 'chatbot_node.dart';
import 'models.dart';
import 'package:flutter/material.dart';

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
  List<String> quickReplies = [];

  ChatbotController() {
    _startChat();
  }

  void _startChat() {
    messages.add(
      ChatMessage(
        text: 'Halo 👋 Aku asisten Eye Care.\nApa keluhan mata kamu?',
        sender: Sender.bot,
      ),
    );

    quickReplies = [
      'Mata perih',
      'Mata kering',
      'Mata merah',
    ];

    notifyListeners();
  }

  void selectReply(String reply) {
    // tampilkan jawaban user
    messages.add(
      ChatMessage(
        text: reply,
        sender: Sender.user,
      ),
    );

    quickReplies = [];

    // FLOW
    if (reply == 'Mata perih') {
      _botReply(
        'Apakah mata terasa perih disertai rasa panas?',
        ['Iya', 'Tidak'],
      );
    } else if (reply == 'Mata kering') {
      _botReply(
        'Apakah mata sering terasa kering saat menatap layar?',
        ['Iya', 'Tidak'],
      );
    } else if (reply == 'Mata merah') {
      _botReply(
        'Apakah mata merah disertai rasa gatal?',
        ['Iya', 'Tidak'],
      );
    } else if (reply == 'Iya') {
      _botReply(
        'Kemungkinan mata mengalami iritasi ringan.\nCoba istirahatkan mata & kurangi screen time ya.',
        ['Terima kasih'],
      );
    } else {
      _botReply(
        'Baik 👍 Kalau keluhan berlanjut, sebaiknya konsultasi ke dokter mata.',
        [],
      );
    }

    notifyListeners();
  }

  void _botReply(String text, List<String> replies) {
    messages.add(
      ChatMessage(
        text: text,
        sender: Sender.bot,
      ),
    );
    quickReplies = replies;
  }
}
