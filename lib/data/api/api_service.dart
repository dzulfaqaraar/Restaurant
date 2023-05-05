import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/add_review.dart';
import '../model/restaurant.dart';
import '../model/review.dart';

class ApiService {
  static const _baseUrl = 'https://restaurant-api.dicoding.dev';
  static const list = '$_baseUrl/list';
  static const search = '$_baseUrl/search';
  static const detail = '$_baseUrl/detail';
  static const review = '$_baseUrl/review';

  final http.Client client;
  ApiService({required this.client});

  Future<List<Restaurant>> listRestaurant({String? keywordSearch}) async {
    Uri uri;
    if (keywordSearch == null) {
      uri = Uri.parse(list);
    } else {
      uri = Uri.parse('$search?q=$keywordSearch');
    }

    final response = await client.get(uri);

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false) {
          List<Restaurant> list = (data['restaurants'] as List<dynamic>)
              .map((e) => Restaurant.fromJson(e))
              .toList();
          return list;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load list restaurant');
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<Restaurant?> detailRestaurant(String id) async {
    try {
      final response = await client.get(Uri.parse('$detail/$id'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['error'] == false) {
          return Restaurant.fromJson(data['restaurant']);
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load detail restaurant');
      }
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<List<Review>> reviewRestaurant(AddReview data) async {
    try {
      final response = await client.post(Uri.parse(review), body: data.toJson());

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['error'] == false) {
          List<Review> list = List<Review>.from(
              (data['customerReviews'] as List<dynamic>)
                  .map((e) => Review.fromJson(e))
                  .toList());
          return list;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to submit review');
      }
    } catch (error) {
      return Future.error(error);
    }
  }
}
