import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'session_service.dart';

/// Handles client-side tracking of user interactions directly to Recombee 
/// using the Public Token and HMAC-SHA1 signing.
class RecombeeTrackingService {
  static final _dio = Dio();

  /// Tracks a 'DetailView' interaction when a user views a product's details.
  static Future<void> trackDetailView(String itemId, {String? recommId}) async {
    try {
      final dbId = dotenv.env['RECOMBEE_DATABASE_ID'];
      final token = dotenv.env['RECOMBEE_PUBLIC_TOKEN'];
      final region = dotenv.env['RECOMBEE_REGION'];

      if (dbId == null || token == null || token.isEmpty || dbId.isEmpty) {
        return; // Missing config
      }

      final user = await SessionService.getUser();
      final sessionUserId = user['id'];
      final userId = (sessionUserId == null || sessionUserId.isEmpty) 
          ? 'anonymous_frontend_user' 
          : sessionUserId;

      // Recombee expects unix timestamp in seconds (can be decimal, but integer is fine)
      final unixTimestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor();
      
      // Base URI path
      final uriPath = '/$dbId/detailviews/';
      
      // We will send the data in the JSON body instead of the URL query string
      final requestBody = {
        'itemId': itemId,
        'userId': userId,
        'timestamp': unixTimestamp,
        'cascadeCreate': true,
        if (recommId != null) 'recommId': recommId,
      };
      
      // The frontend_timestamp must be appended to the URI before signing
      final frontendTimestamp = unixTimestamp;
      final uriToSign = '$uriPath?frontend_timestamp=$frontendTimestamp';

      // Compute HMAC-SHA1 signature
      final key = utf8.encode(token);
      final bytes = utf8.encode(uriToSign);
      final hmacSha1 = Hmac(sha1, key);
      final digest = hmacSha1.convert(bytes);
      final signature = digest.toString();

      // Construct final URL
      final baseUrl = region != null && region.isNotEmpty 
          ? 'https://client-rapi-$region.recombee.com'
          : 'https://client-rapi.recombee.com';
          
      final finalUrl = '$baseUrl$uriToSign&frontend_sign=$signature';

      // Send the tracking request with JSON body
      await _dio.post(
        finalUrl,
        data: requestBody,
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );
    } catch (e) {
      print('❌ Failed to track Recombee interaction: $e');
    }
  }

  static Future<void> trackAddBookmark(String itemId) async {
    await _sendInteraction('bookmarks/', 'POST', itemId);
  }

  static Future<void> trackDeleteBookmark(String itemId) async {
    // Delete Bookmark uses the same endpoint, but with DELETE method.
    await _sendInteraction('bookmarks/', 'DELETE', itemId);
  }

  static Future<void> trackAddCartAddition(String itemId, int amount) async {
    await _sendInteraction('cartadditions/', 'POST', itemId, amount: amount);
  }

  static Future<void> trackDeleteCartAddition(String itemId) async {
    await _sendInteraction('cartadditions/', 'DELETE', itemId);
  }

  static Future<void> _sendInteraction(String endpoint, String method, String itemId, {String? recommId, int? amount}) async {
    try {
      final dbId = dotenv.env['RECOMBEE_DATABASE_ID'];
      final token = dotenv.env['RECOMBEE_PUBLIC_TOKEN'];
      final region = dotenv.env['RECOMBEE_REGION'];

      if (dbId == null || token == null || token.isEmpty || dbId.isEmpty) {
        return; // Missing config
      }

      final user = await SessionService.getUser();
      final sessionUserId = user['id'];
      final userId = (sessionUserId == null || sessionUserId.isEmpty) 
          ? 'anonymous_frontend_user' 
          : sessionUserId;

      final unixTimestamp = (DateTime.now().toUtc().millisecondsSinceEpoch / 1000).floor();
      
      final uriPath = '/$dbId/$endpoint';
      
      final requestBody = {
        'itemId': itemId,
        'userId': userId,
        'timestamp': unixTimestamp,
        'cascadeCreate': true,
        if (recommId != null) 'recommId': recommId,
        if (amount != null) 'amount': amount,
      };
      
      final frontendTimestamp = unixTimestamp;
      
      // For DELETE, Recombee might require itemId and userId in query params. 
      // The Dart Recombee client adds them to query params for DELETE, 
      // but let's send them in query params if it's DELETE just to be safe,
      // or we can just pass them as query params in the URI to sign.
      String uriToSign;
      if (method == 'DELETE') {
        uriToSign = '$uriPath?frontend_timestamp=$frontendTimestamp&itemId=$itemId&userId=$userId';
      } else {
        uriToSign = '$uriPath?frontend_timestamp=$frontendTimestamp';
      }

      final key = utf8.encode(token);
      final bytes = utf8.encode(uriToSign);
      final hmacSha1 = Hmac(sha1, key);
      final digest = hmacSha1.convert(bytes);
      final signature = digest.toString();

      final baseUrl = region != null && region.isNotEmpty 
          ? 'https://client-rapi-$region.recombee.com'
          : 'https://client-rapi.recombee.com';
          
      final finalUrl = '$baseUrl$uriToSign&frontend_sign=$signature';

      if (method == 'DELETE') {
        await _dio.delete(
          finalUrl,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
      } else {
        await _dio.post(
          finalUrl,
          data: requestBody,
          options: Options(
            headers: {'Content-Type': 'application/json'},
          ),
        );
      }
    } catch (e) {
      print('❌ Failed to track Recombee interaction ($method $endpoint): $e');
    }
  }
}
