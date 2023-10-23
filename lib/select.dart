import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Db db;
  late UserProfileCollection userProfileCollection;

  @override
  void initState() {
    super.initState();

    // Replace with your MongoDB connection string
    db = Db('mongodb://your_mongodb_connection_string');
    userProfileCollection = UserProfileCollection(db.collection('profileData'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MongoDB Schema Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Test MongoDB operations for userVideos field
            await testUserVideosField();
          },
          child: Text('Test userVideos Field'),
        ),
      ),
    );
  }

  Future<void> testUserVideosField() async {
    await db.open();

    // Static data for the userVideos field
    List<Label> userVideos = [
      Label(
        category: 'Category1',
        genre: [
          Genre(
            key: 'Genre1',
            value: [
              SingleStory(
                videoPath: ['video1.mp4', 'video2.mp4'],
                latitude: 40.7128,
                longitude: -74.0060,
                location: 'New York City',
                expDescription: 'A wonderful experience',
                placeLoveDesc: ['Beaches', 'Mountains'],
                dontLikeDesc: 'Traffic',
                review: 'Great place to visit',
                starRating: 4.5,
                selectedVisibility: 'Public',
                storyTitle: 'My NYC Adventure',
                productDescription: 'Exploring the city',
              ),
            ],
          ),
        ],
      ),
      // Add more videos and data as needed
    ];

    // Insert the static data
    await userProfileCollection.insertUserVideos(userVideos);

    // Retrieve and print the userVideos data
    List<Label>? retrievedUserVideos = await userProfileCollection.findUserVideos();
    for (var label in retrievedUserVideos!) {
      print('Category: ${label.category}');
      for (var genre in label.genre) {
        print('Genre: ${genre.key}');
        for (var story in genre.value) {
          print('VideoPath: ${story.videoPath}');
          print('Latitude: ${story.latitude}');
          print('Longitude: ${story.longitude}');
          print('Location: ${story.location}');
          print('ExpDescription: ${story.expDescription}');
          print('PlaceLoveDesc: ${story.placeLoveDesc}');
          print('DontLikeDesc: ${story.dontLikeDesc}');
          print('Review: ${story.review}');
          print('StarRating: ${story.starRating}');
          print('SelectedVisibility: ${story.selectedVisibility}');
          print('StoryTitle: ${story.storyTitle}');
          print('ProductDescription: ${story.productDescription}');
        }
      }
    }

    await db.close();
  }
}

class UserProfileCollection {
  final DbCollection _collection;

  UserProfileCollection(this._collection);

  Future<void> insertUserVideos(List<Label> userVideos) async {
    await _collection.update(
      where.eq('category.category.genre.key', 'your_desired_key'), // Adjust the filter to match your data
      modify.set('category.$.category.genre.$.key.value.singleStory', userVideos[0].genre[0].value[0].toJson()),
    );
  }

  Future<List<Label>?> findUserVideos() async {
    final profiles = await _collection.find().toList();
    return profiles
        .map((profile) =>
        Label.fromJson(profile['category'][0] as Map<String, dynamic>))
        .toList();
  }
}

class Label {
  String category;
  List<Genre> genre;

  Label({
    required this.category,
    required this.genre,
  });

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'genre': genre.map((g) => g.toJson()).toList(),
    };
  }

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      category: json['category'],
      genre: List<Genre>.from(json['genre'].map((x) => Genre.fromJson(x))),
    );
  }
}

class Genre {
  String key;
  List<SingleStory> value;

  Genre({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value.map((s) => s.toJson()).toList(),
    };
  }

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      key: json['key'],
      value: List<SingleStory>.from(
          json['value'].map((x) => SingleStory.fromJson(x))),
    );
  }
}

class SingleStory {
  List<String> videoPath;
  double latitude;
  double longitude;
  String location;
  String expDescription;
  List<String> placeLoveDesc;
  String dontLikeDesc;
  String review;
  double starRating;
  String selectedVisibility;
  String storyTitle;
  String productDescription;

  SingleStory({
    required this.videoPath,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.expDescription,
    required this.placeLoveDesc,
    required this.dontLikeDesc,
    required this.review,
    required this.starRating,
    required this.selectedVisibility,
    required this.storyTitle,
    required this.productDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'videoPath': videoPath,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'expDescription': expDescription,
      'placeLoveDesc': placeLoveDesc,
      'dontLikeDesc': dontLikeDesc,
      'review': review,
      'starRating': starRating,
      'selectedVisibility': selectedVisibility,
      'storyTitle': storyTitle,
      'productDescription': productDescription,
    };
  }

  factory SingleStory.fromJson(Map<String, dynamic> json) {
    return SingleStory(
      videoPath: List<String>.from(json['videoPath'].map((x) => x)),
      latitude: json['latitude'],
      longitude: json['longitude'],
      location: json['location'],
      expDescription: json['expDescription'],
      placeLoveDesc: List<String>.from(json['placeLoveDesc'].map((x) => x)),
      dontLikeDesc: json['dontLikeDesc'],
      review: json['review'],
      starRating: json['starRating'],
      selectedVisibility: json['selectedVisibility'],
      storyTitle: json['storyTitle'],
      productDescription: json['productDescription'],
    );
  }
}
