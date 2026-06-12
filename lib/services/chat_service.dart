import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dio_client.dart';
import 'session_service.dart';

/// Service for streaming AI chatbot responses via NDJSON (Google Gemini).
class ChatService {
  // ── Thinking-token open/close pairs for Gemma 4 ──
  // The model wraps internal reasoning in these special tokens.
  // We silently strip them so only the polished answer reaches the user.
  static const List<String> _thinkOpenTags = [
    '<|think|>',
    '<|channel>',
  ];
  static const List<String> _thinkCloseTags = [
    '</think>',
    '<channel|>',
  ];

  /// Streams the AI chatbot response for the given [message].
  ///
  /// Connects to the backend's `/api/chat/stream` NDJSON endpoint and yields
  /// text chunks as they arrive. Internal reasoning blocks emitted by Gemma 4
  /// (wrapped in think / channel tags) are silently filtered out.
  static Stream<String> streamChat(String message) async* {
    final uri = Uri.parse(
      '${DioClient.baseUrl}/api/chat/stream?message=${Uri.encodeQueryComponent(message)}',
    );

    final request = http.Request('GET', uri);
    request.headers['Accept'] = 'application/x-ndjson';
    request.headers['Cache-Control'] = 'no-cache';

    // Attach JWT for authenticated chat saving & order tracking
    final token = await SessionService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final client = http.Client();

    try {
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception('Chat API returned status ${response.statusCode}');
      }

      // Stateful flag – tracks whether we are inside a thinking block
      // across chunk boundaries.
      bool insideThinking = false;

      // Read the NDJSON stream line by line
      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {

        if (chunk.trim().isEmpty) continue;

        // Skip [DONE] signals if backend still sends them
        if (chunk.trim() == '[DONE]') continue;

        try {
          // The backend sends NDJSON: {"content": "chunk_text"}
          final Map<String, dynamic> jsonResponse = jsonDecode(chunk);
          if (jsonResponse.containsKey('content')) {
            final raw = jsonResponse['content'] as String;
            final visible = _filterThinking(raw, insideThinking);
            insideThinking = visible.nowInside;
            if (visible.text.isNotEmpty) {
              yield visible.text;
            }
          }
        } catch (e) {
          // Fallback just in case backend sends raw text
          final visible = _filterThinking(chunk, insideThinking);
          insideThinking = visible.nowInside;
          if (visible.text.isNotEmpty) {
            yield visible.text;
          }
        }
      }
    } catch (e) {
      debugPrint('ChatService.streamChat error: $e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Filters thinking-mode tokens from [content].
  ///
  /// Walks through [content] character-by-character, toggling an
  /// "inside thinking" flag whenever an open or close tag is found.
  /// Returns only the user-visible portion together with the updated flag
  /// so the caller can carry state across chunks.
  static _FilterResult _filterThinking(String content, bool insideThinking) {
    final buffer = StringBuffer();
    String remaining = content;

    while (remaining.isNotEmpty) {
      if (insideThinking) {
        // Look for the earliest close tag
        int bestIdx = -1;
        int bestLen = 0;
        for (final tag in _thinkCloseTags) {
          final idx = remaining.indexOf(tag);
          if (idx != -1 && (bestIdx == -1 || idx < bestIdx)) {
            bestIdx = idx;
            bestLen = tag.length;
          }
        }
        if (bestIdx != -1) {
          // Skip everything up to and including the close tag
          remaining = remaining.substring(bestIdx + bestLen);
          insideThinking = false;
        } else {
          // Still inside thinking – discard entire remaining text
          remaining = '';
        }
      } else {
        // Look for the earliest open tag
        int bestIdx = -1;
        int bestLen = 0;
        for (final tag in _thinkOpenTags) {
          final idx = remaining.indexOf(tag);
          if (idx != -1 && (bestIdx == -1 || idx < bestIdx)) {
            bestIdx = idx;
            bestLen = tag.length;
          }
        }
        if (bestIdx != -1) {
          // Yield everything before the open tag
          buffer.write(remaining.substring(0, bestIdx));
          remaining = remaining.substring(bestIdx + bestLen);
          insideThinking = true;
        } else {
          // No tags found – everything is visible
          buffer.write(remaining);
          remaining = '';
        }
      }
    }

    return _FilterResult(buffer.toString(), insideThinking);
  }

  /// Retrieves all chat sessions for the authenticated user.
  static Future<List<dynamic>> getChatSessions() async {
    try {
      final response = await DioClient.instance.get('/api/chat/sessions');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting chat sessions: $e');
      return [];
    }
  }

  /// Retrieves all messages for a specific chat session.
  static Future<List<dynamic>> getSessionMessages(String sessionId) async {
    try {
      final response = await DioClient.instance.get('/api/chat/sessions/$sessionId/messages');
      if (response.statusCode == 200) {
        return response.data as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Error getting session messages: $e');
      return [];
    }
  }
}

/// Holds the result of filtering thinking tokens from a text chunk.
class _FilterResult {
  /// The user-visible text with thinking blocks removed.
  final String text;

  /// Whether we are still inside a thinking block after processing this chunk.
  final bool nowInside;

  const _FilterResult(this.text, this.nowInside);
}
