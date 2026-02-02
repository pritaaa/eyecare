import 'models.dart';

final Map<String, ChatbotNode> eyeChatbotFlow = {
  // START - Pertanyaan Pembuka (konteks hidup pasien)
  "start": ChatbotNode(
    id: "start",
    message:
        "Selamat datang di Asisten Pemeriksaan Kesehatan Mata.\n\n"
        "Keluhan mata Anda biasanya muncul dalam kondisi seperti apa?",
    options: [
      ChatbotOption(text: "Setelah menatap layar lama (HP/laptop)", nextNodeId: "symptoms"),
      ChatbotOption(text: "Saat membaca atau fokus jarak dekat", nextNodeId: "symptoms"),
      ChatbotOption(text: "Saat berada di ruangan ber-AC atau berdebu", nextNodeId: "symptoms"),
      ChatbotOption(text: "Saat kurang tidur atau begadang", nextNodeId: "symptoms"),
      ChatbotOption(text: "Tidak yakin atau kombinasi beberapa hal", nextNodeId: "symptoms"),
    ],
  ),

  // GEJALA UTAMA
  "symptoms": ChatbotNode(
    id: "symptoms",
    message: "Gejala apa yang paling Anda rasakan saat ini?\n(Pilih yang paling sesuai)",
    options: [
      ChatbotOption(text: "Mata terasa perih atau panas", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Mata kering", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Mata sering berair", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Mata terasa berat atau pegal", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Mata merah", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Penglihatan buram", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Sulit fokus saat membaca", nextNodeId: "time_pattern"),
      ChatbotOption(text: "Silau berlebihan (terutama malam)", nextNodeId: "time_pattern"),
    ],
  ),

  // WAKTU & POLA
  "time_pattern": ChatbotNode(
    id: "time_pattern",
    message: "Kapan keluhan ini paling terasa?",
    options: [
      ChatbotOption(text: "Pagi hari", nextNodeId: "rest_effect"),
      ChatbotOption(text: "Siang hari", nextNodeId: "rest_effect"),
      ChatbotOption(text: "Sore atau malam hari", nextNodeId: "rest_effect"),
      ChatbotOption(text: "Sepanjang hari", nextNodeId: "rest_effect"),
    ],
  ),

  // DURASI & KEPARAHAN
  "rest_effect": ChatbotNode(
    id: "rest_effect",
    message: "Apakah keluhan membaik setelah mata diistirahatkan?",
    options: [
      ChatbotOption(text: "Ya, membaik", nextNodeId: "environment"),
      ChatbotOption(text: "Sedikit membaik", nextNodeId: "environment"),
      ChatbotOption(text: "Tidak membaik", nextNodeId: "red_flag"),
    ],
  ),

  // FAKTOR LINGKUNGAN & KEBIASAAN
  "environment": ChatbotNode(
    id: "environment",
    message: "Apakah Anda sering berada di kondisi berikut?\n(Pilih yang paling sering)",
    options: [
      ChatbotOption(text: "Ruangan ber-AC", nextNodeId: "red_flag"),
      ChatbotOption(text: "Menatap layar tanpa istirahat", nextNodeId: "red_flag"),
      ChatbotOption(text: "Jarang berkedip", nextNodeId: "red_flag"),
      ChatbotOption(text: "Kurang minum air", nextNodeId: "red_flag"),
      ChatbotOption(text: "Menggunakan lensa kontak", nextNodeId: "red_flag"),
      ChatbotOption(text: "Pernah menggunakan kacamata minus atau silinder", nextNodeId: "red_flag"),
    ],
  ),

  // RED FLAG (WAJIB)
  "red_flag": ChatbotNode(
    id: "red_flag",
    message: "Apakah Anda mengalami salah satu dari berikut?",
    options: [
      ChatbotOption(text: "Nyeri mata hebat", nextNodeId: "result_urgent"),
      ChatbotOption(text: "Penglihatan tiba-tiba menurun", nextNodeId: "result_urgent"),
      ChatbotOption(text: "Mata merah disertai nyeri", nextNodeId: "result_urgent"),
      ChatbotOption(text: "Sakit kepala berat atau mual", nextNodeId: "result_urgent"),
      ChatbotOption(text: "Trauma mata", nextNodeId: "result_urgent"),
      ChatbotOption(text: "Tidak ada", nextNodeId: "result_analysis"),
    ],
  ),

  // HASIL - URGENT (Red Flag)
  "result_urgent": ChatbotNode(
    id: "result_urgent",
    message:
        "PERHATIAN\n\n"
        "Berdasarkan gejala yang Anda alami, disarankan untuk segera memeriksakan diri ke dokter mata.\n\n"
        "Gejala yang Anda sebutkan memerlukan pemeriksaan medis langsung untuk memastikan tidak ada kondisi serius.",
    options: [
      ChatbotOption(text: "Mengerti", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // ANALISIS HASIL (Logic sederhana)
  "result_analysis": ChatbotNode(
    id: "result_analysis",
    message: "Sedang menganalisis keluhan Anda...",
    options: [
      ChatbotOption(text: "Lihat Hasil", nextNodeId: "result_digital_eye_strain"),
    ],
  ),

  // HASIL A - Kelelahan Mata Digital / Mata Kering Ringan
  "result_digital_eye_strain": ChatbotNode(
    id: "result_digital_eye_strain",
    message:
        "HASIL PEMERIKSAAN\n\n"
        "Kemungkinan: Kelelahan Mata Digital atau Mata Kering Ringan\n\n"
        "Ciri-ciri:\n"
        "• Dipicu oleh penggunaan layar\n"
        "• Lebih berat pada sore atau malam hari\n"
        "• Membaik saat istirahat\n\n"
        "SARAN:\n\n"
        "1. Terapkan Aturan 20-20-20\n"
        "   Setiap 20 menit, lihat objek sejauh 20 kaki (6 meter) selama 20 detik\n\n"
        "2. Berkedip Lebih Sering\n"
        "   Berkedip secara sadar saat menatap layar\n\n"
        "3. Atur Posisi Layar\n"
        "   Layar sejajar atau sedikit di bawah mata, jarak 50-70 cm\n\n"
        "4. Kurangi Paparan AC Langsung\n"
        "   Hindari aliran udara AC mengarah langsung ke wajah\n\n"
        "5. Gunakan Tetes Air Mata Buatan\n"
        "   Gunakan bila perlu (tanpa pengawet)\n\n"
        "Catatan: Ini bukan diagnosis medis. Jika keluhan berlanjut lebih dari 1 minggu, konsultasikan ke dokter mata.",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // HASIL B - Kelelahan Otot Mata
  "result_eye_fatigue": ChatbotNode(
    id: "result_eye_fatigue",
    message:
        "HASIL PEMERIKSAAN\n\n"
        "Kemungkinan: Kelelahan Otot Mata\n\n"
        "Ciri-ciri:\n"
        "• Mata terasa pegal dan berat\n"
        "• Sulit fokus pada jarak dekat\n"
        "• Sering membaca atau melakukan pekerjaan detail\n\n"
        "SARAN:\n\n"
        "1. Istirahatkan Mata Secara Terjadwal\n"
        "   Beri jeda setiap 1-2 jam\n\n"
        "2. Pijat Ringan Area Sekitar Mata\n"
        "   Gunakan ujung jari dengan lembut\n\n"
        "3. Latihan Fokus Dekat dan Jauh\n"
        "   Bergantian melihat objek dekat dan jauh\n\n"
        "4. Evaluasi Kebutuhan Kacamata\n"
        "   Periksa mata jika belum pernah menggunakan kacamata\n\n"
        "Catatan: Ini bukan diagnosis medis. Jika keluhan berlanjut, konsultasikan ke dokter mata.",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // HASIL C - Iritasi Lingkungan Ringan
  "result_environmental": ChatbotNode(
    id: "result_environmental",
    message:
        "HASIL PEMERIKSAAN\n\n"
        "Kemungkinan: Iritasi Lingkungan Ringan\n\n"
        "Ciri-ciri:\n"
        "• Mata merah atau berair\n"
        "• Sering berada di ruangan berdebu atau ber-AC\n"
        "• Tidak selalu terkait dengan penggunaan layar\n\n"
        "SARAN:\n\n"
        "1. Hindari Paparan Langsung AC\n"
        "   Atur arah aliran udara\n\n"
        "2. Jaga Kelembapan Ruangan\n"
        "   Gunakan pelembap udara (humidifier) jika perlu\n\n"
        "3. Jangan Sering Mengucek Mata\n"
        "   Gunakan tisu bersih jika diperlukan\n\n"
        "4. Gunakan Tetes Air Mata Buatan\n"
        "   Untuk menjaga kelembapan mata\n\n"
        "Catatan: Ini bukan diagnosis medis. Jika mata merah berlanjut lebih dari 3 hari, segera konsultasikan ke dokter mata.",
    options: [
      ChatbotOption(text: "Selesai", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // HASIL D - Tidak Dapat Disimpulkan
  "result_uncertain": ChatbotNode(
    id: "result_uncertain",
    message:
        "HASIL PEMERIKSAAN\n\n"
        "Untuk memastikan kondisi mata Anda, disarankan melakukan pemeriksaan langsung ke dokter mata.\n\n"
        "Beberapa keluhan mata memerlukan pemeriksaan fisik dan alat khusus untuk diagnosis yang tepat.\n\n"
        "Segera berkonsultasi jika:\n"
        "• Keluhan berlanjut lebih dari 1 minggu\n"
        "• Penglihatan menurun\n"
        "• Nyeri mata yang tidak hilang\n"
        "• Mata merah disertai kotoran",
    options: [
      ChatbotOption(text: "Mengerti", nextNodeId: "end"),
      ChatbotOption(text: "Ulangi Pemeriksaan", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // END
  "end": ChatbotNode(
    id: "end",
    message:
        "Terima kasih telah menggunakan Asisten Pemeriksaan Mata.\n\n"
        "Jaga kesehatan mata Anda dengan:\n"
        "• Istirahat yang cukup\n"
        "• Penggunaan layar yang bijak\n"
        "• Pemeriksaan rutin ke dokter mata\n\n"
        "Semoga lekas membaik.",
    options: [
      ChatbotOption(text: "Mulai Lagi", nextNodeId: "start"),
      ChatbotOption(text: "Hapus Riwayat", nextNodeId: "clear_chat"),
    ],
  ),

  // NODE: Clear Chat
  "clear_chat": ChatbotNode(
    id: "clear_chat",
    message: "",
    options: [],
  ),
};