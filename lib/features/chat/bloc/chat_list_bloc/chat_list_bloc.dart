import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/chat/bloc/chat_list_bloc/chat_list_event.dart';
import 'package:rent_cam/features/chat/bloc/chat_list_bloc/chat_list_state.dart';
import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  final ChatService _chatService;

  ChatListBloc({required ChatService chatService})
      : _chatService = chatService,
        super(ChatListInitial()) {
    on<LoadChats>(_onLoadChats);
    on<DeleteChat>(_onDeleteChat);
  }

  Future<void> _onLoadChats(
    LoadChats event,
    Emitter<ChatListState> emit,
  ) async {
    emit(ChatListLoading());
    try {
      await emit.forEach<List<Chat>>(
        _chatService.getUserChats(),
        onData: (chats) => ChatListLoaded(chats),
        onError: (error, stackTrace) => ChatListError('Failed to load chats'),
      );
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }

  Future<void> _onDeleteChat(
    DeleteChat event,
    Emitter<ChatListState> emit,
  ) async {
    try {
      await _chatService.deleteChat(event.chatId);
      add(LoadChats());
    } catch (e) {
      emit(ChatListError(e.toString()));
    }
  }
}
