import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, booking, system, image }

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final DateTime lastSeen;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.lastSeen,
  });

  factory ChatUser.fromMap(Map<String, dynamic> map) {
    return ChatUser(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown User',
      email: map['email'] ?? 'unknown@example.com',
      photoUrl: map['photoUrl'] ?? map['imageUrl'],
      lastSeen: map['lastSeen'] != null
          ? (map['lastSeen'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'lastSeen': Timestamp.fromDate(lastSeen),
    };
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String text;
  final DateTime timestamp;
  final MessageType type;
  final String? bookingId;
  final String? imageUrl;
  final bool read;
  final bool deleted;
  final String? replyTo;
  final ReplyData? replyData;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.type = MessageType.text,
    this.bookingId,
    this.imageUrl,
    this.read = false,
    this.deleted = false,
    this.replyTo,
    this.replyData,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      type: _parseMessageType(map['type']),
      bookingId: map['bookingId'],
      imageUrl: map['imageUrl'],
      read: map['read'] ?? false,
      deleted: map['deleted'] ?? false,
      replyTo: map['replyTo'],
      replyData:
          map['replyData'] != null ? ReplyData.fromMap(map['replyData']) : null,
    );
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;

    if (type is String) {
      switch (type.toLowerCase()) {
        case 'booking':
          return MessageType.booking;
        case 'system':
          return MessageType.system;
        case 'image':
          return MessageType.image;
        default:
          return MessageType.text;
      }
    }

    return MessageType.text;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.toString().split('.').last,
      'bookingId': bookingId,
      'imageUrl': imageUrl,
      'read': read,
      'deleted': deleted,
      'replyTo': replyTo,
      'replyData': replyData?.toMap(),
    };
  }
}

class ReplyData {
  final String messageId;
  final String senderName;
  final String text;
  final MessageType type;
  final String? imageUrl;
  final DateTime timestamp;

  ReplyData({
    required this.messageId,
    required this.senderName,
    required this.text,
    required this.type,
    this.imageUrl,
    required this.timestamp,
  });

  factory ReplyData.fromMap(Map<String, dynamic> map) {
    return ReplyData(
      messageId: map['messageId'] ?? '',
      senderName: map['senderName'] ?? 'Unknown',
      text: map['text'] ?? '',
      type: _parseMessageType(map['type']),
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static MessageType _parseMessageType(dynamic type) {
    if (type == null) return MessageType.text;

    if (type is String) {
      switch (type.toLowerCase()) {
        case 'booking':
          return MessageType.booking;
        case 'system':
          return MessageType.system;
        case 'image':
          return MessageType.image;
        default:
          return MessageType.text;
      }
    }

    return MessageType.text;
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'senderName': senderName,
      'text': text,
      'type': type.toString().split('.').last,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class Chat {
  final String id;
  final List<String> participants;
  final Message? lastMessage;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Chat({
    required this.id,
    required this.participants,
    this.lastMessage,
    required this.createdAt,
    this.updatedAt,
  });

  factory Chat.fromMap(Map<String, dynamic> map) {
    Message? lastMessage;
    if (map['lastMessage'] != null) {
      try {
        final lastMessageData = Map<String, dynamic>.from(map['lastMessage']);
        lastMessageData['id'] = lastMessageData['id'] ?? 'temp_id';
        lastMessage = Message.fromMap(lastMessageData);
      } catch (e) {
        print('Error parsing lastMessage: $e');
        print('LastMessage data: ${map['lastMessage']}');
        lastMessage = null; // Set to null if parsing fails
      }
    }

    return Chat(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: lastMessage,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
