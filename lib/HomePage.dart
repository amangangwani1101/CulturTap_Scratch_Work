//homepage
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/Dummy/dummyHomePage.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/categoryData.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/category_section_builder.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/data_service.dart';
import 'package:learn_flutter/CulturTap/VideoFunc/process_fetched_stories.dart';
import 'package:learn_flutter/CulturTap/appbar.dart';
import 'package:learn_flutter/CulturTap/searchBar.dart';
import 'package:learn_flutter/CustomItems/CostumAppbar.dart';
import 'package:learn_flutter/CustomItems/CustomFooter.dart';
import 'package:learn_flutter/CustomItems/MyCustomScrollPhysics.dart';
import 'package:learn_flutter/CustomItems/VideoAppBar.dart';
import 'package:learn_flutter/Notifications/notification.dart';
import 'package:learn_flutter/SearchEngine/searchPage.dart';
import "package:learn_flutter/Utils/location_utils.dart";
import "package:learn_flutter/Utils/BackButtonHandler.dart";
import 'package:http/http.dart' as http;
import 'package:learn_flutter/fetchDataFromMongodb.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/rendering.dart';
import 'package:learn_flutter/userLocation.dart';
import 'package:learn_flutter/widgets/Constant.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';



Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async{
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyD_Q30r4nDBH0HOpvpclE4U4V8ny6QPJj4",
      authDomain: "culturtap-19340.web.app",
      projectId: "culturtap-19340",
      storageBucket: "culturtap-19340.appspot.com",
      messagingSenderId: "268794997426",
      appId: "1:268794997426:android:694506cda12a213f13f7ab ",
    ),
  );
  print(message.notification!.title.toString());
}



//new stuff

//inside this

class ImageScroll extends StatelessWidget {
  final List<String> imageUrls = [
    'assets/images/home_one.png',
    'assets/images/home_two.png',
    'assets/images/home_three.png',
    'assets/images/home_four.png',
    'assets/images/home_five.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(1.0),
            child: Image.network(
              imageUrls[index],
              width: 150.0, // Adjust the width as needed
              height: 150.0, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}

Future<List<dynamic>> fetchSearchResults(String query, String apiEndpoint) async {
  try {
    // Modify the search API endpoint based on your backend implementation
    final Map<String, dynamic> queryParams = {'query': query};
    final uri = Uri.http('173.212.193.109:8080', apiEndpoint, queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final List<dynamic> searchResults = json.decode(response.body);
      print('Search results: $searchResults');

      return searchResults;
      // Process and update the UI with the search results

    } else {
      print('Failure');
      throw Exception('Failed to load search results');
    }
  } catch (error) {
    print('Error fetching search results: $error');
    throw error; // Add this line to explicitly return an error
  }
}

Future<void> sendNotificationsToAll() async {
  final String serverUrl = '${Constant().serverUrl}/send/send-notifications'; // Update with your server URL

  try {
    final response = await http.post(Uri.parse(serverUrl));

    if (response.statusCode == 200) {
      print('Notifications sent successfully');
    } else {
      print('Failed to send notifications. Status code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error sending notifications: $error');
  }
}




class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  Razorpay ? _razorpay;



  bool _isVisible = true;
  bool isLoading = true;
  String userName = '';
  String userId = '';
  ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();




  Map<int, bool> categoryLoadingStates = {};

  Future<void> fetchDataForCategory(double latitude, double longitude, int categoryIndex) async {
    try {

      final Map<String, dynamic> category = categoryData[categoryIndex];
      String apiEndpoint = category['apiEndpoint'];

      final fetchedStoryList = await fetchDataForStories(latitude, longitude, apiEndpoint);

      Map<String, dynamic> processedData = processFetchedStories(fetchedStoryList, latitude, longitude);

      categoryData[categoryIndex]['storyUrls'] = processedData['totalVideoPaths'];
      categoryData[categoryIndex]['videoCounts'] = processedData['totalVideoCounts'];
      categoryData[categoryIndex]['storyDistance'] = processedData['storyDistances'];
      categoryData[categoryIndex]['storyLocation'] = processedData['storyLocations'];
      categoryData[categoryIndex]['storyTitle'] = processedData['storyTitles'];
      categoryData[categoryIndex]['storyCategory'] = processedData['storyCategories'];
      categoryData[categoryIndex]['thumbnail_url'] = processedData['thumbnail_urls'];
      categoryData[categoryIndex]['storyDetailsList'] = processedData['storyDetailsList'];


      setState(() {
        isLoading = false;
      });


      // print('Video counts per story in category $categoryIndex: ${processedData['totalVideoCounts']}');
      // print('All video paths in category $categoryIndex: ${processedData['totalVideoPaths']}');
      // print('storyurls');
      print('storyUrls');
      print(categoryData[categoryIndex]['storyUrls']);
    } catch (error) {
      print('Error fetching stories for category $categoryIndex: $error');
      setState(() {
        categoryLoadingStates[categoryIndex] = false;
      });
    }
  }

  Future<void> updateLiveLocation(String userId, double liveLatitude, double liveLongitude) async {
    final String serverUrl = Constant().serverUrl;
    final Uri uri = Uri.parse('$serverUrl/updateLiveLocation');
    final Map<String, dynamic> data = {
      'userId': userId,
      'liveLatitude': liveLatitude,
      'liveLongitude': liveLongitude,
    };

    try {
      final response = await http.put(
        uri,
        body: jsonEncode(data),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('Live location updated successfully');
      } else {
        print('Failed to update live location. ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating live location: $error');
    }
  }


// Inside your _HomePageState class

  Future<void> fetchUserLocationAndData() async {
    print('I called');

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      double latitude = position.latitude;
      double longitude = position.longitude;
      String query = _searchController.text;

      getAndPrintLocationNameFast(latitude,longitude);

      updateLiveLocation(userID, position.latitude, position.longitude);

      print('Latitude is: $latitude');

      // Fetch stories for each category

      if(query.isNotEmpty){
        print('wow');

      }
      else{
        for (int i = 0; i < categoryData.length; i++) {
          await fetchDataForCategory(latitude, longitude, i);
        }
      }



    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response){
    // Fluttertoast.showToast(
    //     msg: "SUCCESS PAYMENT : ${response.paymentId}", timeInSecForIosWeb:4
    // );
  }


  void _handlePaymentError(PaymentFailureResponse response){
    // Fluttertoast.showToast(
    //     msg: "ERROR HERE : ${response.code} - ${response.message}", timeInSecForIosWeb:4
    // );
  }

  void _handleExternalWallet(ExternalWalletResponse response){
    // Fluttertoast.showToast(
    //     msg: "External Wallet IS : ${response.walletName}", timeInSecForIosWeb:4
    // );
  }


  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  NotificationServices notificationServices  = NotificationServices();



  @override
  void initState() {

    super.initState();

    _razorpay = Razorpay();
    _razorpay?.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay?.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay?.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);





    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setupInteractMessage(context);
    notificationServices.isTokenRefresh();
    f();

    fetchDataFromMongoDB();

    requestLocationPermission();
    fetchUserLocationAndData();
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
        });
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
        });
      }
    });
    setState(() {


    });
    print('userID print kra rha hu $userID');

  }

  //updated code from here

  void f()async{
    String?token = await notificationServices.getDeviceToken();
    print('Token $token');
  }



  Future<void> fetchUserLocationAndDataasync() async {
    await fetchUserLocationAndData();
    print(userName);
    // Any other asynchronous initialization tasks can be added here
  }

  // void makePayment() async{
  //   var options = {
  //     'key' : 'rzp_live_GmFI5alUgs6ny1',
  //     'amount' : '100',
  //     'name' : 'Culturtap',
  //     'description' : 'trip Planning Services',
  //     'prefill' : {'contact' : userPhoneNumber, 'email' : 'utkarsh@culturtap.com'},
  //     'external' : {
  //       'wallets' : ['paytm'],
  //       'upi' : {'utkarshg494@okicici' : '6394687295', 'Utkarsh' : 'Aishwary'},
  //     },
  //     'theme' : {'color' : '#FB8C00'},
  //     'image' : 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAOEAAADhCAMAAAAJbSJIAAAAw1BMVEX////7jAD7hwD7igD7hAD+69j7kgD7hgD9won//vv9xp77gwD7mRH+6tD9yZX7jgD+8eP9u3z+27D8nzj9woH+3r7+2sL/8+v8q2b8q0/+69/9vXP+5NL/+PD7kBD//Pb8oVH+2rb8s2z/8d/9xY/+4sf9uWv8oTP8pEH+7tb8ozL9z538qTv9xpX7lwD/9O78rVz90aj8sV78p037mDL7liP91KX8n0D8tXL9xoP8q0n8vIr+5MT8sFX91rb8t3n8nksJwcvIAAAFrklEQVR4nO3Ye3+aOhwGcMgvigwLeOmxrkOmaNW5td7ouq5bz/t/VScIgSDgbWdnZ/s833/aQAh5EJKApgEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/H68+Xxu/lALP3b0z1WzP5DFuWWxD92Je6Ty4r4Zu1/ktk8+Xnbyh3qzTO2y1koFDccg0iNEjDqfDme0OcX4G3Vze3B/2ekfLCrhXF3WWplHncXxEsT0gxFtllRkSkKvq1PzsvM/WHoR1f+1hOaCaL/1jX/oiLKE7pLR/zVhSUB9ePCIkoSTjtj20xKaB4ewY+PbhO8H1GkpfsJVI/EoKtW6sjQ0SxKaK4N2nRo3GmNPm8vKLU/cvQtZGkelsSwtPM2/HvXXK+9QQnM+WTXW/X6/u5p4SY/dtDMLrba6638bp7vKeJtCQN2K2r7hbIc/i0x/WXGBWa2yhLdymGLMcFytndbuiVFsmzQU7dECx0ianbreSIxqzBh5lQnNxU2oGywad8ThGzs+25Vs3tjaYbSX6e/n1Qm/G4W22TracZMkp36UkMt9JQlroZFdJaqLhHJ/lNDtULZHc+uy1HFn8WF81ON6EdVrj2QoTxCRsdkNgFdpdWJyAqBFZcLn4j3qTM5KONyqTZyccNPlsue1ioR3bG8b6+cTKrVZ5bikNhLNhcKTeUZC3yamtnBywsFAXhhjVbyPdglv9xPqfFiRUKfPFRPcPHsEiGajp9GszuOrcWLCL9PZNG3Cmc1mz72TEurZ/WesxGqKcyUOE0WLdgmjS67kWFYl1GlVnvCRK1U83/c9d6Kdk7DneW35a1DT9zwxrJ2UMJqU4j+G+1Zwv6YR2VMv2qLdibWT83E6yDLSNsgnVFrrl8/hi/QGoVm+xukjzUuWMD70tITkxP+y23hCe5Ml7Mbt3L1fBLsbbSl30WCSH2kcyu6Jh2MJ5Qwb/DcJxfk2XDz31ix5gIoJAznNeenT61znfsNxbeHIBq3ylfq1cpdS335c3YXsrOfw4oRMPDft0c3No+xKMaGm+bXGbDr9ZndKE9J7UaUhD+PlCzFPmWyjaVVMoOyssTSX8P70hKTvX/KShO5TNCMSpS8GJQnbRxJqypMvj4tv1wsS6tzTzOHJM/7RhO5mF02slA4kXKQnq3ifHB9d0zRNZeVzOCGFrbX1NktotEU3pxcnbO2isNGb10H5Xfp57k3keqNqpNGuij+izgIloQg1b2+zQjHhPMzGR0ZqQtq+XK3TfWcn3A0i7MnX/OeKkSb8nJ6bplXLb1uZaeUZoh9xlHab8WzdWZbQzy3b+FvtOm2SePbmcnbC+W6D8V28YfQrEirLgeqVqT8tRKRQPIlfypZSpQm13PpRJPTLFx2XJYzmaXNakVDtc/VnnV7x/SkaTl115eAMDiV0B0oLIqH2rEQeyEPPv0vjFQsNPoblI40aMHrkK7n9vZdg8TSJ099miwEaywGxNKE2VFZP4jnUJuk0rPPb14tHmuTtQ1maViUk1joQUEyKdpg2smtuFk0t3ohRPFgPhsE2+QAWJzSSkiG/Yrw4cQMUXxxt5cTjPNFa+8qS2knCRDGhbJWMJKG3TGYL8R4iP8DlEsbZo1dg+9inDHe8rDPxLm5wPVx+ekm22pu6xWnaCrRgWo853SihLkvpdxpX1DW4Ve804hXRyygUA1R9KS7VVyep3YwSNuWhs0JCWa/ufJGXvtE0OIWvV2u57z43W2xboc653mkdeMXPfsfau++2vZjUAi+38d27wIxWT1LUr15a6ikXKapbS7vtB1HR2+2QRENmWgj2r3rWataKFsQdyNrw8jN+UFNP+qfIr2n+REj4+8u+Jv79q7vyk7h3t4nxr+4KAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQM4/7b1y+FDhCc8AAAAASUVORK5CYII=',
  //     'currency' : 'INR',
  //   };
  //   try{
  //     _razorpay?.open(options);
  //
  //   }catch(e){
  //     debugPrint(e.toString());
  //   }
  // }

  List<Map<String, dynamic>> categoryData = [
    ...generateCategoryData(name: 'Trending NearBy', apiEndpoint: '/main/api/trending-nearby-places'),
    ...generateCategoryData(specificName: 'Trending Visits in Nation', apiEndpoint: '/nation/api/trending-visits-in-nation'),
    ...generateCategoryData(name: 'International Trendings', apiEndpoint: '/international/trending-international'),
    ...generateCategoryData(name: 'Festivals Around You', apiEndpoint: 'api/nearby-places/Festivals'),
    ...generateCategoryData(specificName: 'Are You Feeling Hungry ?',name: 'Street Foods Nearby', apiEndpoint: 'api/nearby-places/Street Foods'),
    ...generateCategoryData(specificName: 'Are You Feeling Hungry ?',name: 'Restaurants Near you', apiEndpoint: 'api/nearby-places/Restaurants'),
    ...generateCategoryData(name: 'Popular & Trending here in foods', apiEndpoint: 'popular/api/popular-foods'),
    ...generateCategoryData(name: 'Local Stores Near you', apiEndpoint: 'api/nearby-places/Fashion'),
    ...generateCategoryData(specificName: 'Local Fashion for you !', name: 'Popular & Trending Here', apiEndpoint: '/fashion/api/nearby-fashion-places'),
    ...generateCategoryData(specificName: 'Local Fashion for you !', name: 'Popular & Trending here', apiEndpoint: '/popularFashion/api/popular-fashion-places'),
    ...generateCategoryData(specificName: 'Party Tonight ?', name: 'Popular & Trending Clubs Here', apiEndpoint: 'api/nearby-places/Party-Clubs & Bars'),
    ...generateCategoryData(specificName: 'Party Tonight ?', name: 'Nearby Hotels & Resorts', apiEndpoint: 'api/nearby-places/Resorts'),
    ...generateCategoryData(specificName: 'Other Outlets', name: 'Local Furniture', apiEndpoint: 'api/stories/best/businessCategory/Furniture'),
    ...generateCategoryData(specificName: 'Other Outlets', name: 'Handy-Crafts', apiEndpoint: 'api/stories/best/businessCategory/Handicraft'),
    ...generateCategoryData(specificName: 'Famous Visiting Places', name: 'Forests Near you', apiEndpoint: 'api/nearby-places/Forests'),
    ...generateCategoryData(specificName: 'Famous Visiting Places', name: 'Famous RiverSides Here', apiEndpoint: 'api/nearby-places/Riverside'),
    ...generateCategoryData(specificName: '', name: 'Islands Here', apiEndpoint: 'api/nearby-places/Island'),

  ];


  BackButtonHandler backButtonHandler10 = BackButtonHandler(
    imagePath: 'assets/images/exit.svg',
    textField: 'Do you want to exit?',
    what: 'exit',
    button1: 'NO',
    button2:'EXIT',
  );

  Future<void> _refreshHomepage() async {
    await fetchUserLocationAndData();
    fetchDataFromMongoDB();

    print(userName);
    print(userId);
  }


  Widget build(BuildContext context) {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
    //   statusBarColor: Colors.white,
    //   statusBarBrightness: Brightness.light,
    // ));
    return WillPopScope(

      onWillPop: () => backButtonHandler10.onWillPop(context, true),
      child: Scaffold(



        backgroundColor: Theme.of(context).backgroundColor,
        body: RefreshIndicator(
          backgroundColor: Color(0xFF263238),
          color: Colors.orange,
          onRefresh: _refreshHomepage,
          child: CustomScrollView(
            physics: MyBouncingScrollPhysics(),
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                title: ProfileHeader(reqPage: 0, userId:userID),
                automaticallyImplyLeading: false,
                shadowColor: Colors.transparent,
                backgroundColor: Theme.of(context).backgroundColor,

                toolbarHeight: 90,
                // Adjust as needed
                floating: true,
                pinned: false,
                flexibleSpace: FlexibleSpaceBar(




                  // You can add more customization to the flexible space here
                ),
              ),


              SliverList(
                delegate: SliverChildListDelegate(
                  [


                    StoryBar(),
                    // InkWell(
                    //   onTap:(){
                    //     makePayment();
                    //   },
                    //     child: Text('create Payment')),




                    isLoading ? Container(
                      height : 500,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(child: CircularProgressIndicator(color : Theme.of(context).primaryColor,)),
                          ],
                        ),
                      ),
                    ) :
                    Column(
                      children: categoryData.asMap().entries.map((entry) {
                        final int categoryIndex = entry.key;
                        final Map<String, dynamic> category = entry.value;

                        final bool categoryLoading = categoryLoadingStates[categoryIndex] ?? false;
                        final String specificCategoryName = category['specificName'];
                        final String categoryName = category['name'];
                        final String whereTo = 'home';
                        final List<String> storyUrls = category['storyUrls'];
                        final List<String> videoCounts = category['videoCounts'];
                        final List<String> storyDistance = category['storyDistance'];
                        final List<String> storyLocation = category['storyLocation'];
                        final List<String> storyCategory = category['storyCategory'];
                        final List<String> storyTitle = category['storyTitle'];
                        List<Map<String, dynamic>> storyDetailsList = category['storyDetailsList'];

                        return buildCategorySection(
                          specificCategoryName,
                          categoryName,
                          whereTo,
                          storyUrls,
                          videoCounts,
                          storyDistance,
                          storyLocation,
                          storyTitle,
                          storyCategory,
                          storyDetailsList,
                          categoryLoading,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

        ),
        bottomNavigationBar: AnimatedContainer(
          duration: Duration(milliseconds: 100),
          height: _isVisible ? 70 : 0,
          child: SingleChildScrollView(
            child: Container(
                height : 70,
                child: CustomFooter(userName: userName, userId: userID, lode: 'home')),
          ),
        ),

      ),
    );
  }
}
