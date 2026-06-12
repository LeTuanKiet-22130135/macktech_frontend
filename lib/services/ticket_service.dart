import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/ticket.dart';
import 'dio_client.dart';
import 'session_service.dart';

class TicketService {
  /// Create a new support ticket.
  /// Uploads optional image to Firebase Storage and submits JSON to the backend.
  static Future<Ticket?> createTicket(
    String type,
    String issueDescription, {
    File? image,
  }) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      List<String> imageUrls = [];

      // 1. Upload image to Firebase Storage if provided
      if (image != null) {
        String fileName =
            'ticket_${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('support_ticket')
            .child(fileName);

        await storageRef.putFile(
          image,
          SettableMetadata(
            contentType: 'image/jpeg',
          ), // Adjust if supporting other types
        );

        final downloadUrl = await storageRef.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // 2. Send JSON request to the backend
      final Map<String, dynamic> ticketData = {
        'type': type,
        'issueDescription': issueDescription,
        'imageUrls': imageUrls,
      };

      final response = await DioClient.instance.post(
        '/api/tickets',
        data: ticketData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Ticket.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      rethrow;
    }
  }

  /// Fetch all tickets for the authenticated user.
  static Future<List<Ticket>> getUserTickets() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.get('/api/tickets');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Ticket.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting user tickets: $e');
      return [];
    }
  }

  /// Fetch details of a specific ticket.
  static Future<Ticket?> getTicketDetails(String ticketId) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.get('/api/tickets/$ticketId');
      if (response.statusCode == 200) {
        return Ticket.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting ticket details: $e');
      return null;
    }
  }

  // ==========================================
  // ADMIN / AGENT ENDPOINTS
  // ==========================================

  /// Fetch all tickets across all users (Admin/Agent only).
  static Future<List<Ticket>> getAllTickets() async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.get('/api/tickets/admin');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Ticket.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error getting all tickets: $e');
      return [];
    }
  }

  /// Update the status of a specific ticket (Admin/Agent only).
  static Future<Ticket?> updateTicketStatus(String ticketId, String status) async {
    try {
      final token = await SessionService.getToken();
      if (token == null) throw Exception("Not authenticated");

      final response = await DioClient.instance.patch(
        '/api/tickets/admin/$ticketId/status',
        data: {'status': status},
      );
      
      if (response.statusCode == 200) {
        return Ticket.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error updating ticket status: $e');
      rethrow;
    }
  }
}
