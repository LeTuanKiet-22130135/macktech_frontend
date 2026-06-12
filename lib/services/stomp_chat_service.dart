import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dio_client.dart';
import 'session_service.dart';

/// Service for Agent-Customer live chat over WebSocket using STOMP.
///
/// Uses `ticketId` as the `sessionId` for topic subscriptions.
class StompChatService {
  StompClient? _stompClient;
  final String sessionId;
  final String senderType; // 'user' or 'agent'
  final String senderId;

  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  /// Stream of incoming messages from the STOMP topic.
  Stream<Map<String, dynamic>> get messages => _messageController.stream;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  StompChatService({
    required this.sessionId,
    required this.senderType,
    required this.senderId,
  });

  /// Connect to the WebSocket server and subscribe to the topic.
  Future<void> connect() async {
    final token = await SessionService.getToken();

    _stompClient = StompClient(
      config: StompConfig.sockJS(
        url: '${DioClient.baseUrl}/ws', // SockJS uses HTTP URL
        stompConnectHeaders: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        webSocketConnectHeaders: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onWebSocketError: (error) {
          debugPrint('StompChatService WebSocket error: $error');
        },
        onStompError: (frame) {
          debugPrint('StompChatService STOMP error: ${frame.body}');
        },
        // Reconnect automatically
        reconnectDelay: const Duration(seconds: 5),
      ),
    );

    _stompClient!.activate();
  }

  void _onConnect(StompFrame frame) {
    debugPrint('StompChatService connected to /topic/messages/$sessionId');
    _isConnected = true;

    // Subscribe to the topic for this session
    _stompClient!.subscribe(
      destination: '/topic/messages/$sessionId',
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!) as Map<String, dynamic>;
            debugPrint('StompChatService received: $data');
            _messageController.add(data);
          } catch (e) {
            debugPrint('StompChatService parse error: $e');
          }
        }
      },
    );
  }

  void _onDisconnect(StompFrame frame) {
    debugPrint('StompChatService disconnected');
    _isConnected = false;
  }

  /// Send a message to the chat session.
  void sendMessage(String text) {
    if (_stompClient == null || !_isConnected) {
      debugPrint('StompChatService: Not connected, cannot send message');
      return;
    }

    final payload = jsonEncode({
      'sessionId': sessionId,
      'senderType': senderType,
      'senderId': senderId,
      'textPayload': text,
    });

    _stompClient!.send(destination: '/app/chat.sendMessage', body: payload);

    debugPrint('StompChatService sent: $payload');
  }

  /// Disconnect and clean up resources.
  void dispose() {
    _stompClient?.deactivate();
    _messageController.close();
    _isConnected = false;
    debugPrint('StompChatService disposed');
  }
}
