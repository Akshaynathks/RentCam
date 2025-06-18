import 'package:rent_cam/features/chat/model/chat_models.dart';

abstract class ChatDetailState {}

class ChatDetailInitial extends ChatDetailState {}

class ChatDetailLoading extends ChatDetailState {}

class ChatDetailLoaded extends ChatDetailState {
  final List<Message> messages;
  final ChatUser? otherUser;
  final Message? replyMessage;

  ChatDetailLoaded(this.messages, {this.otherUser, this.replyMessage});
}

class ChatDetailSuccess extends ChatDetailState {
  final String message;

  ChatDetailSuccess(this.message);
}

class ChatDetailError extends ChatDetailState {
  final String message;

  ChatDetailError(this.message);
}
