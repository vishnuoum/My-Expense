class CategoryAnalyticsDetails {
  String category;
  double totalSpent;
  double percentage;

  CategoryAnalyticsDetails({
    required this.category,
    required this.totalSpent,
    required this.percentage,
  });

  factory CategoryAnalyticsDetails.fromMap(Map<String, dynamic> map) {
    return CategoryAnalyticsDetails(
      category: map["category"],
      totalSpent: map["totalSpent"],
      percentage: map["percentage"],
    );
  }
}
