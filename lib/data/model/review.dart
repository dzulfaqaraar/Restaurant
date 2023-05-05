class Review {
  String? name;
  String? review;
  String? date;

  Review({
    this.name,
    this.review,
    this.date,
  });

  Review.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    review = json['review'];
    date = json['date'];
  }
}
