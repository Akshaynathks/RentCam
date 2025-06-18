
abstract class ChatListEvent {}

class LoadChats extends ChatListEvent {}

class DeleteChat extends ChatListEvent {
  final String chatId;

  DeleteChat(this.chatId);
}


