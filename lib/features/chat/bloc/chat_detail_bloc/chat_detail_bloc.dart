import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_event.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_state.dart';
import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';
import 'package:rent_cam/features/home/services/profile_photo.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  final ChatService _chatService;

  ChatDetailBloc({required ChatService chatService})
      : _chatService = chatService,
        super(ChatDetailInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<SendMultipleImageMessages>(_onSendMultipleImageMessages);
    on<DeleteMessage>(_onDeleteMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<SendReplyMessage>(_onSendReplyMessage);
    on<SendReplyImageMessage>(_onSendReplyImageMessage);
    on<SetReplyMessage>(_onSetReplyMessage);
    on<ClearReplyMessage>(_onClearReplyMessage);
  }

  // Public getter for current user ID
  String get currentUserId => _chatService.currentUserId;

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(ChatDetailLoading());
    try {
      // Get other user info
      final currentUserId = _chatService.currentUserId;

      // Try to parse participants from chat ID
      List<String> participants;
      try {
        participants = event.chatId.split('_');
      } catch (e) {
        emit(ChatDetailError('Invalid chat ID format'));
        return;
      }

      if (participants.length < 2) {
        emit(ChatDetailError('Invalid chat ID: insufficient participants'));
        return;
      }

      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => participants.first, // Fallback to first participant
      );

      final otherUser = await _chatService.getUserInfo(otherUserId);

      await emit.forEach<List<Message>>(
        _chatService.getChatMessages(event.chatId),
        onData: (messages) {
          // Preserve reply message state if it exists
          Message? replyMessage;
          if (state is ChatDetailLoaded) {
            replyMessage = (state as ChatDetailLoaded).replyMessage;
          }
          return ChatDetailLoaded(messages,
              otherUser: otherUser, replyMessage: replyMessage);
        },
        onError: (_, __) => ChatDetailError('Failed to load messages'),
      );
    } catch (e) {
      emit(ChatDetailError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      await _chatService.sendMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        text: event.text,
        type: event.type,
        bookingId: event.bookingId,
      );
    } catch (e) {
      emit(ChatDetailError('Failed to send message: ${e.toString()}'));
    }
  }

  Future<void> _onSendImageMessage(
    SendImageMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      await _chatService.sendImageMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        imageFile: event.imageFile,
        caption: event.caption,
      );
    } catch (e) {
      emit(ChatDetailError('Failed to send image: ${e.toString()}'));
    }
  }

  Future<void> _onSendMultipleImageMessages(
    SendMultipleImageMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      await _chatService.sendMultipleImageMessages(
        chatId: event.chatId,
        receiverId: event.receiverId,
        imageFiles: event.imageFiles,
        caption: event.caption,
      );
      emit(ChatDetailSuccess('Images sent successfully'));
    } catch (e) {
      emit(ChatDetailError('Failed to send images: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteMessage(
    DeleteMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      print(
          'ChatDetailBloc: Deleting message ${event.messageId} from chat ${event.chatId}');
      await _chatService.deleteMessage(event.chatId, event.messageId);
      print('ChatDetailBloc: Message deletion completed successfully');

      // Don't emit success state here as it might interfere with the stream
      // The stream will automatically update when the message is deleted
    } catch (e) {
      print('ChatDetailBloc: Failed to delete message: ${e.toString()}');
      emit(ChatDetailError('Failed to delete message: ${e.toString()}'));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      await _chatService.markMessagesAsRead(
        event.chatId,
        _chatService.currentUserId,
      );
    } catch (e) {
      // Fail silently for read receipts
    }
  }

  Future<void> _onSendReplyMessage(
    SendReplyMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      print('Sending reply message: ${event.text}');
      print(
          'Reply to message: ${event.replyToMessage.id} - ${event.replyToMessage.text}');
      await _chatService.sendReplyMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        text: event.text,
        replyToMessage: event.replyToMessage,
        type: event.type,
        bookingId: event.bookingId,
      );
      print('Reply message sent successfully');
    } catch (e) {
      print('Error sending reply message: $e');
      emit(ChatDetailError('Failed to send reply message: ${e.toString()}'));
    }
  }

  Future<void> _onSendReplyImageMessage(
    SendReplyImageMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(event.imageFile);
      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Send the reply image message
      await _chatService.sendReplyMessage(
        chatId: event.chatId,
        receiverId: event.receiverId,
        text: event.caption ?? 'Image',
        replyToMessage: event.replyToMessage,
        type: MessageType.image,
        imageUrl: imageUrl,
      );
    } catch (e) {
      emit(ChatDetailError('Failed to send reply image: ${e.toString()}'));
    }
  }

  void _onSetReplyMessage(
    SetReplyMessage event,
    Emitter<ChatDetailState> emit,
  ) {
    print(
        'Setting reply message in bloc: ${event.message?.id} - ${event.message?.text}');
    if (state is ChatDetailLoaded) {
      final currentState = state as ChatDetailLoaded;
      emit(ChatDetailLoaded(
        currentState.messages,
        otherUser: currentState.otherUser,
        replyMessage: event.message,
      ));
      print('Reply message set successfully');
    } else {
      print(
          'State is not ChatDetailLoaded, current state: ${state.runtimeType}');
    }
  }

  void _onClearReplyMessage(
    ClearReplyMessage event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is ChatDetailLoaded) {
      final currentState = state as ChatDetailLoaded;
      emit(ChatDetailLoaded(
        currentState.messages,
        otherUser: currentState.otherUser,
        replyMessage: null,
      ));
    }
  }
}
