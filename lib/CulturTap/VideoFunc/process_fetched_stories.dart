import 'dart:math';



double calculateDistance(double userLat, double userLng, double storyLat, double storyLng) {
  const double earthRadius = 6371; // Radius of the Earth in kilometers

  // Convert latitude and longitude from degrees to radians
  final double userLatRad = userLat * pi / 180.0;
  final double userLngRad = userLng * pi / 180.0;
  final double storyLatRad = storyLat * pi / 180.0;
  final double storyLngRad = storyLng * pi / 180.0;

  // Calculate the differences
  final double latDiff = storyLatRad - userLatRad;
  final double lngDiff = storyLngRad - userLngRad;

  // Haversine formula to calculate distance
  final double a = pow(sin(latDiff / 2), 2) +
      cos(userLatRad) * cos(storyLatRad) * pow(sin(lngDiff / 2), 2);
  final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  // Distance in kilometers
  final double distance = earthRadius * c;

  return distance;
}



Map<String, dynamic> processFetchedStories(List<dynamic> fetchedStoryList, double latitude, double longitude) {

  List<Map<String, dynamic>> storyDetailsList = [];
  List<String> totalVideoPaths = [];
  List<String> totalVideoCounts = [];
  List<String> storyDistances = [];
  List<String> storyLocations = [];
  List<String> storyTitles = [];
  List<String> storyCategories = [];

  for (var story in fetchedStoryList) {
    dynamic videoPathData = story['videoPath'];

    double storyLat = story['latitude'];
    double storyLng = story['longitude'];

    String location = story['location'];
    String storyTitle = story['storyTitle'];
    String storyLocation = location?.split(',')?.first ?? '';
    String countryLocation = location?.split(',')?.last?.trim() ?? '';
    String cityLocation = location?.split(',')?.elementAt(1)?.trim() ?? '';
    String expDescription = story['expDescription'];
    List<String> placeLoveDesc = List.from(story['placeLoveDesc'] ?? []);
    String dontLikeDesc = story['dontLikeDesc'];
    String review = story['review'];
    int starRating = story['starRating'];
    String selectedVisibility = story['selectedVisibility'];
    String productDescription = story['productDescription'];
    String category = story['category'];
    String genre = story['genre'];
    String storyCategory = story['category'];

    print(story['userID']);
    print(story['userName']);
    String userID = story['userID'];
    String userName = story['userName'];
    int likes = story['likes'];
    int views = story['views'];

    double douDistance = calculateDistance(latitude, longitude, storyLat, storyLng);
    String distance = '${douDistance.toStringAsFixed(2)}';

    if (videoPathData is List) {
      List<String> videoPaths = videoPathData
          .whereType<String>() // Filter out non-string elements
          .toList();

      Map<String, dynamic> storyDetails = {
        'videoPaths': videoPaths,
        'storyDistance': distance,
        'storyLocation': storyLocation,
        'storyCityLocation' : cityLocation,
        'storyCategory': storyCategory,
        'expDescription': expDescription,
        'placeLoveDesc': placeLoveDesc,
        'dontLikeDesc': dontLikeDesc,
        'review': review,
        'starRating': starRating,
        'selectedVisibility': selectedVisibility,
        'storyTitle': storyTitle,
        'productDescription': productDescription,
        'category': category,
        'genre': genre,
        'userID' : userID,
        'userName' : userName,
        'likes' : likes,
        'views' : views,
      };

      totalVideoCounts.add('${videoPaths.length}');
      String thumbnailurl = 'thumbnail-' + videoPaths[0].replaceAll('.mp4', '.webp');
      totalVideoPaths.add('$thumbnailurl');
      storyDistances.add(distance);
      storyLocations.add(storyLocation);
      storyTitles.add(storyTitle);

      storyCategories.add(storyCategory);


      storyDetailsList.add(storyDetails);
    } else {
      print('Unsupported videoPath format');
    }
  }

  return {
    'storyDetailsList': storyDetailsList,
    'totalVideoPaths': totalVideoPaths,
    'totalVideoCounts': totalVideoCounts,
    'storyDistances': storyDistances,
    'storyLocations': storyLocations,
    'storyTitles': storyTitles,
    'storyCategories': storyCategories,
  };
}

