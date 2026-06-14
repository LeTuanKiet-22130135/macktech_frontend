class PromoCode {
  final String id;
  final String code;
  final String discountType; // 'percentage' or 'fixed'
  final double discountValue;
  final double minimumOrderValue;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minimumOrderValue,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.usedCount = 0,
    required this.isActive,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      discountType: json['discountType'] as String? ?? 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minimumOrderValue: (json['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      validFrom: json['validFrom'] != null ? DateTime.parse(json['validFrom'].toString()) : null,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'].toString()) : null,
      usageLimit: json['usageLimit'] as int?,
      usedCount: json['timesUsed'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'minimumOrderValue': minimumOrderValue,
      if (validFrom != null) 'validFrom': validFrom!.toIso8601String(),
      if (validUntil != null) 'validUntil': validUntil!.toIso8601String(),
      if (usageLimit != null) 'usageLimit': usageLimit,
      'isActive': isActive,
    };
  }
}
