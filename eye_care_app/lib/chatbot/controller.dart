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
  bool _isDisposed = false;

  ChatbotController() {
    _loadNode(_currentNodeId);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  void _loadNode(String nodeId) {
    final node = eyeChatbotFlow[nodeId];
    if (node == null) {
      print("❌ NODE NOT FOUND: $nodeId");
      return;
    }

    print("✅ Loading node: $nodeId");
    print("📝 Message: ${node.message}");
    print("🔘 Options count: ${node.options.length}");

    messages.add(
      ChatMessage(
        text: node.message,
        sender: Sender.bot,
      ),
    );

    currentOptions = node.options;
    _currentNodeId = nodeId;

    print("🎯 Current options set: ${currentOptions.length}");
    
    _safeNotify();
  }

  Future<void> selectOption(ChatbotOption option) async {
  print("👆 User selected: ${option.text} → ${option.nextNodeId}");

  // ✅ HANDLE CLEAR CHAT DI SINI
  if (option.nextNodeId == "clear_chat") {
    clearChat();
    return;
  }

  messages.add(
    ChatMessage(
      text: option.text,
      sender: Sender.user,
    ),
  );

  currentOptions = [];
  _safeNotify();

  await Future.delayed(const Duration(milliseconds: 300));

  if (_isDisposed) return;

  _loadNode(option.nextNodeId);
}


  // ✅ METHOD BARU: Clear semua chat dan mulai dari awal
  void clearChat() {
  print("🗑️ Clearing all chat history");

  messages.clear();
  currentOptions = [];
  _currentNodeId = "start";

  _safeNotify(); // notify dulu setelah clear
  _loadNode("start");

  print("✅ Chat cleared, restarted from beginning");
}



  // ✅ Track jawaban user
  // String? triggerCondition;
  // String? mainSymptom;
  // String? timePattern;
  // bool? improvedWithRest;
  // String? environmentFactor;

  // Future<void> selectOption(ChatbotOption option) async {
  //   print("👆 User selected: ${option.text} → ${option.nextNodeId}");
    
  //   // ✅ Handle clear chat
  //   if (option.nextNodeId == "clear_chat") {
  //     clearChat();
  //     return;
  //   }

  //   // ✅ Track jawaban berdasarkan node saat ini
  //   if (_currentNodeId == "start") {
  //     triggerCondition = option.text;
  //   } else if (_currentNodeId == "symptoms") {
  //     mainSymptom = option.text;
  //   } else if (_currentNodeId == "time_pattern") {
  //     timePattern = option.text;
  //   } else if (_currentNodeId == "rest_effect") {
  //     improvedWithRest = option.text.contains("membaik");
  //   } else if (_currentNodeId == "environment") {
  //     environmentFactor = option.text;
  //   }

  //   // ✅ Logic untuk menentukan hasil
  //   if (option.nextNodeId == "result_analysis") {
  //     String resultNode = _determineResult();
      
  //     messages.add(
  //       ChatMessage(
  //         text: option.text,
  //         sender: Sender.user,
  //       ),
  //     );

  //     currentOptions = [];
  //     _safeNotify();

  //     await Future.delayed(const Duration(milliseconds: 800));

  //     if (_isDisposed) return;

  //     _loadNode(resultNode);
  //     return;
  //   }
    
  //   // ... sisa kode selectOption
  // }

  // String _determineResult() {
  //   // Logic sederhana untuk menentukan hasil
  //   if (triggerCondition?.contains("layar") == true && 
  //       timePattern?.contains("malam") == true &&
  //       improvedWithRest == true) {
  //     return "result_digital_eye_strain";
  //   } else if (mainSymptom?.contains("pegal") == true ||
  //              mainSymptom?.contains("berat") == true) {
  //     return "result_eye_fatigue";
  //   } else if (environmentFactor?.contains("AC") == true ||
  //              mainSymptom?.contains("berair") == true) {
  //     return "result_environmental";
  //   } else {
  //     return "result_digital_eye_strain"; // Default
  //   }
  // }
}