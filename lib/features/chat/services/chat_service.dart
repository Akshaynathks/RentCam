import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rent_cam/features/chat/model/chat_models.dart';
import 'package:rent_cam/features/home/services/profile_photo.dart';
import 'dart:io';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  // Create or get existing chat
  Future<String> getOrCreateChat(String otherUserId) async {
    final currentUserId = _auth.currentUser!.uid;
    final participants = [currentUserId, otherUserId]..sort();
    final chatId = participants.join('_');

    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        // Create new chat with initial data
        await _firestore.collection('chats').doc(chatId).set({
          'participants': participants,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastMessage': null, // Initialize lastMessage as null
        });
      }

      return chatId;
    } catch (e) {
      print('Error in getOrCreateChat: $e');
      rethrow;
    }
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String text,
    MessageType type = MessageType.text,
    String? bookingId,
    String? imageUrl,
  }) async {
    try {
      final currentUserId = _auth.currentUser!.uid;
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      final message = Message(
        id: messageRef.id,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        type: type,
        bookingId: bookingId,
        imageUrl: imageUrl,
      );

      // Batch write to update last message and add new message
      final batch = _firestore.batch();

      // Add the new message
      batch.set(messageRef, message.toMap());

      // Update the chat document with the last message
      batch.update(_firestore.collection('chats').doc(chatId), {
        'lastMessage': message.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }

  // Send a reply message
  Future<void> sendReplyMessage({
    required String chatId,
    required String receiverId,
    required String text,
    required Message replyToMessage,
    MessageType type = MessageType.text,
    String? bookingId,
    String? imageUrl,
  }) async {
    try {
      print('=== SEND REPLY MESSAGE START ===');
      print('Chat ID: $chatId');
      print('Receiver ID: $receiverId');
      print('Text: $text');
      print('Reply to message ID: ${replyToMessage.id}');
      print('Reply to message text: ${replyToMessage.text}');

      final currentUserId = _auth.currentUser!.uid;
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc();

      // Get sender name for reply data
      final senderInfo = await getUserInfo(replyToMessage.senderId);
      print('Sender info for reply: ${senderInfo.name}');

      // Create reply data
      final replyData = ReplyData(
        messageId: replyToMessage.id,
        senderName: senderInfo.name,
        text: replyToMessage.deleted
            ? 'This message was deleted'
            : replyToMessage.text,
        type: replyToMessage.type,
        imageUrl: replyToMessage.imageUrl,
        timestamp: replyToMessage.timestamp,
      );
      print('Reply data created: ${replyData.toMap()}');

      final message = Message(
        id: messageRef.id,
        chatId: chatId,
        senderId: currentUserId,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        type: type,
        bookingId: bookingId,
        imageUrl: imageUrl,
        replyTo: replyToMessage.id,
        replyData: replyData,
      );
      print('Message created with reply data: ${message.toMap()}');

      // Batch write to update last message and add new message
      final batch = _firestore.batch();

      // Add the new message
      batch.set(messageRef, message.toMap());

      // Update the chat document with the last message
      batch.update(_firestore.collection('chats').doc(chatId), {
        'lastMessage': message.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('=== SEND REPLY MESSAGE COMPLETED ===');
    } catch (e) {
      print('❌ Error in sendReplyMessage: $e');
      print('=== SEND REPLY MESSAGE FAILED ===');
      rethrow;
    }
  }

  // Send an image message
  Future<void> sendImageMessage({
    required String chatId,
    required String receiverId,
    required File imageFile,
    String? caption,
  }) async {
    try {
      // Upload image to Cloudinary
      final imageUrl = await CloudinaryService.uploadImage(imageFile);
      if (imageUrl == null) {
        throw Exception('Failed to upload image');
      }

      // Send the image message
      await sendMessage(
        chatId: chatId,
        receiverId: receiverId,
        text: caption ?? 'Image',
        type: MessageType.image,
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error in sendImageMessage: $e');
      rethrow;
    }
  }

  // Send multiple image messages
  Future<void> sendMultipleImageMessages({
    required String chatId,
    required String receiverId,
    required List<File> imageFiles,
    String? caption,
  }) async {
    try {
      print('Sending ${imageFiles.length} images...');

      for (int i = 0; i < imageFiles.length; i++) {
        final imageFile = imageFiles[i];
        print('Uploading image ${i + 1}/${imageFiles.length}');

        // Upload image to Cloudinary
        final imageUrl = await CloudinaryService.uploadImage(imageFile);
        if (imageUrl == null) {
          print('Failed to upload image ${i + 1}');
          continue;
        }

        // Send the image message
        await sendMessage(
          chatId: chatId,
          receiverId: receiverId,
          text: caption ?? 'Image ${i + 1}',
          type: MessageType.image,
          imageUrl: imageUrl,
        );

        print('Successfully sent image ${i + 1}');
      }

      print('All images sent successfully');
    } catch (e) {
      print('Error in sendMultipleImageMessages: $e');
      rethrow;
    }
  }

  // Delete a message (soft delete)
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      print('=== DELETE MESSAGE PROCESS START ===');
      print('Deleting message: $messageId from chat: $chatId');

      final messageRef = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      // Check if message exists first
      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        print('❌ Message does not exist: $messageId');
        throw Exception('Message not found');
      }

      print('✅ Message found, updating to deleted state...');
      print('Message data before deletion: ${messageDoc.data()}');

      // Update the message to mark it as deleted
      await messageRef.update({
        'deleted': true,
        'text': 'This message was deleted',
      });

      print('✅ Message marked as deleted successfully');

      // Update the last message in chat if this was the last message
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final lastMessage = chatDoc.data()?['lastMessage'];
        print('Chat last message: $lastMessage');

        if (lastMessage != null && lastMessage['id'] == messageId) {
          print('🔄 This was the last message, updating chat document...');

          // Get all messages and find the most recent non-deleted one
          // This avoids the complex query that requires an index
          final allMessages = await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .get();

          print('Found ${allMessages.docs.length} total messages');

          // Find the most recent non-deleted message
          Message? newLastMessage;
          for (final doc in allMessages.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            final message = Message.fromMap(data);

            if (!message.deleted) {
              newLastMessage = message;
              break;
            }
          }

          if (newLastMessage != null) {
            await _firestore.collection('chats').doc(chatId).update({
              'lastMessage': newLastMessage.toMap(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('✅ Updated chat with new last message: ${newLastMessage.id}');
          } else {
            // No non-deleted messages left, clear the last message
            await _firestore.collection('chats').doc(chatId).update({
              'lastMessage': null,
              'updatedAt': FieldValue.serverTimestamp(),
            });
            print('✅ Cleared last message from chat');
          }
        } else {
          print('ℹ️ This was not the last message, no chat update needed');
        }
      } else {
        print('❌ Chat document does not exist');
      }

      print('=== DELETE MESSAGE PROCESS COMPLETED ===');
    } catch (e) {
      print('❌ Error in deleteMessage: $e');
      print('=== DELETE MESSAGE PROCESS FAILED ===');
      rethrow;
    }
  }

  // Get chat stream
  Stream<List<Message>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id; // Ensure ID is included
          final message = Message.fromMap(data);

          // Debug print for messages with reply data
          if (message.replyData != null) {
            print('Loaded message with reply data: ${message.id}');
            print('Reply data: ${message.replyData!.toMap()}');
          }

          return message;
        }).toList();

        return messages;
      } catch (e) {
        print('Error parsing messages: $e');
        return <Message>[];
      }
    });
  }

  // Get user chats - Fixed to handle the actual Firebase structure
  Stream<List<Chat>> getUserChats() {
    try {
      final currentUserId = _auth.currentUser!.uid;

      return _firestore
          .collection('chats')
          .where('participants', arrayContains: currentUserId)
          .snapshots()
          .map((snapshot) {
        try {
          final chats = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Ensure ID is included
            return Chat.fromMap(data);
          }).toList();

          // Sort chats by updatedAt in descending order (most recent first)
          chats.sort((a, b) {
            final aTime = a.updatedAt ?? a.createdAt;
            final bTime = b.updatedAt ?? b.createdAt;
            return bTime.compareTo(aTime);
          });

          return chats;
        } catch (e) {
          print('Error parsing chat: $e');
          return <Chat>[];
        }
      });
    } catch (e) {
      print('Error in getUserChats: $e');
      rethrow;
    }
  }

  // Get user info - Fixed to handle missing user data
  Future<ChatUser> getUserInfo(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        // Return a default user if the user document doesn't exist
        return ChatUser(
          id: userId,
          name: 'Unknown User',
          email: 'unknown@example.com',
          photoUrl: null,
          lastSeen: DateTime.now(),
        );
      }

      final data = doc.data()!;
      data['id'] = userId; // Ensure ID is included

      // Map imageUrl to photoUrl for ChatUser model
      if (data['imageUrl'] != null) {
        data['photoUrl'] = data['imageUrl'];
      }

      // Handle missing lastSeen field
      if (data['lastSeen'] == null) {
        data['lastSeen'] = Timestamp.fromDate(DateTime.now());
      }

      return ChatUser.fromMap(data);
    } catch (e) {
      print('Error getting user info for $userId: $e');
      // Return a default user on error
      return ChatUser(
        id: userId,
        name: 'Unknown User',
        email: 'unknown@example.com',
        photoUrl: null,
        lastSeen: DateTime.now(),
      );
    }
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    try {
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: currentUserId)
          .where('read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }

      if (unreadMessages.docs.isNotEmpty) {
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // Delete chat (optional)
  Future<void> deleteChat(String chatId) async {
    try {
      final chatRef = _firestore.collection('chats').doc(chatId);
      final messagesRef = chatRef.collection('messages');

      // Get all messages
      final messages = await messagesRef.get();

      // Delete all messages in a batch
      final batch = _firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Delete the chat document
      batch.delete(chatRef);

      await batch.commit();
    } catch (e) {
      print('Error deleting chat: $e');
      rethrow;
    }
  }
}
