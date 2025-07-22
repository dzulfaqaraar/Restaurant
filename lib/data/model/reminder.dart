class Reminder {
  final int? id;
  final String restaurantId;
  final String restaurantName;
  final int hour;
  final int minute;
  final bool isActive;
  final String? notificationMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Reminder({
    this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.hour,
    required this.minute,
    this.isActive = true,
    this.notificationMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'restaurant_name': restaurantName,
      'hour': hour,
      'minute': minute,
      'is_active': isActive ? 1 : 0,
      'notification_message': notificationMessage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      restaurantId: map['restaurant_id'],
      restaurantName: map['restaurant_name'],
      hour: map['hour'],
      minute: map['minute'],
      isActive: map['is_active'] == 1,
      notificationMessage: map['notification_message'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Reminder copyWith({
    int? id,
    String? restaurantId,
    String? restaurantName,
    int? hour,
    int? minute,
    bool? isActive,
    String? notificationMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isActive: isActive ?? this.isActive,
      notificationMessage: notificationMessage ?? this.notificationMessage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get timeString {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Reminder{id: $id, restaurantId: $restaurantId, restaurantName: $restaurantName, time: $timeString, isActive: $isActive}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.restaurantId == restaurantId &&
        other.hour == hour &&
        other.minute == minute;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        restaurantId.hashCode ^
        hour.hashCode ^
        minute.hashCode;
  }
}