import 'models.dart';

final Map<String, ChatbotNode> eyeChatbotFlow = {
  "start": ChatbotNode(
    id: "start",
    message: "Halo 👋 Aku akan bantu cek keluhan matamu. Apa keluhan utamamu?",
    options: [
      ChatbotOption(text: "Mata terasa perih", nextNodeId: "perih"),
      ChatbotOption(text: "Mata kering", nextNodeId: "kering"),
      ChatbotOption(text: "Mata merah", nextNodeId: "merah"),
      ChatbotOption(text: "Penglihatan buram", nextNodeId: "buram"),
    ],
  ),

  "perih": ChatbotNode(
    id: "perih",
    message: "Mata perih biasanya disebabkan iritasi atau kelelahan. Apakah kamu sering menatap layar?",
    options: [
      ChatbotOption(text: "Iya, sering", nextNodeId: "screen_fatigue"),
      ChatbotOption(text: "Tidak", nextNodeId: "perih_lain"),
    ],
  ),

  "screen_fatigue": ChatbotNode(
    id: "screen_fatigue",
    message:
        "Kemungkinan kamu mengalami kelelahan mata digital (Computer Vision Syndrome).\n\nSaran:\n• Istirahatkan mata tiap 20 menit\n• Atur pencahayaan\n• Gunakan aturan 20-20-20",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
    ],
  ),

  "kering": ChatbotNode(
    id: "kering",
    message: "Apakah mata terasa kering disertai rasa mengganjal?",
    options: [
      ChatbotOption(text: "Iya", nextNodeId: "dry_eye"),
      ChatbotOption(text: "Tidak", nextNodeId: "kering_ringan"),
    ],
  ),

  "dry_eye": ChatbotNode(
    id: "dry_eye",
    message:
        "Kemungkinan kamu mengalami Dry Eye Syndrome.\n\nSaran:\n• Gunakan tetes mata\n• Kurangi screen time\n• Perbanyak minum air",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
    ],
  ),

  "end": ChatbotNode(
    id: "end",
    message:
        "Terima kasih sudah menggunakan pengecekan mata 😊\nJika keluhan berlanjut, disarankan ke dokter mata.",
    options: [],
  ),
};
