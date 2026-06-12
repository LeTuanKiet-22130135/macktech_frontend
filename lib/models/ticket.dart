class TicketAttachment {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  TicketAttachment({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory TicketAttachment.fromJson(Map<String, dynamic> json) {
    return TicketAttachment(
      id: json['id'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}

class Ticket {
  final String id;
  final String ticketNumber;
  final String type;
  final String issueDescription;
  final String status;
  final List<TicketAttachment> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Ticket({
    required this.id,
    required this.ticketNumber,
    required this.type,
    required this.issueDescription,
    required this.status,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'] as String? ?? '',
      ticketNumber: json['ticketNumber'] as String? ?? '',
      type: json['type'] as String? ?? '',
      issueDescription: json['issueDescription'] as String? ?? '',
      status: json['status'] as String? ?? 'Open',
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => TicketAttachment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }
}
