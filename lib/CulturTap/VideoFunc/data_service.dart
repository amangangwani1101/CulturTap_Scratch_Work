
import 'package:http/http.dart' as http;
import 'dart:math';
import 'dart:convert';



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


Future<List<dynamic>> fetchDataForStories(double latitude, double longitude, String apiEndpoint) async {
  final uri = Uri.http('173.212.193.109:8080', apiEndpoint, {
    'latitude': latitude.toString(),
    'longitude': longitude.toString(),
  });

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);

    // Calculate distances for each story


    // print('Fetched data: $data');
    return data;
  } else {
    print('failure');
    throw Exception('Failed to load data');
  }
}


class DataService {
  final List<Map<String, dynamic>> categoryData;

  DataService(this.categoryData);
  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {


      final Map<String, dynamic> category = categoryData[categoryIndex];
      final String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);


      List<Map<String, dynamic>> storyDetailsList = [];
      List<String> totalVideoPaths = [];
      List<String> totalVideoCounts = [];
      List<String> storyDistances = [];
      List<String> storyLocations = [];
      List<String> storyCategories = [];





      for (var story in fetchedStoryList) {
        dynamic videoPathData = story['videoPath'];
        double storyLat = story['latitude'];
        double storyLng = story['longitude'];

        String location = story['location'];
        String storyLocation = location?.split(',')?.first ?? '';
        String expDescription = story['expDescription'];
        List<String> placeLoveDesc = List.from(story['placeLoveDesc'] ?? []);
        String dontLikeDesc = story['dontLikeDesc'];
        String review = story['review'];
        int starRating = story['starRating'];
        String selectedVisibility = story['selectedVisibility'];
        String storyTitle = story['storyTitle'];
        String productDescription = story['productDescription'];
        String category = story['category'];
        String genre = story['genre'];
        // Add more details as needed


        String storyCategory = story['category'];

        double douDistance = calculateDistance(latitude, longitude, storyLat, storyLng);
        String distance = '${douDistance.toStringAsFixed(2)}';
        print(distance);

        // print('Distance to story: $distance km');


        if (videoPathData is List) {
          List<String> videoPaths = videoPathData
              .whereType<String>() // Filter out non-string elements
              .toList();

          Map<String, dynamic> storyDetails = {
            'videoPaths': videoPaths,
            'storyDistance': distance,
            'storyLocation': storyLocation,
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
            // Add more details to the map
          };

          // print(storyDetails);
          totalVideoCounts.add('${videoPaths.length}');
          totalVideoPaths.add(genre);
          storyDistances.add(distance);
          storyLocations.add(storyLocation);
          storyCategories.add(storyCategory);


          storyDetailsList.add(storyDetails);
          print('storyDetailsListindata_service $storyDetailsList');
          // print('printing story details');
          // print(categoryData[categoryIndex]['storyDetailsList']);

        } else {
          print('Unsupported videoPath format');
          // Handle unsupported format as needed
        }
      }

      // Update the 'storyUrls' property of the current category
      categoryData[categoryIndex]['storyUrls'] = totalVideoPaths;
      categoryData[categoryIndex]['videoCounts'] = totalVideoCounts;
      categoryData[categoryIndex]['storyDistance'] = storyDistances;
      categoryData[categoryIndex]['storyLocation'] = storyLocations;
      categoryData[categoryIndex]['storyCategory'] = storyCategories;
      categoryData[categoryIndex]['storyDetailsList'] = storyDetailsList;


      // Refresh the UI to reflect the changes
      // setState(() {
      //   isLoading = false;
      // });
      print('Video counts per story in category $categoryIndex: $totalVideoCounts');
      print('All video paths in category $categoryIndex: $totalVideoPaths');
    } catch (error) {
      print('Error fetching stories for category $categoryIndex: $error');
    }
  }

}