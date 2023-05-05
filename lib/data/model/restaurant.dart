import 'package:equatable/equatable.dart';

import 'menu.dart';
import 'review.dart';

class Restaurant extends Equatable {
  final String? id;
  final String? name;
  final String? description;
  final String? pictureId;
  final String? city;
  final String? address;
  final num? rating;
  final Menu? menus;
  final List<Review>? customerReviews;

  const Restaurant({
    this.id,
    this.name,
    this.description,
    this.pictureId,
    this.city,
    this.address,
    this.rating,
    this.menus,
    this.customerReviews,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureId: json['pictureId'],
      city: json['city'],
      address: json['address'],
      rating: json['rating'],
      menus: json['menus'] != null ? Menu.fromJson(json['menus']) : null,
      customerReviews: json['customerReviews'] != null
          ? List<Review>.from((json['customerReviews'] as List<dynamic>)
              .map((e) => Review.fromJson(e))
              .toList())
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'pictureId': pictureId,
      'city': city,
      'rating': rating,
    };
  }

  @override
  String toString() {
    return 'Restaurant(id: $id, name: $name, description: $description, pictureId: $pictureId, city: $city, address: $address, rating: $rating, menus: $menus, customerReviews: $customerReviews)';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        pictureId,
        city,
        address,
        rating,
        menus,
        customerReviews
      ];
}
