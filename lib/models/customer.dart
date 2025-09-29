class Customer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? profileImage;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic> defaultAddress;
  final List<Map<String, dynamic>> addresses;
  final int totalOrders;
  final double totalSpent;
  final double averageOrderValue;
  final List<String> preferences;
  final String? notes;

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.profileImage,
    required this.dateJoined,
    this.lastLogin,
    required this.isActive,
    required this.defaultAddress,
    required this.addresses,
    required this.totalOrders,
    required this.totalSpent,
    required this.averageOrderValue,
    required this.preferences,
    this.notes,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'],
      dateJoined: DateTime.parse(json['dateJoined'] ?? DateTime.now().toIso8601String()),
      lastLogin: json['lastLogin'] != null 
          ? DateTime.parse(json['lastLogin']) 
          : null,
      isActive: json['isActive'] ?? true,
      defaultAddress: Map<String, dynamic>.from(json['defaultAddress'] ?? {}),
      addresses: List<Map<String, dynamic>>.from(json['addresses'] ?? []),
      totalOrders: json['totalOrders'] ?? 0,
      totalSpent: (json['totalSpent'] ?? 0.0).toDouble(),
      averageOrderValue: (json['averageOrderValue'] ?? 0.0).toDouble(),
      preferences: List<String>.from(json['preferences'] ?? []),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'dateJoined': dateJoined.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
      'defaultAddress': defaultAddress,
      'addresses': addresses,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'averageOrderValue': averageOrderValue,
      'preferences': preferences,
      'notes': notes,
    };
  }

  Customer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImage,
    DateTime? dateJoined,
    DateTime? lastLogin,
    bool? isActive,
    Map<String, dynamic>? defaultAddress,
    List<Map<String, dynamic>>? addresses,
    int? totalOrders,
    double? totalSpent,
    double? averageOrderValue,
    List<String>? preferences,
    String? notes,
  }) {
    return Customer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      dateJoined: dateJoined ?? this.dateJoined,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      defaultAddress: defaultAddress ?? this.defaultAddress,
      addresses: addresses ?? this.addresses,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      averageOrderValue: averageOrderValue ?? this.averageOrderValue,
      preferences: preferences ?? this.preferences,
      notes: notes ?? this.notes,
    );
  }

  // Helper methods
  String get fullName => '$firstName $lastName';
  String get formattedTotalSpent => '${totalSpent.toStringAsFixed(0)} сум';
  String get formattedAverageOrderValue => '${averageOrderValue.toStringAsFixed(0)} сум';
  bool get isNewCustomer => DateTime.now().difference(dateJoined).inDays <= 30;
  bool get isHighValueCustomer => totalSpent > 500;
  String get customerTier {
    if (totalSpent > 1000) return 'Gold';
    if (totalSpent > 500) return 'Silver';
    if (totalSpent > 100) return 'Bronze';
    return 'New';
  }
}