class AddReview {
  String? id;
  String? name;
  String? review;

  AddReview({
    this.id,
    this.name,
    this.review,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'review': review,
    };
  }
}
