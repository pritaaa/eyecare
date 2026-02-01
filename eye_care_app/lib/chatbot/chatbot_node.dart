import 'models.dart';

final Map<String, ChatbotNode> eyeChatbotFlow = {
  // START
  "start": ChatbotNode(
    id: "start",
    message:
        "Halo 👋\nSaya adalah asisten pemeriksaan kesehatan mata.\n\nSilakan pilih keluhan utama yang sedang Anda alami:",
    options: [
      ChatbotOption(text: "Mata terasa perih / panas", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Mata terasa kering", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Mata sering berair", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Mata terasa berat / pegal", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Mata merah", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Penglihatan buram", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Sulit fokus saat membaca", nextNodeId: "confirm_screen"),
      ChatbotOption(text: "Silau berlebihan (malam hari)", nextNodeId: "confirm_screen"),
    ],
  ),

  // KONFIRMASI 1
  "confirm_screen": ChatbotNode(
    id: "confirm_screen",
    message:
        "Apakah keluhan tersebut sering muncul setelah menatap layar dalam waktu lama?",
    options: [
      ChatbotOption(text: "Ya", nextNodeId: "confirm_time"),
      ChatbotOption(text: "Tidak", nextNodeId: "confirm_time"),
    ],
  ),

  // KONFIRMASI 2
  "confirm_time": ChatbotNode(
    id: "confirm_time",
    message:
        "Apakah keluhan terasa lebih berat pada sore atau malam hari?",
    options: [
      ChatbotOption(text: "Ya", nextNodeId: "confirm_environment"),
      ChatbotOption(text: "Tidak", nextNodeId: "confirm_environment"),
    ],
  ),

  // KONFIRMASI 3
  "confirm_environment": ChatbotNode(
    id: "confirm_environment",
    message:
        "Apakah Anda sering berada di ruangan ber-AC atau jarang berkedip saat bekerja?",
    options: [
      ChatbotOption(text: "Ya", nextNodeId: "result_digital_eye_strain"),
      ChatbotOption(text: "Tidak", nextNodeId: "result_eye_fatigue"),
    ],
  ),

  // HASIL A
  "result_digital_eye_strain": ChatbotNode(
    id: "result_digital_eye_strain",
    message:
        "Berdasarkan jawaban Anda, keluhan kemungkinan berkaitan dengan:\n\n"
        "🟢 Kelelahan mata digital dan mata kering ringan.\n\n"
        "Saran:\n"
        "• Terapkan aturan 20-20-20\n"
        "• Sadar berkedip saat menatap layar\n"
        "• Gunakan tetes air mata buatan\n"
        "• Hindari AC langsung ke wajah\n"
        "• Atur posisi layar sejajar mata",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
    ],
  ),

  // HASIL B
  "result_eye_fatigue": ChatbotNode(
    id: "result_eye_fatigue",
    message:
        "Keluhan Anda kemungkinan disebabkan oleh kelelahan otot mata sementara.\n\n"
        "Saran:\n"
        "• Istirahatkan mata secara berkala\n"
        "• Atur jarak dan tinggi layar\n"
        "• Lakukan peregangan mata ringan\n\n"
        "Kondisi ini umumnya tidak berbahaya.",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
    ],
  ),

  // END
  "end": ChatbotNode(
    id: "end",
    message:
        "Terima kasih telah menggunakan pemeriksaan mata 😊\n"
        "Jaga kesehatan mata Anda dengan istirahat yang cukup dan penggunaan layar yang bijak.",
    options: [],
  ),
};
