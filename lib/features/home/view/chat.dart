import 'package:flutter/material.dart';
import 'package:rent_cam/core/widget/appbar.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

   @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        showBackButton: false,
        title: "Message",
      ),
    );
  }
}

