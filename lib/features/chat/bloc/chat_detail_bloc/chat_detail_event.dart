import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'dart:io';

abstract class ChatDetailEvent {}

class LoadMessages extends ChatDetailEvent {
  final String chatId;

  LoadMessages(this.chatId);
}

class SendMessage extends ChatDetailEvent {
  final String chatId;
  final String receiverId;
  final String text;
  final MessageType type;
  final String? bookingId;

  SendMessage({
    required this.chatId,
    required this.receiverId,
    required this.text,
    this.type = MessageType.text,
    this.bookingId,
  });
}

class SendImageMessage extends ChatDetailEvent {
  final String chatId;
  final String receiverId;
  final File imageFile;
  final String? caption;

  SendImageMessage({
    required this.chatId,
    required this.receiverId,
    required this.imageFile,
    this.caption,
  });
}

class SendMultipleImageMessages extends ChatDetailEvent {
  final String chatId;
  final String receiverId;
  final List<File> imageFiles;
  final String? caption;

  SendMultipleImageMessages({
    required this.chatId,
    required this.receiverId,
    required this.imageFiles,
    this.caption,
  });
}

class DeleteMessage extends ChatDetailEvent {
  final String chatId;
  final String messageId;

  DeleteMessage({
    required this.chatId,
    required this.messageId,
  });
}

class MarkMessagesAsRead extends ChatDetailEvent {
  final String chatId;

  MarkMessagesAsRead(this.chatId);
}

class SendReplyMessage extends ChatDetailEvent {
  final String chatId;
  final String receiverId;
  final String text;
  final Message replyToMessage;
  final MessageType type;
  final String? bookingId;

  SendReplyMessage({
    required this.chatId,
    required this.receiverId,
    required this.text,
    required this.replyToMessage,
    this.type = MessageType.text,
    this.bookingId,
  });
}

class SendReplyImageMessage extends ChatDetailEvent {
  final String chatId;
  final String receiverId;
  final File imageFile;
  final Message replyToMessage;
  final String? caption;

  SendReplyImageMessage({
    required this.chatId,
    required this.receiverId,
    required this.imageFile,
    required this.replyToMessage,
    this.caption,
  });
}

class SetReplyMessage extends ChatDetailEvent {
  final Message? message;

  SetReplyMessage(this.message);
}

class ClearReplyMessage extends ChatDetailEvent {}
