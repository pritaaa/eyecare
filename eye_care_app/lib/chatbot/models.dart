class ChatbotNode {
  final String id;
  final String message;
  final List<ChatbotOption> options;

  ChatbotNode({
    required this.id,
    required this.message,
    required this.options,
  });
}



class ChatbotOption {
  final String text;
  final String nextNodeId;

  ChatbotOption({
    required this.text,
    required this.nextNodeId,
  });
}


enum Sender { bot, user }

class ChatMessage {
  final String text;
  final Sender sender;

  ChatMessage({
    required this.text,
    required this.sender,
  });
}
