class Draft {
  int? id;
  double latitude;
  double longitude;
  String videoPaths;
  String selectedLabel;
  String selectedCategory;
  String selectedGenre;
  String experienceDescription;
  String selectedLoveAboutHere;
  String dontLikeAboutHere;
  String selectedaCategory;
  String reviewText;
  int starRating;
  String selectedVisibility;
  String storyTitle;
  String productDescription;

  Draft({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.videoPaths,
    required this.selectedLabel,
    required this.selectedCategory,
    required this.selectedGenre,
    required this.experienceDescription,
    required this.selectedLoveAboutHere,
    required this.dontLikeAboutHere,
    required this.selectedaCategory,
    required this.reviewText,
    required this.starRating,
    required this.selectedVisibility,
    required this.storyTitle,
    required this.productDescription,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'videoPaths': videoPaths,
      'selectedLabel': selectedLabel,
      'selectedCategory': selectedCategory,
      'selectedGenre': selectedGenre,
      'experienceDescription': experienceDescription,
      'selectedLoveAboutHere': selectedLoveAboutHere,
      'dontLikeAboutHere': dontLikeAboutHere,
      'selectedaCategory': selectedaCategory,
      'reviewText': reviewText,
      'starRating': starRating,
      'selectedVisibility': selectedVisibility,
      'storyTitle': storyTitle,
      'productDescription': productDescription,
    };
  }
}
