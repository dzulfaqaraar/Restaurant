import 'drink.dart';
import 'food.dart';

class Menu {
  List<Food>? foods;
  List<Drink>? drinks;

  Menu({this.foods, this.drinks});

  Menu.fromJson(Map<String, dynamic> json) {
    if (json['foods'] != null) {
      foods = <Food>[];
      json['foods'].forEach((v) {
        foods!.add(Food.fromJson(v));
      });
    }
    if (json['drinks'] != null) {
      drinks = <Drink>[];
      json['drinks'].forEach((v) {
        drinks!.add(Drink.fromJson(v));
      });
    }
  }
}
