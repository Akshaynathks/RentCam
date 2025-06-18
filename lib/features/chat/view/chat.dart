import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rent_cam/features/chat/bloc/chat_list_bloc/chat_list_bloc.dart';
import 'package:rent_cam/features/chat/bloc/chat_list_bloc/chat_list_event.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';
import 'package:rent_cam/features/chat/view/chat_list_page.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ChatService>(
          create: (context) => ChatService(),
        ),
        BlocProvider<ChatListBloc>(
          create: (context) => ChatListBloc(
            chatService: context.read<ChatService>(),
          )..add(LoadChats()),
        ),
      ],
      child: const ChatListPage(),
    );
  }
}
