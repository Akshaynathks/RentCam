import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rent_cam/core/widget/color.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_bloc.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_event.dart';
import 'package:rent_cam/features/chat/bloc/chat_detail_bloc/chat_detail_state.dart';
import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'package:rent_cam/features/chat/services/chat_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({super.key, required this.chatId});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatDetailBloc>().add(LoadMessages(widget.chatId));
    context.read<ChatDetailBloc>().add(MarkMessagesAsRead(widget.chatId));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile>? images = await picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (images != null && images.isNotEmpty) {
        final state = context.read<ChatDetailBloc>().state;
        if (state is ChatDetailLoaded && state.otherUser != null) {
          // Show loading snackbar for multiple images
          if (images.length > 1) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Sending ${images.length} images...'),
                  ],
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }

          if (images.length == 1) {
            // Single image
            if (state.replyMessage != null) {
              // Send reply image
              context.read<ChatDetailBloc>().add(
                    SendReplyImageMessage(
                      chatId: widget.chatId,
                      receiverId: state.otherUser!.id,
                      imageFile: File(images.first.path),
                      replyToMessage: state.replyMessage!,
                      caption: _messageController.text.trim().isNotEmpty
                          ? _messageController.text.trim()
                          : null,
                    ),
                  );
              // Clear reply after sending
              context.read<ChatDetailBloc>().add(ClearReplyMessage());
            } else {
              // Send normal image
              context.read<ChatDetailBloc>().add(
                    SendImageMessage(
                      chatId: widget.chatId,
                      receiverId: state.otherUser!.id,
                      imageFile: File(images.first.path),
                      caption: _messageController.text.trim().isNotEmpty
                          ? _messageController.text.trim()
                          : null,
                    ),
                  );
            }
          } else {
            // Multiple images - for now, send as normal images
            // TODO: Implement multiple reply images if needed
            final imageFiles = images.map((image) => File(image.path)).toList();
            context.read<ChatDetailBloc>().add(
                  SendMultipleImageMessages(
                    chatId: widget.chatId,
                    receiverId: state.otherUser!.id,
                    imageFiles: imageFiles,
                    caption: _messageController.text.trim().isNotEmpty
                        ? _messageController.text.trim()
                        : null,
                  ),
                );
          }
          _messageController.clear();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking images: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteDialog(Message message) {
    print('Showing delete dialog for message: ${message.id}');

    // Get the bloc reference before showing dialog
    final chatDetailBloc = context.read<ChatDetailBloc>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('User confirmed deletion for message: ${message.id}');
                Navigator.of(dialogContext).pop();

                // Use the stored bloc reference directly
                chatDetailBloc.add(
                  DeleteMessage(
                    chatId: widget.chatId,
                    messageId: message.id,
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFullSizeImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: AppColors.buttonPrimary),
            title: const Text(
              'Image',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: Colors.white,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.error,
                      color: Colors.white,
                      size: 64,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardGradientStart,
        automaticallyImplyLeading: false,
        title: BlocBuilder<ChatDetailBloc, ChatDetailState>(
          builder: (context, state) {
            if (state is ChatDetailLoaded && state.otherUser != null) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: state.otherUser!.photoUrl != null
                        ? NetworkImage(state.otherUser!.photoUrl!)
                        : null,
                    child: state.otherUser!.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.otherUser!.name,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Online',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const Text('Chat');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.buttonPrimary,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatDetailBloc, ChatDetailState>(
              listener: (context, state) {
                if (state is ChatDetailSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } else if (state is ChatDetailError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ChatDetailLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ChatDetailError) {
                  return Center(child: Text(state.message));
                } else if (state is ChatDetailLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  return _buildMessagesList(context, state.messages);
                }
                return const Center(child: Text('No messages yet'));
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessagesList(BuildContext context, List<Message> messages) {
    final currentUserId = context.read<ChatDetailBloc>().currentUserId;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId == currentUserId;

        return GestureDetector(
          onLongPress: () {
            if (!message.deleted) {
              _showMessageOptions(message);
            }
          },
          child: _buildMessageBubble(context, message, isMe),
        );
      },
    );
  }

  void _showMessageOptions(Message message) {
    final isMe =
        message.senderId == context.read<ChatDetailBloc>().currentUserId;

    // Get the bloc reference before showing the bottom sheet
    final chatDetailBloc = context.read<ChatDetailBloc>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext bottomSheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: Colors.blue),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                print('Setting reply message: ${message.id} - ${message.text}');
                chatDetailBloc.add(SetReplyMessage(message));
              },
            ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteDialog(message);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, Message message, bool isMe) {
    // Debug print to check reply data
    if (message.replyData != null) {
      print('Message ${message.id} has reply data: ${message.replyData!.text}');
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.deleted
                    ? Colors.grey[300]
                    : (isMe ? AppColors.buttonPrimary : Colors.grey[200]),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reply preview
                  if (message.replyData != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          left: BorderSide(
                            color: isMe ? Colors.white54 : Colors.grey[400]!,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.reply,
                                size: 14,
                                color: isMe ? Colors.white70 : Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                message.replyData!.senderName,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isMe ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          if (message.replyData!.type == MessageType.image)
                            Row(
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 12,
                                  color:
                                      isMe ? Colors.white70 : Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Photo',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: isMe
                                        ? Colors.white70
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              message.replyData!.text,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  if (message.type == MessageType.booking)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.white24 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Booking Request',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (message.type == MessageType.image &&
                      message.imageUrl != null &&
                      !message.deleted)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () => _showFullSizeImage(message.imageUrl!),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                message.imageUrl!,
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.error),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(
                                  Icons.fullscreen,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Text(
                    message.deleted ? 'This message was deleted' : message.text,
                    style: GoogleFonts.poppins(
                      color: message.deleted
                          ? Colors.grey[600]
                          : (isMe ? Colors.white : Colors.black87),
                      fontSize: 14,
                      fontStyle:
                          message.deleted ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTime(message.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    Icon(
                      message.read ? Icons.done_all : Icons.done,
                      size: 16,
                      color: message.read ? Colors.blue : Colors.grey[600],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return BlocBuilder<ChatDetailBloc, ChatDetailState>(
      builder: (context, state) {
        Message? replyMessage;
        if (state is ChatDetailLoaded) {
          replyMessage = state.replyMessage;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 50, 50, 50),
            boxShadow: [
              BoxShadow(
                color:
                    const Color.fromARGB(255, 170, 170, 170).withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Reply preview
                if (replyMessage != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          color: AppColors.buttonPrimary,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.reply,
                                    size: 16,
                                    color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Replying to ${replyMessage.senderId == context.read<ChatDetailBloc>().currentUserId ? 'yourself' : 'message'}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (replyMessage.type == MessageType.image)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.image,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Photo',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Text(
                                  replyMessage.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 20,
                          ),
                          onPressed: () {
                            context
                                .read<ChatDetailBloc>()
                                .add(ClearReplyMessage());
                          },
                        ),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo_library,
                          color: AppColors.buttonPrimary),
                      onPressed: _pickAndSendImage,
                      tooltip: 'Send Images',
                    ),
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(
                          maxHeight: 120, // Limit maximum height
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: replyMessage != null
                                ? 'Reply to message...'
                                : 'Type a message...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          maxLines: 5, // Limit to 5 lines maximum
                          minLines: 1, // Start with 1 line
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.buttonPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send,
                            color: Colors.white, size: 20),
                        onPressed: () {
                          final state = context.read<ChatDetailBloc>().state;
                          if (state is ChatDetailLoaded) {
                            final text = _messageController.text.trim();
                            if (text.isNotEmpty && state.otherUser != null) {
                              if (replyMessage != null) {
                                // Send reply message
                                context.read<ChatDetailBloc>().add(
                                      SendReplyMessage(
                                        chatId: widget.chatId,
                                        receiverId: state.otherUser!.id,
                                        text: text,
                                        replyToMessage: replyMessage,
                                      ),
                                    );
                                // Clear reply after sending
                                context
                                    .read<ChatDetailBloc>()
                                    .add(ClearReplyMessage());
                              } else {
                                // Send normal message
                                context.read<ChatDetailBloc>().add(
                                      SendMessage(
                                        chatId: widget.chatId,
                                        receiverId: state.otherUser!.id,
                                        text: text,
                                      ),
                                    );
                              }
                              _messageController.clear();
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(time.year, time.month, time.day);

    // Convert to 12-hour format
    final hour =
        time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final timeString =
        '${hour}:${time.minute.toString().padLeft(2, '0')} $period';

    if (messageDate == today) {
      return timeString;
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday $timeString';
    } else {
      return '${time.day}/${time.month} $timeString';
    }
  }
}
