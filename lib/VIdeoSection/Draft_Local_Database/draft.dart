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
  String liveLocation;
  String selectedOption;
  String productPrice;
  String transportationPricing;
  String festivalName;
  String foodType;
  String restaurantType;
  String otherGenre;
  String otherCategory;

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
    required this.liveLocation,
    required this.selectedOption,
    required this.productPrice,
    required this.transportationPricing,
    required this.festivalName,
    required this.foodType,
    required this.restaurantType,
    required this.otherGenre,
    required this.otherCategory,
  });

  // Named constructor to create a Draft object from a map
  factory Draft.fromMap(Map<String, dynamic> map) {
    return Draft(
      id: map['id'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      videoPaths: map['videoPaths'],
      selectedLabel: map['selectedLabel'],
      selectedCategory: map['selectedCategory'],
      selectedGenre: map['selectedGenre'],
      experienceDescription: map['experienceDescription'],
      selectedLoveAboutHere: map['selectedLoveAboutHere'],
      dontLikeAboutHere: map['dontLikeAboutHere'],
      selectedaCategory: map['selectedaCategory'],
      reviewText: map['reviewText'],
      starRating: map['starRating'],
      selectedVisibility: map['selectedVisibility'],
      storyTitle: map['storyTitle'],
      productDescription: map['productDescription'],
      liveLocation: map['liveLocation'],
      selectedOption: map['selectedOption'],
      productPrice: map['productPrice'],
      transportationPricing: map['transportationPricing'],
      festivalName: map['festivalName'],
      foodType: map['foodType'],
      restaurantType: map['restaurantType'],
      otherGenre: map['otherGenre'],
      otherCategory: map['otherCategory'],
    );
  }

  // Named constructor to convert a Draft object to a map
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
      'liveLocation' : liveLocation,
      'selectedOption' : selectedOption,
      'productPrice' : productPrice,
      'transportationPricing' : transportationPricing,
      'festivalName' : festivalName,
      'foodType' : foodType,
      'restaurantType' : restaurantType,
      'otherGenre' : otherGenre,
      'otherCategory' : otherCategory,
    };
  }
}
