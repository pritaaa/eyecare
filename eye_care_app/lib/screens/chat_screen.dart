import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eye_care_app/chatbot/controller.dart';
import 'package:eye_care_app/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:sizer/sizer.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.putih,
      appBar: AppBar(
        title: Text(
          'Asisten Mata',
          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.teksgelap,
        elevation: 2,
      ),
      body: Column(
        children: [
          Expanded(child: _ChatList(scrollController: _scrollController)),
          SafeArea(top: false, child: const _OptionSection()),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

class _ChatList extends StatelessWidget {
  final ScrollController scrollController;

  const _ChatList({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ChatbotController>();

    // Auto scroll setelah ada pesan baru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final msg = controller.messages[index];
        final isUser = msg.sender == Sender.user;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!isUser)
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.bluePrimary,
                child: Icon(Icons.visibility, size: 16, color: Colors.white),
              ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.blueLight2 : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser
                        ? const Radius.circular(16)
                        : Radius.zero,
                    bottomRight: isUser
                        ? Radius.zero
                        : const Radius.circular(16),
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
                    color: isUser ? Colors.black54 : AppColors.teksgelap,
                    fontSize: 14.sp,
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
      margin: const EdgeInsets.only(bottom: 16), // ✅ Kurangi margin dari 70
      constraints: const BoxConstraints(
        maxHeight: 180,
      ), // ✅ Tambah sedikit tinggi
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.putih,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: controller.currentOptions.asMap().entries.map((entry) {
            final index = entry.key;
            final option = entry.value;

            return Padding(
              padding: EdgeInsets.only(
                bottom: index < controller.currentOptions.length - 1 ? 8 : 0,
              ),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: AppColors.birugelap),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  controller.selectOption(option);
                },
                child: Text(
                  option.text,
                  style: TextStyle(color: AppColors.birugelap, fontSize: 14.sp),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
